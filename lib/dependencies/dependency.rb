# frozen_string_literal: true

require 'expressions'

module Dependencies
  # A Dependency Expression requires LowType in order to be injected via a constructor.
  class Dependency < ::Expressions::Expression
    attr_reader :provider_key, :var_name

    def initialize(provider_key: nil, var_name: nil)
      super()

      @provider_key = provider_key || var_name
      @var_name = var_name
    end

    def required?
      false
    end

    # Inject dependency via LowType's default value.
    def default_value
      Providers[@provider_key]
    end

    # Ignore LowType's validation on arguments of type Dependency.
    def validate!(value:, proxy:); end

    private

    def union_value(value)
      @provider_key = value
      @var_name = Dependencies.name_from_namespace(value)
    end
  end
end
