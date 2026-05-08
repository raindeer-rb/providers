# frozen_string_literal: true

module Providers
  class Provider
    attr_reader :key

    def initialize(key:, &block)
      @key = key
      @proc = block
      @result = nil
    end

    def result
      @result ||= @proc.call
    end
  end
end
