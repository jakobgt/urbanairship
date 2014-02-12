module Urbanairship
  class PushObject

    # manuually set push object values
    attr_accessor :audience, :notification, :device_types, :options, :message
    # automatically build push object
    attr_accessor :tokens, :token_device_types, :audience_identifiers, :overrides, :implied_overrides, :extras, :alert

    PLATFORMS = {
      :ios => {
        :identifier => :device_token,
        :overrides =>[ :alert, :badge, :sound, 'content-available'.to_sym, :content_available, :extra, :expiry, :priority ]
      },
      :android => {
        :identifier => :apid,
        :overrides => [ :alert, :collapse_key, :time_to_live, :delay_while_idle, :extra ]
      },
      :blackberry => {
        :identifier => :device_pin,
        :overrides => [ :alert, :body, :content_type, 'content-type'.to_sym ]
      },
      :mpns => {
        :identifier => :mpns,
        :overrides => [ :alert, :toast, :tile ]
      },
      :wns => {
        :identifier => :wns,
        :overrides => [ :alert, :toast, :tile, :badge ]
      }
    }

    AUDIENCE_IDENTIFIERS = [:tag, :alias, :segment]
    TOKEN_IDENTIFIERS = PLATFORMS.keys.collect { |platform| PLATFORMS[platform][:identifier] }

    def initialize(attributes={})
      self.tokens = {}
      self.audience_identifiers = {}
      self.token_device_types = []
      self.overrides = {}
      self.implied_overrides = {}
      self.extras = {}

      process_arguments(attributes)
    end

    def process_arguments(attributes={})
      attributes.each_pair do |k, v|
        send("#{k}=".to_sym, v)
      end
    end

    # build the push object

    def build
      json = {
        :audience     => audience.nil? ? generated_audience : audience,
        :notification => notification.nil? ? notification_with_overrides : notification
      }
      if !device_types.nil?
        json[:device_types] = device_types
      else
        if !token_device_types.empty?
          json[:device_types] = token_device_types
        end
      end

      unless options.nil?
        json[:options] = options
      end

      unless message.nil?
        json[:message] = message
      end

      json
    end

    # helpers

    def add_platform_override(platform, key, value)
      return false if PLATFORMS[platform.to_sym].nil?
      return false if !PLATFORMS[platform.to_sym][:overrides].include?(key.to_sym)

      overrides[platform] ||= {}
      overrides[platform][key] = value

      value
    end

    def add_extra(key, value)
      extras[key.to_sym] = value.to_s
    end

    def add_override_and_extras(values)
      values.each_pair do |k, v|
        add_override_or_extra(k, v)
      end
    end

    # adds a value to the notification
    # settings it as a platform override if it matches
    # settings it as an extra otherwise
    def add_override_or_extra(key, value)
      key = key.to_sym
      is_override = false

      iterate_platforms do |platform|
        if PLATFORMS[platform][:overrides].include?(key)
          add_platform_override(platform, key, value)

          implied_overrides[key] = value

          is_override = true
        end
      end

      unless is_override
        add_extra(key, value)
      end

      value
    end

    def overrides_platform_present(override)
      override = override.to_sym
      return true if audience == 'all'
      return true if device_types == 'all'

      platforms = []
      iterate_platforms do |platform|
        if PLATFORMS[platform][:overrides].include?(override) && token_device_types.include?(override)
          platforms.push(platform)
        end
      end
    end

    def method_missing(method, *args, &block)
      is_assignment = method[-1,1] == '='

      base_method = method.to_s
      base_method.chop! if is_assignment
      base_method = base_method.to_sym

      if is_assignment
        # look for methods, e.g., po.apids= ... or po.device_token= ...
        iterate_platforms do |platform|
          identifier = PLATFORMS[platform][:identifier]
          if [ identifier, "#{identifier}s".to_sym ].include?(base_method)
            add_token_identifiers(args.first, platform, true)
            return args
          end
        end

        # no token assignment found, add as an override or extra
        return add_override_or_extra(base_method, args.first)
      else
        # return the extras value if one has been set
        return extras[base_method] if extras.has_key?(base_method)

        iterate_platforms do |platform|
          # look for token methods, e.g., po.apid or po.device_tokens
          identifier = PLATFORMS[platform][:identifier]
          if [ identifier, "#{identifier}s".to_sym ].include?(base_method)
            return tokens[identifier]
          end

          # look for a platform override, e.g., po.collapse_key
          if PLATFORMS[platform][:overrides].include?(base_method)
            return overrides[platform][base_method]
          end
        end
      end

      super(method, *args, &block)
    end

    def to_json
      build.to_json
    end

    private

    # adds new device tokens to the correct platform hash
    # replaces the current tokens if specified
    # also adds the correct platform identifier
    def add_token_identifiers(new_identifiers, platform, replace=false)
      return false if PLATFORMS[platform].nil?

      platform_identifier_key = PLATFORMS[platform][:identifier]

      identifiers = replace ? [] : tokens[platform_identifier_key] || []
      for identifier in wrap(new_identifiers)
        identifiers.push(identifier)
      end
      tokens[platform_identifier_key] = identifiers

      token_device_types.push(platform).uniq!
      token_device_types.sort!

      new_identifiers
    end

    def add_audience_identifiers(new_identifiers, identifier, replace=false)
      return false unless AUDIENCE_IDENTIFIERS.include?(identifier)

      identifiers = replace ? [] : audience_identifiers[identifier] || []
      for ident in wrap(new_identifiers)
        identifiers.push(ident)
      end
      audience_identifiers[identifier] = identifiers

      new_identifiers
    end

    def add_token_audience(identifier, values, replace=false)
      return false unless TOKEN_IDENTIFIERS.include?(identifier)
      current_identifiers = replace ? [] : tokens[identifier] || []
      for identifier in wrap(values)
        current_identifiers.push(identifier)
      end
      tokens[identifier] = current_identifiers

      values
    end

    def generated_audience
      or_value = []

      iterate_platforms do |platform|
        identifier = PLATFORMS[platform][:identifier]
        or_value.push({ identifier => tokens[identifier] }) unless tokens[identifier].nil?
      end

      iterate_audience_identifiers do |identifier|
        or_value.push({ identifier => audience_identifiers[identifier] }) unless audience_identifiers[identifier].nil?
      end

      if or_value.length == 0
        nil
      elsif or_value.length == 1
        or_value[0]
      else
        {
          :OR => or_value
        }
      end
    end

    def notification_with_overrides
      notifs = {}
      notifs[:alert] = alert

      unless extras.empty?
        for device_type in token_device_types
          add_platform_override(device_type, :extra, extras)
        end
      end

      iterate_platforms do |platform|
        notifs[platform] = overrides[platform] if !overrides[platform].nil? && token_device_types.include?(platform)
      end

      notifs
    end

    def wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end

    def self.iterate_platforms(&block)
      PLATFORMS.keys.sort.each do |platform|
        yield platform
      end
    end

    def iterate_platforms(&block)
      Urbanairship::PushObject.iterate_platforms(&block)
    end

    def self.iterate_audience_identifiers(&block)
      AUDIENCE_IDENTIFIERS.sort.each do |identifier|
        yield identifier
      end
    end

    def iterate_audience_identifiers(&block)
      Urbanairship::PushObject.iterate_audience_identifiers(&block)
    end

    # meta programming

    # create methods for for tokens, e.g.,
    # po.add_device_tokens(...)
    # po.add_apid(...)
    def self.define_add_identifier(identifier, platform)
      define_method("add_#{identifier}") do |tokens|
        add_token_identifiers(tokens, platform)
      end
    end

    Urbanairship::PushObject.iterate_platforms do |platform|
      identifier = PLATFORMS[platform][:identifier]
      plural_identifier = "#{identifier}s".to_sym
      define_add_identifier(identifier, platform)
      define_add_identifier(plural_identifier, platform)
    end

    # create methods for non-token identifiers, e.g.,
    # po.add_tags(...)
    # po.add_segment(...)
    def self.define_audience_methods(name, identifier)
      define_method("add_#{name}") do |identifiers|
        add_audience_identifiers(identifiers, identifier)
      end

      define_method(name) do
        audience_identifiers[identifier]
      end

      define_method("#{name}=") do |identifiers|
        add_audience_identifiers(identifiers, identifier, true)
      end
    end

    AUDIENCE_IDENTIFIERS.each do |value|
      identifier = value
      plural_identifier = value == :alias ? "#{identifier}es".to_sym : "#{identifier}s".to_sym
      define_audience_methods(identifier, identifier)
      define_audience_methods(plural_identifier, identifier)
    end

  end
end
