<a href="https://rubygems.org/gems/providers" title="Install gem"><img src="https://badge.fury.io/rb/providers.svg" alt="Gem version" height="18"></a> <a href="https://github.com/raindeer-rb/providers" title="GitHub"><img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" alt="GitHub repo" height="18"></a> <a href="https://codeberg.org/Iow/dependency" title="Codeberg"><img src="https://img.shields.io/badge/Codeberg-2185D0?style=for-the-badge&logo=Codeberg&logoColor=white" alt="Codeberg repo" height="18"></a>

# Providers

Automatic Dependency Injection where you get to see and keep control of the constructor.

## Injection

Inject a dependency:

```ruby
class MyClass
  include LowType

  def initialize(my_dependency: Dependency)
    @my_dependency = my_dependency # => "my_dependency" is injected.
  end
end
```

ℹ️ The above example requires [LowType](https://github.com/raindeer-rb/low_type) in order to use the `def(dependency: Dependency)` syntax.

Or you may like to use the more traditional `include` syntax:

```ruby
class MyClass
  include Dependencies[:my_dependency]

  def my_method
    @my_dependency # => "@my_dependency" is injected.
  end
end
```

This method hides and creates the constructor on your behalf.

## Providers

Provide the dependency with:
```ruby
Dependencies.provide(:my_dependency) do
  MyDependency.new
end
```

Namespaced string keys are fine too:
```ruby
Dependencies.provide('billing.payment_provider') do
  PaymentProvider.new
end
```

## Mixing dependency types

Providers lets you do something special; mix "classical" dependency injection (passing an arg to `new`) with "provider" style dependency injection (populating an arg via a framework):

```ruby
Dependencies.provide(:provider_dependency) do
  ProviderDependency.new
end

# Define both a "provider" and a "classical" dependency:
class MyClass
  include LowType

  def initialize(provider_dependency: Dependency, classical_dependency:)
    @provider_dependency = provider_dependency
    @classical_dependency = classical_dependency
  end
end

# Now bring it all together by calling:
MyClass.new(classical_dependency: ClassicalDependency.new)
```

The `provider_dependency` argument will automatically be injected by Providers!

Now you get to have your classical dependency cake 🍰 and eat it too with an automatically injected dependency spoon 🥣

## API

### Dependency Expression

A Dependency Expression defines the dependency to be injected, the provider that will inject it and the name of the local variable that it will be made available as.

The `def(dependency: Dependency)` syntax is an [Expression](https://github.com/raindeer-rb/expressions); an object composed via a query builder like interface. It follows the same logically consistent rules as other expressions in the Expressions API.

To define a provider with a different name to that of the local variable do:
```ruby
def initialize(dependency_one: Dependency | :provider_one)
  dependency_one # => Dependency injected from :provider_one.
end
```

For providers with string keys do:
```ruby
def initialize(dependency_two: Dependency | 'billing.provider_two')
  dependency_two # => Dependency injected from 'billing.provider_two'.
end
```

ℹ️ The value after the pipe `|` becomes the provider key. When the provider key is omitted then the name of the positional/keyword argument is substituted as the provider key instead.

### Traditional Dependency

The `include` style syntax supports the same functionallity as the dependency expression syntax.

Multiple dependencies:
```ruby
class MyClass
  include Dependencies[:dependency_one, :dependency_two]
end
```

Dependencies with differing local variable/provider keys:
```ruby
class MyClass
  include Dependencies[dependency_one: :provider_one, dependency_two: 'billing.provider_two']
  # Instance variables @dependency_one and @dependency_two are now available.
end
```

ℹ️ Provider keys with a namespace such as `'billing.provider_two'` will have their dependency injected without the namespace; the variable will just be `@provider_two`.

Separating many dependencies on multiple lines:
```ruby
class MyClass
  include Dependencies[
    dependency_one: :provider_one,
    dependency_two: 'billing.provider_two',
    :dependency_three,
    :four_dependencies_is_still_quite_reasonable_yeah,
  ]
end
```

## Installation

Add `gem 'providers'` to your Gemfile then:
```
bundle install
```
