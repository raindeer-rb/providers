# Providers

<a href="https://rubygems.org/gems/providers" title="Install gem"><img src="https://badge.fury.io/rb/providers.svg" alt="Gem version" height="18"></a> <a href="https://github.com/raindeer-rb/providers" title="GitHub"><img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" alt="GitHub repo" height="18"></a> <a href="https://codeberg.org/Iow/dependency" title="Codeberg"><img src="https://img.shields.io/badge/Codeberg-2185D0?style=for-the-badge&logo=Codeberg&logoColor=white" alt="Codeberg repo" height="18"></a>

Automatic Dependency Injection where you get to see and keep control of the constructor.

## Injectors

There are 3 ways to inject a dependency.

### 1. Dependency Expression

Place a `Dependency` expression as the default value of your dependency:

```ruby
class MyClass
  include LowType

  def initialize(my_dependency: Dependency)
    @my_dependency = my_dependency # => "my_dependency" is injected.
  end
end
```

ℹ️ This method requires [LowType](https://github.com/low-rb/lowtype) in order to use the `def(dependency: Dependency)` syntax.

### 2. Constructor Include

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

### 3. Providers Hash

```ruby
my_dependency = Providers[:my_provider]
```

ℹ️ Use this method only when necessary, it's the least "in the spirit" of dependency injection and takes more lines of code to stub in a test.

## Providers

Provide the dependency with:
```ruby
Providers.define(:my_dependency) do
  MyDependency.new
end
```

Namespaced string keys are fine too:
```ruby
Providers.define('billing.payment_provider') do
  PaymentProvider.new
end
```

## Mixing dependency types

Providers lets you do something special; mix "classical" dependency injection (passing an arg to `new`) with "provider" style dependency injection (via a framework):

```ruby
Providers.define(:provider_dependency) do
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

# Then call without "provider_dependency":
MyClass.new(classical_dependency: ClassicalDependency.new)
```

The omitted `provider_dependency` argument will automatically be injected from the `provider_dependency` provider by Providers!

Now you get to have your classical dependency cake 🍰 and eat it too with an automatically injected dependency spoon 🥣

## API

### Dependency Expression

A Dependency Expression defines the dependency to be injected, the provider that will inject it and the name of the local variable that it will be made available as.
The `def(dependency: Dependency)` syntax is an [Expression](https://github.com/raindeer-rb/expressions); an object composed via a query builder like interface.

ℹ️ The value after the pipe `|` becomes the provider key. When the provider key is omitted then the positional/keyword argument becomes the provider key.

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

Dependencies on multiple lines:
```ruby
def initialize(
  dependency_one: Dependency | :provider_one,
  dependency_two: Dependency | 'billing.provider_two',
)
  dependency_one # => Dependency injected from :provider_one.
  dependency_two # => Dependency injected from 'billing.provider_two'.
end
```

### Constructor Include

The `include` style syntax supports the same functionallity as the Dependency Expression syntax.

Multiple dependencies:
```ruby
class MyClass
  include Dependencies[:dependency_one, :dependency_two]
end
```

Dependency with differing dependency and provider key:
```ruby
class MyClass
  include Dependencies[dependency_one: :provider_one]
  # Instance variable @dependency_one is now available on instantiation.
end
```

Namespaced dependency:
```ruby
class MyClass
  include Dependencies['billing.provider_two']
  # Dependency injected without the namespace as @provider_two.
end
```

Separating dependencies on multiple lines:
```ruby
class MyClass
  include Dependencies[
    :dependency_one,
    'billing.provider_two',
    dependency_three: :provider_three,
    dependency_four: 'billing.provider_four',
    :five_dependencies_is_still_quite_reasonable_yeah,
  ]
end
```

### Providers Hash

```ruby
my_dependency = Providers['namespace.my_provider']
```

Multiple dependencies:
```ruby
dependency_one, dependency_two = Providers[:provider_one, 'provider_two']
```

## Examples

### Boot File

A boot sequence taken from the boot file of [Raindeer](https://github.com/raindeer-rb/raindeer):
```ruby
require 'low_event' # Defines 'low.event.pool' provider.

Providers.define('rain.router') do
  require_relative 'router/router'
  Rain::Router.new
end

Providers.define('rain.matrix') do
  require_relative 'matrix/matrix'
  Rain::Matrix.new(event_pool: Providers['low.event.pool'])
end

Providers.define('low.loop') do
  require 'low_loop'
  LowLoop.new(router: Providers['rain.router'], renderer: Providers['rain.matrix'])
end
```

## Installation

Add `gem 'providers'` to your Gemfile then:
```
bundle install
```
