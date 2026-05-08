# frozen_string_literal: true

require_relative '../../lib/providers'
require_relative '../fixtures/mock_provider'

RSpec.describe Providers do
  describe '.define' do
    it 'defines a provider' do
      described_class.define(:mock_provider) do
        MockProvider.new
      end

      expect(Providers.all.count).to eq(1)
    end
  end
end
