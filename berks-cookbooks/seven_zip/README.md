[![Cookbook Version](http://img.shields.io/cookbook/v/seven_zip.svg)](https://supermarket.chef.io/cookbooks/seven_zip)
[![Build status](https://ci.appveyor.com/api/projects/status/y1lsnlkd2b3q6gfd/branch/master?svg=true)](https://ci.appveyor.com/project/ChefWindowsCookbooks65871/seven-zip/branch/master)

# seven_zip Cookbook
[7-Zip](http://www.7-zip.org/) is a file archiver with a high compression ratio. This cookbook installs the full 7-zip suite of tools (GUI and CLI). This cookbook replaces the older [7-zip cookbook](https://github.com/sneal/7-zip).

# Requirements
## Platforms
- Windows XP
- Windows Vista
- Windows 7
- Windows 8, 8.1
- Windows 10
- Windows Server 2003 R2
- Windows Server 2008 (R1, R2)
- Windows Server 2012 (R1, R2)

## Chef
- Chef >= 11.6

## Cookbooks
- windows

# Attributes
## Optional
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><code>['seven_zip']['home']</code></td>
    <td>String</td>
    <td>7-Zip installation directory.</td>
    <td></td>
  </tr>
  <tr>
    <td><code>['seven_zip']['syspath']</code></td>
    <td>Boolean</td>
    <td>If true, adds 7-zip directory to system PATH environment variable.</td>
    <td></td>
  </tr>
  <tr>
    <td><code>['seven_zip']['default_extract_timeout']</code></td>
    <td>Integer</td>
    <td>The default timeout for an extract operation in seconds. This can be overridden by a resource attribute.</td>
    <td>600</td>
  </tr>
</table>

# Usage
## default

Add `seven_zip::default` to your run\_list which will download and install 7-zip for the current Windows platform. 

# Resource/Provider
## seven_zip_archive
Extracts a 7-zip compatible archive (iso, zip, 7z etc) to the specified destination directory.

#### Actions
- `:extract` - Extract a 7-zip compatible archive

#### Attribute Parameters
- `path` - Name attribute. The destination to extract to.
- `source` - The file path to the archive to extract.
- `overwrite` - Defaults to false. If true, the destination files will be overwritten.
- `checksum` - The archive file checksum.
- `timeout` - The extract action timeout in seconds, defaults to `node['seven_zip']['default_extract_timeout']`.

#### Examples
Extract 7-zip source files to `C:\seven_zip_source`.

```ruby
seven_zip_archive 'seven_zip_source' do
  path      'C:\seven_zip_source'
  source    'http://www.7-zip.org/a/7z1514-src.7z'
  overwrite true
  checksum  '3713aed72728eae8f6649e4803eba0b3676785200c76df6269034c520df4bbd5'
  timeout   30
end
```

# Recipes
## default

Installs 7-zip and adds it to your system PATH.

# License & Authors
- Author:: Seth Chisamore (<schisamo@chef.io>)
- Author:: Shawn Neal (<sneal@sneal.net>)

```text
Copyright:: 2011-2016, Chef Software, Inc.

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
