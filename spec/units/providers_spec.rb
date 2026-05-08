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

  describe '.[]' do
    before do
      described_class.define(:provider_one) { MockProvider.new }
    end

    it 'returns a dependency' do
      expect(described_class[:provider_one]).to be_instance_of(MockProvider)
    end

    context 'with multiple providers' do
      before do
        described_class.define('provider_two') { MockProvider.new }
      end

      it 'returns multiple dependencies' do
        expect(described_class[:provider_one, 'provider_two']).to match_array([instance_of(MockProvider), instance_of(MockProvider)])
      end
    end
  end
end
