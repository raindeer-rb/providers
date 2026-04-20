# frozen_string_literal: true

require_relative 'config/config'
require_relative 'expressions/dependency'
require_relative 'factories/dependency_factory'
require_relative 'repositories/dependencies'
require_relative 'providers'

class Dependencies
  class << self
    def provide(key, &block)
      Low::Dependencies.provide(key:, &block)
    end

    # Usage: "include Dependencies[:dependency]"
    def [](*dependencies)
      class_dependencies = Low::DependencyFactory.parse([*dependencies])

      # "include" doesn't know the class that did the include, however "included" happens immediately after.
      Low::Dependencies.push(class_dependencies:)

      included_hook
    end

    def included_hook
      Module.new do
        def self.included(klass)
          klass.class_eval do
            # "include" doesn't know the class that did the include, however "included" happens immediately after.
            @low_dependencies = Low::Dependencies.pop

            class << self
              attr_reader :low_dependencies
            end

            def initialize
              self.class.low_dependencies.each do |dependency|
                provider = Low::Providers.find(dependency.provider_key)
                raise StandardError, "Provider #{dependency.provider_key} not found" if provider.nil?

                var_name = Providers.var_name_via_namespace(dependency.var_name)
                instance_variable_set("@#{var_name}", provider.result)
              end
            end

            Providers.define_readers(@low_dependencies, self)
          end
        end
      end
    end

    def define_readers(dependencies, klass)
      dependencies.each do |dependency|
        var_name = var_name_via_namespace(dependency.var_name)

        klass.define_method(var_name) do
          instance_variable_get("@#{var_name}")
        end
      end
    end

    def var_name_via_namespace(namespace)
      return namespace.split('.').last if namespace.is_a?(String)

      namespace
    end
  end
end
