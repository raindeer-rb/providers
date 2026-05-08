# frozen_string_literal: true

require_relative 'config/config'
require_relative 'dependencies/dependency'
require_relative 'dependencies/factory'
require_relative 'dependencies/repository'
require_relative 'providers'

module Dependencies
  class << self
    # Usage: "include Dependencies[:dependency]"
    def [](*dependencies)
      class_dependencies = Factory.parse([*dependencies])

      # "include" doesn't know the class that did the include, however "included" happens immediately after.
      Repository.push(class_dependencies:)

      included_hook
    end

    def included_hook
      Module.new do
        def self.included(klass)
          klass.class_eval do
            # "include" doesn't know the class that did the include, however "included" happens immediately after.
            @dependencies = Repository.pop

            class << self
              attr_reader :dependencies
            end

            def initialize
              self.class.dependencies.each do |dependency|
                provider = Providers[dependency.provider_key]
                raise StandardError, "Provider #{dependency.provider_key} is missing or returning nil" if provider.nil?

                var_name = Dependencies.name_from_namespace(dependency.var_name)
                instance_variable_set("@#{var_name}", provider)
              end
            end

            Dependencies.define_readers(@dependencies, self)
          end
        end
      end
    end

    def define_readers(dependencies, klass)
      dependencies.each do |dependency|
        var_name = name_from_namespace(dependency.var_name)

        klass.define_method(var_name) do
          instance_variable_get("@#{var_name}")
        end
      end
    end

    def name_from_namespace(namespace)
      return namespace.split('.').last if namespace.is_a?(String)

      namespace
    end
  end
end
