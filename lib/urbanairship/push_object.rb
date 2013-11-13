module Urbanairship
  class PushObject

    # manuually set push object values
    attr_accessor :audience, :notification, :device_types, :options, :message
    # automatically build push object
    attr_accessor :tokens, :token_device_types, :overrides, :implied_overrides, :extras, :alert

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

    def initialize(attributes={})
      self.tokens = {}
      self.token_device_types = []
      self.overrides = {}
      self.implied_overrides = {}
      self.extras = {}

      process_arguments(attributes)
    end

    def process_arguments(attributes={})
      iterate_platforms do |platform|
        platform_identifier_key = PLATFORMS[platform][:identifier]
        device_identifiers = attributes.delete(platform_identifier_key)
        add_identifiers(device_identifiers, platform) unless device_identifiers.nil?

        platform_identifier_key_plural = "#{platform_identifier_key}s".to_sym
        device_identifiers_plural = attributes.delete(platform_identifier_key_plural)
        add_identifiers(device_identifiers_plural, platform) unless device_identifiers_plural.nil?
      end

      alert_arg = attributes.delete(:alert)
      self.alert = alert_arg unless alert_arg.nil?

      attributes.each_pair do |k, v|
        add_override_or_extra(k, v)
      end
    end

    # build the push object

    def build
      json = {
        :audience     => audience.nil? ? device_token_audience : audience,
        :notification => notification.nil? ? notification_with_overrides : notification,
        :device_types => device_types.nil? ? token_device_types : device_types
      }

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
        iterate_platforms do |platform|
          identifier = PLATFORMS[platform][:identifier]
          if [ identifier, "#{identifier}s".to_sym ].include?(base_method)
            add_identifiers(args.first, platform, true)
            return args
          end
        end

        return add_override_or_extra(base_method, args.first)
      else
        return extras[base_method] if extras.has_key?(base_method)

        iterate_platforms do |platform|
          identifier = PLATFORMS[platform][:identifier]
          if [ identifier, "#{identifier}s".to_sym ].include?(base_method)
            return tokens[identifier]
          end

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

    def add_identifiers(new_identifiers, platform, replace=false)
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

    def add_audience(identifier, values, replace=false)
      return false unless [:tag, :alias, :segment].include?(identifier)
      current_identifiers = replace ? [] : tokens[identifier] || []
      for identifier in wrap(values)
        current_identifiers.push(identifier)
      end
      tokens[identifier] = current_identifiers

      values
    end

    def device_token_audience
      if tokens.size == 1
        tokens
      elsif tokens.size > 1
        or_value = []

        iterate_platforms do |platform|
          identifier = PLATFORMS[platform][:identifier]
          or_value.push({ identifier => tokens[identifier] }) unless tokens[identifier].nil?
        end

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

    # meta programming

    def self.define_add_identifier(identifier, platform)
      define_method("add_#{identifier}") do |tokens|
        add_identifiers(tokens, platform)
      end
    end

    Urbanairship::PushObject.iterate_platforms do |platform|
      identifier = PLATFORMS[platform][:identifier]
      plural_identifier = "#{identifier}s".to_sym
      define_add_identifier(identifier, platform)
      define_add_identifier(plural_identifier, platform)
    end

    def self.define_audience_methods(name, identifier)
      define_method("add_#{name}") do |tokens|
        add_audience(tokens, identifier)
      end

      define_method(name) do
        tokens[identifier]
      end

      define_method("#{name}=") do |tokens|
        add_audience(tokens, identifier, true)
      end
    end

    [:tag, :alias, :segement].each do |value|
      identifier = value
      plural_identifier = value == :alias ? "#{identifier}es".to_sym : "#{identifier}s".to_sym
      define_audience_methods(identifier, identifier)
      define_audience_methods(plural_identifier, identifier)
    end

  end
end
