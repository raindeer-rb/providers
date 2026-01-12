# frozen_string_literal: true

require_relative '../models/provider'

module Low
  # Private API. Public methods exposed via LowDependency.
  class Providers
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

      # Providers[] is harder to stub in tests and should only be used when dependency injection isn't possible.
      def [](provider_key)
        providers[provider_key].result
      end

      def all
        providers
      end

      def clear
        @providers = {}
      end
    end
  end
end
