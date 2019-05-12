# frozen_string_literal: true
require 'forwardable'

module Registry
  MSGS = {
    unknown: 'can not use unregistered object %p. known objects are: %p'
  }

  class UnknownKey < StandardError
  end

  class Registries
    extend Forwardable
    include Enumerable

    def_delegators :registries, :each, :keys, :values

    def [](key)
      registry = values.detect { |registry| registry.key?(key) }
      obj = registry[key] if registry
      obj || raise(UnknownKey, MSGS[:unknown] % [key, all_keys])
    end

    def registry(key)
      registries[key]
    end

    def registries
      @registries ||= Hash.new { |registries, key| registries[key] = Registry.new }
    end

    def all_keys
      values.map(&:keys).flatten.sort
    end
  end

  class Registry
    extend Forwardable
    include Enumerable

    def_delegators :objects, :each, :key?, :keys, :values

    def []=(key, object)
      objects[key.to_sym] = object
    end

    def [](key)
      key && objects[key.to_sym] || raise(UnknownKey, MSGS[:unknown] % [key, objects.keys.sort])
    end

    def objects
      @objects ||= {}
    end

    def clear
      objects.clear
    end
  end

  class << self
    def included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)

      name = base.name.to_s.split('::').last&.downcase&.to_sym || :default
      base.instance_variable_set(:@registry_name, name)

      base.instance_variable_set(:@registries, Registries.new)
    end
  end

  module ClassMethods
    attr_reader :registry_key

    def register(key, obj = self)
      obj.instance_variable_set(:@registry_key, key)
      registry[key] = obj
    end

    def registered?(key)
      registry.key?(key&.to_sym)
    end

    def lookup(key)
      registered?(key) ? self[key] : registries[key]
    end

    def [](key)
      registry[key&.to_sym] || fail(MSGS[:unknown] % [key, registry.keys.sort])
    end

    def registry(name = nil)
      name ? registry_name(name) : @registry ||= registries.registry(registry_name)
    end

    def registry_name(name = nil)
      name.nil? ? @registry_name ||= superclass.registry_name : @registry_name = name
    end

    def registries
      @registries ||= superclass.registries
    end
  end

  module InstanceMethods
    def registry_key
      self.class.registry_key
    end

    def registry_name
      self.class.registry_name
    end
  end
end
