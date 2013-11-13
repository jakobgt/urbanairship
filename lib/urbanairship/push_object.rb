module Urbanairship
  class PushObject

    attr_accessor :audience, :notification, :device_types, :options, :message
    attr_accessor :tokens, :token_device_types, :overrides, :extras, :alert

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
      self.options = {}
      self.message = {}

      self.tokens = {}
      self.token_device_types = []
      self.overrides = {}
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

    # device identifiers

    def device_tokens=(device_tokens)
      add_identifiers(device_tokens, :ios, true)
    end

    def add_device_tokens(device_tokens)
      add_identifiers(device_tokens, :ios)
    end

    def apids=(apids)
      add_identifiers(apids, :android, true)
    end

    def add_apids(apids)
      add_identifiers(apids, :android)
    end

    def device_pins=(device_pins)
      add_identifiers(device_pins, :blackberry, true)
    end

    def add_device_pins(device_pins)
      add_identifiers(device_pins, :blackberry)
    end

    def mpns=(mpns)
      add_identifiers(mpns, :mpns, true)
    end

    def add_mpns(mpns)
      add_identifiers(mpns, :mpns)
    end

    def wns=(wns)
      add_identifiers(wns, :wns, true)
    end

    def add_wns(wns)
      add_identifiers(wns, :wns)
    end

    # build the push object

    def build
      json = {
        :audience     => audience.nil? ? device_token_audience : audience,
        :notification => notification.nil? ? notification_with_overrides : notification,
        :device_types => device_types.nil? ? token_device_types : device_types
      }

      if !options.nil? && !options.empty?
        json[:options] = message
      end

      if message.nil? && !message.empty?
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
      true
    end

    def add_override_or_extra(key, value)
      key = key.to_sym
      is_override = false

      iterate_platforms do |platform|
        if PLATFORMS[platform][:overrides].include?(key)
          add_platform_override(platform, key, value)
          is_override = true
        end
      end

      unless is_override
        add_extra(key, value)
      end

      true
    end

    def add_extra(key, value)
      extras[key.to_sym] = value.to_s
    end

    def method_missing(method, *args, &block)
      is_assignment = method[-1,1] == '='

      base_method = method.to_s
      base_method.chop! if is_assignment
      base_method = base_method.to_sym

      if is_assignment
        return add_override_or_extra(base_method, args.first)
      else
        return extras[base_method] if extras.has_key?(base_method)

        iterate_platforms do |platform|
          if PLATFORMS[platform][:overrides].include?(base_method)
            return overrides[platform][base_method]
          end
        end
      end

      super(method, *args, &block)
    end

    private

    def add_identifiers(new_identifiers, platform, replace=false)
      return if PLATFORMS[platform].nil?

      platform_identifier_key = PLATFORMS[platform][:identifier]

      identifiers = replace ? [] : tokens[platform_identifier_key] || []
      for identifier in wrap(new_identifiers)
        identifiers.push(identifier)
      end
      tokens[platform_identifier_key] = identifiers

      token_device_types.push(platform).uniq!
      token_device_types.sort!
      true
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

    def iterate_platforms(&block)
      PLATFORMS.keys.sort.each do |platform|
        yield platform
      end
    end
  end
end
