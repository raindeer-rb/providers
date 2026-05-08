# frozen_string_literal: true

require_relative '../dependencies/dependency'

module Dependencies
  class Factory
    class << self
      def parse(dependencies)
        class_dependencies = []

        dependencies.each do |dependency|
          case dependency
          when Hash
            provider_key = dependency.keys.first
            dependency = dependency[provider_key]
          else
            provider_key = dependency
          end

          class_dependencies << (Dependency.new(var_name: dependency) | provider_key)
        end

        class_dependencies
      end
    end
  end
end
