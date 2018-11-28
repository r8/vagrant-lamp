# mingw Cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/mingw.svg)][cookbook] [![Build Status](http://img.shields.io/travis/chef-cookbooks/mingw.svg?branch=master)][travis]

Installs a mingw/msys based compiler tools chain on windows. This is required for compiling C software from source.

## Requirements

### Platforms

- Windows

### Chef

- Chef 12.5+

### Cookbooks

- seven_zip

## Usage

Add this cookbook as a dependency to your cookbook in its `metadata.rb` and include the default recipe in one of your recipes.

```ruby
# metadata.rb
depends 'mingw'
```

```ruby
# your recipe.rb
include_recipe 'mingw::default'
```

Use the `msys2_package` resource in any recipe to fetch msys2 based packages. Use the `mingw_get` resource in any recipe to fetch mingw packages. Use the `mingw_tdm_gcc` resource to fetch a version of the TDM GCC compiler.

By default, you should prefer the msys2 packages as they are newer and better supported. C/C++ compilers on windows use various different exception formats and you need to pick the right one for your task. In the 32-bit world, you have SJLJ (set-jump/long-jump) based exception handling and DWARF-2 (shortened to DW2) based exception handling. SJLJ produces code that can happily throw exceptions across stack frames of code compiled by MSVC. DW2 involves more extensive metadata but produces code that cannot unwind MSVC generated stack-frames - hence you need to ensure that you don't have any code that throws across a "system call". Certain languages and runtimes have specific requirements as to the exception format supported. As an example, if you are building code for Rust, you will probably need a modern gcc from msys2 with DW2 support as that's what the panic/exception formatter in Rust depends on. In a 64-bit world, you may still use SJLJ but compilers all commonly support SEH (structured exception handling).

Of course, to further complicate matters, different versions of different compilers support different exception handling. The default compilers that come with mingw_get are 32-bit only compilers and support DW2\. The TDM compilers come in 3 flavors: a 32-bit only version with SJLJ support, a 32-bit only version with DW2 support and a "multilib" compiler which supports only SJLJ in 32-bit mode but can produce 64-bit SEH code. The standard library support varies drastically between these various compiler flavors (even within the same version). In msys2, you can install a mingw-w64 based compilers for either 32-bit DW2 support or 64-bit SEH support. If all this hurts your brain, I can only apologize.

## Resources

### msys2_package

- ':install' - Installs an msys2 package using pacman.
- ':remove' - Uninstalls any existing msys2 package.
- ':upgrade' - Upgrades the specified package using pacman.

All options also automatically attempt to install a 64-bit based msys2 base file system at the root path specified. Note that you probably won't need a "32-bit" msys2 unless you are actually on a 32-bit only platform. You can still install both 32 and 64-bit compilers and libraries in a 64-bit msys2 base file system.

#### Attributes

- `node['msys2']['url']` - overrides the url from which to download the package.
- `node['msys2']['checksum']` - overrides the checksum used to verify the downloaded package.

#### Parameters

- `package` - An msys2 pacman package (or meta-package) to fetch and install. You may use a legal package wild-card pattern here if you are installing. This is the name attribute.
- `root` - The root directory where msys2 tools will be installed. This directory must not contain any spaces in order to pacify old posix tools and most Makefiles.

#### Examples

To get the core msys2 developer tools in `C:\msys2`

```ruby
msys2_package 'base-devel' do
  root 'C:\msys2'
end
```

### mingw_get

#### Actions

- `:install` - Installs a mingw package from sourceforge using mingw-get.exe.
- `:remove` - Uninstalls a mingw package.
- `:upgrade` - Upgrades a mingw package (even to a lower version).

#### Parameters

- `package` - A mingw-get package (or meta-package) to fetch and install. You may use a legal package wild-card pattern here if you are installing. This is the name attribute.
- `root` - The root directory where msys and mingw tools will be installed. This directory must not contain any spaces in order to pacify old posix tools and most Makefiles.

#### Examples

To get the core msys developer tools in `C:\mingw32`

```ruby
mingw_get 'msys-base=2013072300-msys-bin.meta' do
  root 'C:\mingw32'
end
```

### mingw_tdm_gcc

#### Actions

- `:install` - Installs the TDM compiler toolchain at the given path. This only gives you a compiler. If you need any support tooling such as make/grep/awk/bash etc., see `mingw_get`.

#### Parameters

- `flavor` - Either `:sjlj_32` or `:seh_sjlj_64`. TDM-64 is a 32/64-bit multi-lib "cross-compiler" toolchain that builds 64-bit by default. It uses structured exception handling (SEH) in 64-bit code and setjump-longjump exception handling (SJLJ) in 32-bit code. TDM-32 only builds 32-bit binaries and uses SJLJ.
- `root` - The root directory where compiler tools and runtime will be installed. This directory must not contain any spaces in order to pacify old posix tools and most Makefiles.
- `version` - The version of the compiler to fetch and install. This is the name attribute. Currently, '5.1.0' is supported.

#### Examples

To get the 32-bit TDM GCC compiler in `C:\mingw32`

```ruby
mingw_tdm_gcc '5.1.0' do
  flavor :sjlj_32
  root 'C:\mingw32'
end
```

## License & Authors

**Author:** Cookbook Engineering Team ([cookbooks@chef.io](mailto:cookbooks@chef.io))

**Copyright:** 2009-2016, Chef Software, Inc.

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

[cookbook]: https://supermarket.chef.io/cookbooks/mingw
[travis]: http://travis-ci.org/chef-cookbooks/mingw
