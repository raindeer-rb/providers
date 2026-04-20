# frozen_string_literal: true

require_relative '../models/provider'

class Providers
  class MissingProviderError < StandardError; end

  class << self
    def provide(key:, &block)
      providers[key] = Provider.new(key:, &block)
    end

    def providers
      @providers ||= {}
      @providers
    end

    def find(provider_key)
      providers[provider_key]
    end

    # Providers[] are hard to stub in tests and should only be used when dependency injection isn't possible.
    # TODO: Make Providers[] easy to stub in tests and look into feature where we get providers from another Ecosystem.
    def [](provider_key)
      provider = providers[provider_key]
      raise(MissingProviderError, "Provider #{provider_key.inspect} not found") if provider.nil?

      provider.result
    end

    def all
      providers
    end

    def clear
      @providers = {}
    end
  end
end
