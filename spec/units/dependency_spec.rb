# frozen_string_literal: true

require_relative '../../lib/low/dependency'
require_relative '../fixtures/mock_provider'

RSpec.describe ::Low::Dependency do
  describe '| union value' do
    context 'with a symbol value' do
      let(:dependency_expression) { ::Low::Dependency | :symbol_provider }

      it 'defines a provider key' do
        expect(dependency_expression.provider_key).to eq(:symbol_provider)
      end

      it 'defines a var name' do
        expect(dependency_expression.var_name).to eq(:symbol_provider)
      end
    end

    context 'with a string value' do
      let(:dependency_expression) { ::Low::Dependency | 'namespace.string_provider' }

      it 'defines a provider key' do
        expect(dependency_expression.provider_key).to eq('namespace.string_provider')
      end

      it 'defines a var name' do
        expect(dependency_expression.var_name).to eq('string_provider')
      end
    end
  end
end
