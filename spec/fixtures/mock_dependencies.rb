# frozen_string_literal: true

require_relative '../../lib/dependencies'

# Single.

class IncludeDependency
  include Dependencies[:provider_one]
end

class IncludeStringDependency
  include Dependencies['provider_one']
end

class IncludeNamespacedStringDependency
  include Dependencies['namespace.provider_one']
end

class IncludeDependencyWithProvider
  include Dependencies[dependency_one: :provider_one]
end

class IncludeDependencyWithStringProvider
  include Dependencies[dependency_one: 'provider_one']
end

class IncludeDependencyWithNamespacedStringProvider
  include Dependencies[dependency_one: 'namespace.provider_one']
end

# Multiple.

class IncludeDependencies
  include Dependencies[:provider_one, :provider_two]
end

class IncludeStringDependencies
  include Dependencies['provider_one', 'provider_two']
end

class IncludeNamespacedStringDependencies
  include Dependencies['namespace.provider_one', 'namespace.provider_two']
end

class IncludeDependenciesWithProviders
  include Dependencies[dependency_one: :provider_one, dependency_two: :provider_two]
end

class IncludeDependenciesWithStringProviders
  include Dependencies[dependency_one: 'provider_one', dependency_two: 'provider_two']
end

class IncludeDependenciesWithNamespacedStringProviders
  include Dependencies[dependency_one: 'namespace.provider_one', dependency_two: 'namespace.provider_two']
end
