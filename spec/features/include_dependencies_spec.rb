# frozen_string_literal: true

require_relative '../../lib/dependencies'
require_relative '../fixtures/mock_dependencies'
require_relative '../fixtures/mock_provider'

RSpec.describe 'include Dependencies[:dependency]' do
  after do
    Low::Providers.clear
  end

  context 'with a single dependency' do
    let(:subject) { IncludeDependency.new }

    before { Dependencies.provide(:provider_one) { MockProvider.new } }

    it 'injects dependency' do
      expect(subject.provider_one).to be_instance_of(MockProvider)
    end

    context 'with a string key dependency' do
      let(:subject) { IncludeStringDependency.new }

      before { Dependencies.provide('provider_one') { MockProvider.new } }

      it 'injects dependency' do
        expect(subject.provider_one).to be_instance_of(MockProvider)
      end
    end

    context 'with a namespaced string key dependency' do
      let(:subject) { IncludeNamespacedStringDependency.new }

      before { Dependencies.provide('namespace.provider_one') { MockProvider.new } }

      it 'injects dependency without namespace' do
        expect(subject.provider_one).to be_instance_of(MockProvider)
      end
    end
  end

  context 'with multiple dependencies' do
    let(:subject) { IncludeDependencies.new }

    before do
      Dependencies.provide(:provider_one) { MockProvider.new }
      Dependencies.provide(:provider_two) { MockProvider.new }
    end

    it 'injects multiple dependencies' do
      expect(subject.provider_one).to be_instance_of(MockProvider)
      expect(subject.provider_two).to be_instance_of(MockProvider)
    end

    context 'with string key dependencies' do
      let(:subject) { IncludeStringDependencies.new }

      before do
        Dependencies.provide('provider_one') { MockProvider.new }
        Dependencies.provide('provider_two') { MockProvider.new }
      end

      it 'injects dependencies' do
        expect(subject.provider_one).to be_instance_of(MockProvider)
        expect(subject.provider_two).to be_instance_of(MockProvider)
      end
    end

    context 'with namespaced string key dependencies' do
      let(:subject) { IncludeNamespacedStringDependencies.new }

      before do
        Dependencies.provide('namespace.provider_one') { MockProvider.new }
        Dependencies.provide('namespace.provider_two') { MockProvider.new }
      end

      it 'injects dependencies without namespace' do
        expect(subject.provider_one).to be_instance_of(MockProvider)
        expect(subject.provider_two).to be_instance_of(MockProvider)
      end
    end
  end
end
