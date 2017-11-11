# Poise

[![Build Status](https://img.shields.io/travis/poise/poise.svg)](https://travis-ci.org/poise/poise)
[![Gem Version](https://img.shields.io/gem/v/poise.svg)](https://rubygems.org/gems/poise)
[![Cookbook Version](https://img.shields.io/cookbook/v/poise.svg)](https://supermarket.chef.io/cookbooks/poise)
[![Coverage](https://img.shields.io/codecov/c/github/poise/poise.svg)](https://codecov.io/github/poise/poise)
[![Gemnasium](https://img.shields.io/gemnasium/poise/poise.svg)](https://gemnasium.com/poise/poise)
[![License](https://img.shields.io/badge/license-Apache_2-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

## What is Poise?

The poise cookbook is a set of libraries for writing reusable cookbooks. It
provides helpers for common patterns and a standard structure to make it easier to create flexible cookbooks.

## Writing your first resource

Rather than LWRPs, Poise promotes the idea of using normal, or "heavy weight"
resources, while including helpers to reduce much of boilerplate needed for this. Each resource goes in its own file under `libraries/` named to match
the resource, which is in turn based on the class name. This means that the file `libraries/my_app.rb` would contain `Chef::Resource::MyApp` which maps to the resource `my_app`.

An example of a simple shell to start from:

```ruby
require 'poise'
require 'chef/resource'
require 'chef/provider'

module MyApp
  class Resource < Chef::Resource
    include Poise
    provides(:my_app)
    actions(:enable)

    attribute(:path, kind_of: String)
    # Other attribute definitions.
  end

  class Provider < Chef::Provider
    include Poise
    provides(:my_app)

    def action_enable
      notifying_block do
        ... # Normal Chef recipe code goes here
      end
    end
  end
end
```

Starting from the top, first we require the libraries we will be using. Then we
create a module to hold our resource and provider. If your cookbook declares
multiple resources and/or providers, you might want additional nesting here.
Then we declare the resource class, which inherits from `Chef::Resource`. This
is similar to the `resources/` file in an LWRP, and a similar DSL can be used.
We then include the `Poise` mixin to load our helpers, and then call
`provides(:my_app)` to tell Chef this class will implement the `my_app`
resource. Then we use the familiar DSL, though with a few additions we'll cover
later.

Then we declare the provider class, again similar to the `providers/` file in an
LWRP. We include the `Poise` mixin again to get access to all the helpers and
call `provides()` to tell Chef what provider this is. Rather than use the
`action :enable do ... end` DSL from LWRPs, we just define the action method
directly. The implementation of action comes from a block of recipe code
wrapped with `notifying_block` to capture changes in much the same way as
`use_inline_resources`, see below for more information about all the features of
`notifying_block`.

We can then use this resource like any other Chef resource:

```ruby
my_app 'one' do
  path '/tmp'
end
```

## Helpers

While not exposed as a specific method, Poise will automatically set the
`resource_name` based on the class name.

### Notifying Block

As mentioned above, `notifying_block` is similar to `use_inline_resources` in LWRPs. Any Chef resource created inside the block will be converged in a sub-context and if any have updated it will trigger notifications on the current resource. Unlike `use_inline_resources`, resources inside the sub-context can still see resources outside of it, with lookups propagating up sub-contexts until a match is found. Also any delayed notifications are scheduled to run at the end of the main converge cycle, instead of the end of this inner converge.

This can be used to write action methods using the normal Chef recipe DSL, while still offering more flexibility through subclassing and other forms of code reuse.

### Include Recipe

In keeping with `notifying_block` to implement action methods using the Chef DSL, Poise adds an `include_recipe` helper to match the method of the same name in recipes. This will load and converge the requested recipe.

### Resource DSL

To make writing resource classes easier, Poise exposes a DSL similar to LWRPs for defining actions and attributes. Both `actions` and
`default_action` are just like in LWRPs, though `default_action` is rarely needed as the first action becomes the default. `attribute` is also available just like in LWRPs, but with some enhancements noted below.

One notable difference over the standard DSL method is that Poise attributes
can take a block argument.

#### Template Content

A common pattern with resources is to allow passing either a template filename or raw file content to be used in a configuration file. Poise exposes a new attribute flag to help with this behavior:

```ruby
attribute(:name, template: true)
```

This creates four methods on the class, `name_source`, `name_cookbook`,
`name_content`, and `name_options`. If the name is set to `''`, no prefix is applied to the function names. The content method can be set directly, but if not set and source is set, then it will render the template and return it as a string. Default values can also be set for any of these:

```ruby
attribute(:name, template: true, default_source: 'app.cfg.erb',
          default_options: {host: 'localhost'})
```

As an example, you can replace this:

```ruby
if new_resource.source
  template new_resource.path do
    source new_resource.source
    owner 'app'
    group 'app'
    variables new_resource.options
  end
else
  file new_resource.path do
    content new_resource.content
    owner 'app'
    group 'app'
  end
end
```

with simply:

```ruby
file new_resource.path do
  content new_resource.content
  owner 'app'
  group 'app'
end
```

As the content method returns the rendered template as a string, this can also
be useful within other templates to build from partials.

#### Lazy Initializers

One issue with Poise-style resources is that when the class definition is executed, Chef hasn't loaded very far so things like the node object are not
yet available. This means setting defaults based on node attributes does not work directly:

```ruby
attribute(:path, default: node['myapp']['path'])
...
NameError: undefined local variable or method 'node'
```

To work around this, Poise extends the idea of lazy initializers from Chef recipes to work with resource definitions as well:

```ruby
attribute(:path, default: lazy { node['myapp']['path'] })
```

These initializers are run in the context of the resource object, allowing
complex default logic to be moved to a method if desired:

```ruby
attribute(:path, default: lazy { my_default_path })

def my_default_path
  ...
end
```

#### Option Collector

Another common pattern with resources is to need a set of key/value pairs for
configuration data or options. This can done with a simple Hash, but an option collector attribute can offer a nicer syntax:

```ruby
attribute(:mydata, option_collector: true)
...

my_app 'name' do
  mydata do
    key1 'value1'
    key2 'value2'
  end
end
```

This will be converted to `{key1: 'value1', key2: 'value2'}`. You can also pass a Hash to an option collector attribute just as you would with a normal attribute.

## Debugging Poise

Poise has its own extra-verbose level of debug logging that can be enabled in
three different ways. You can either set the environment variable `$POISE_DEBUG`,
set a node attribute `node['POISE_DEBUG']`, or touch the file `/POISE_DEBUG`.
You will see a log message `Extra verbose logging enabled` at the start of the
run to confirm Poise debugging has been enabled. Make sure you also set Chef's
log level to `debug`, usually via `-l debug` on the command line.

## Upgrading from Poise 1.x

The biggest change when upgrading from Poise 1.0 is that the mixin is no longer
loaded automatically. You must add `require 'poise'` to your code is you want to
load it, as you would with normal Ruby code outside of Chef. It is also highly
recommended to add `provides(:name)` calls to your resources and providers, this
will be required in Chef 13 and will display a deprecation warning if you do
not. This also means you can move your code out of the `Chef` module namespace
and instead declare it in your own namespace. An example of this is shown above.

## Sponsors

The Poise test server infrastructure is generously sponsored by [Rackspace](https://rackspace.com/). Thanks Rackspace!

## License

Copyright 2013-2016, Noah Kantrowitz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
