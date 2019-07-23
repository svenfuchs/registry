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

    def delete(key)
      objects.delete(key)
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

      name = base.name.to_s.split('::').last
      name = name ? name.downcase.to_sym : :default
      base.instance_variable_set(:@registry_name, name)

      base.instance_variable_set(:@registries, Registries.new)
    end
  end

  module ClassMethods
    attr_reader :registry_key

    def register(*args)
      obj = !(args.last.is_a?(Symbol) || args.last.is_a?(String)) ? args.pop : self
      args.reverse.map(&:to_sym).each do |key|
        obj.instance_variable_set(:@registry_key, key)
        registry[key] = obj
      end
      self
    end

    def unregister(obj = self)
      return unless obj.respond_to?(:registry_key) && obj.registry_key
      registry.delete(obj.registry_key)
      obj.remove_instance_variable(:@registry_key)
    end

    def registered?(key)
      registry.key?(key && key.to_sym)
    end

    def lookup(key)
      registered?(key) ? self[key] : registries[key]
    end

    def [](key)
      registry[key && key.to_sym] || fail(MSGS[:unknown] % [key, registry.keys.sort])
    end

    def registry(name = nil)
      @registry ||= registries.registry(registry_name(name))
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
