# frozen_string_literal: true

require_relative '../../lib/providers'
require_relative '../../spec/fixtures/mock_dependency_class'
require_relative '../../spec/fixtures/mock_dependency_expression'

RSpec.describe 'LowType Dependency' do
  before do
    Providers.define(provider_name) do
      'Automatic'
    end
  end

  after do
    Providers.clear
  end

  describe 'initialize(automatic: Dependency)' do
    let(:subject) { MockDependencyClass.new(manual: 'Manual') }
    let(:provider_name) { :automatic }

    it 'injects dependency of same name as variable' do
      expect(subject).to have_attributes(manual: 'Manual', automatic: 'Automatic')
    end
  end

  describe 'initialize(automatic: Dependency | :different_name)' do
    let(:subject) { MockDependencyExpression.new(manual: 'Manual') }
    let(:provider_name) { :different_name }

    it 'injects dependency of different name to variable' do
      expect(subject).to have_attributes(manual: 'Manual', automatic: 'Automatic')
    end
  end
end
