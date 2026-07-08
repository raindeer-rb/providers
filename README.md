<p align="center"><img src="assets/dependency-expression.png" alt="Dependency Expression" height="262"/></p>

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

  def initialize(logger: Dependency)
    @logger = logger # => "logger" is injected.
  end
end
```

ℹ️ Requires [LowType](https://github.com/low-rb/lowtype) in order to use the `def(dependency: Dependency)` syntax.

### 2. Constructor Include

Or you may like to use the more traditional `include` syntax:

```ruby
class MyClass
  include Dependencies[:logger]

  def my_method
    @logger # => "@logger" is injected.
  end
end
```

This method hides and creates the constructor on your behalf.

### 3. Providers Hash

```ruby
logger = Providers[:my_provider]
```

See [API: Providers Hash](#providers-hash)

## Providers

Provide the dependency with:
```ruby
Providers.define(:logger) do
  Logger.new
end
```

Namespaced string keys are fine too:
```ruby
Providers.define('billing.payment_provider') do
  PaymentProvider.new
end
```

### Eager Loading

Eager load a provider by adding an `eager: true` keyword argument:
```ruby
Providers.define(:logger, eager: true) do
  Logger.new # Initialised immediately, not when the dependency is requested.
end
```

## Mixing dependency types

Providers lets you do something special; mix "manual" dependency injection (passing an arg to `new`) with "automatic" style dependency injection (via a framework):

```ruby
Providers.define(:automatic) do
  AutomaticDependency.new
end

# Define both a "manual" and "automatic" dependency:
class MyClass
  include LowType

  def initialize(manual:, automatic: Dependency)
    @manual = manual
    @automatic = automatic
  end
end

# Then initialize without the "automatic" arg:
MyClass.new(manual: ManualDependency.new)
```

The omitted `automatic` argument will automatically be injected from the `automatic` provider by Providers!

Now you get to have your manual dependency cake 🍰 and eat it too with an automatically injected dependency spoon 🥣

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
logger = Providers['namespace.my_provider']
```

Multiple dependencies:
```ruby
dependency_one, dependency_two = Providers[:provider_one, 'provider_two']
```

> [!note]
> **Bonus API:** You can use `Providers[]` in method params like `(config: Providers[:config])`, similar to a [Dependency Expression](#dependency-expression).

## Testing

Dependency Expressions and Constructor Include dependencies can easily be stubbed in a test just by passing them as arguments into a method.

### Providers Hash

When called inside a method body the `Providers[]` hash lookup takes more lines of code to stub in a test and is least "in the spirit" of dependency injection due to its hard-coded nature. However testing is still possible with the following techniques:

#### RSpec - `Providers[]` stub

```ruby
before do
  allow(Providers).to receive(:[]).and_call_original
  allow(Providers).to receive(:[]).with(:config).and_return(config)
end
```

#### RSpec - `Providers.define` with stubbed providers

```ruby
around do |example|
  original = Providers.all.dup
  example.run
ensure
  Providers.instance_variable_set(:@providers, original)
end

before do
  Providers.define(:config) { config }
end
```

## Examples

### Boot file

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

## Performance

Providers appears to be over 2x faster than Dry, but load time doesn't really matter at boot time when only a relatively small amount of dependencies are created once. Providers shines at runtime when creating many instances from dependencies again and again, however this increase in performance comes with the caveat that those dependencies should be considered immutable (to be thread-safe).

|                             | **Plain Ruby**     | **Dry container/auto_inject** | **Providers (lowtype)** |
|-----------------------------|--------------------|-------------------------------|-------------------------|
| **Dependency registration** |                    | ~2,229 ns                     | ~650 ns                 |
| **Manual DI**               | 3.76M i/s (266 ns) |                               |                         |
| **Automatic DI**            |                    | 628k i/s (1.59 µs)            | 1.74M i/s (575 ns)      |
| **Manual + Automatic DI**   |                    | 558k i/s (1.79 µs)            | 1.29M i/s (775 ns)      |

<details>
  <summary>Table Key</summary>

  - **DI:** Dependency Injection
  - **i/s:** Iterations per second
  - **µs:** Microseconds (1000 ns)
  - **ns:** Nanoseconds
</details>
<br />

`Providers.define` is roughly 3x faster per registration than `Dry::Container#register` (with `memoize: true`). However Providers has no `prepare`/`start`/`stop` lifecycle, Mutex locking or duplicate key checking. Provider definitions simply call other providers inside the `Provider.define` block via the `Providers[]` syntax. Also, this is a one-time cost during boot that is not that important.
 
For automatic dependencies via `include Dependencies[]` Providers replaces the `initialize` method, whereas `include Import[]` inserts a module into the ancestor chain with its own `initialize` method.

For automatic and manual dependencies (mixed) Providers `prepend`s an `initialize` method that calls `Providers[]` then `super`. This appears to be more efficient than a `.new` override, `**kwargs` slicing and the two chained `initialize` calls of AutoInject:
```ruby
class MyClass
  include Import['automatic']

  def initialize(manual:, **deps)
    @manual = manual
    super(**deps)
  end
end
```

**VS:**
```ruby
class MyClass
  include LowType

  def initialize(manual:, automatic: Dependency)
    @manual = manual
    @automatic = automatic
  end
end
```

Providers will take longer to load on class load/boot with mixed dependency injection as it has to parse the file via LowType, however this is a one-time performance cost.

## Installation

Add `gem 'providers'` to your Gemfile then:
```
bundle install
```
