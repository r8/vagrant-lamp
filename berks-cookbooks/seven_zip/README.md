[![Cookbook Version](http://img.shields.io/cookbook/v/seven_zip.svg)](https://supermarket.chef.io/cookbooks/seven_zip)
[![Build status](https://ci.appveyor.com/api/projects/status/y1lsnlkd2b3q6gfd/branch/master?svg=true)](https://ci.appveyor.com/project/ChefWindowsCookbooks65871/seven-zip/branch/master)

# seven_zip Cookbook
[7-Zip](http://www.7-zip.org/) is a file archiver with a high compression ratio. This cookbook installs the full 7-Zip suite of tools (GUI and CLI). This cookbook replaces the older [7-Zip cookbook](https://github.com/sneal/7-zip).

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
- Chef >= 13.0

## Cookbooks
- windows

# Attributes
## Optional

| Key | Type | Description | Default |
|-----|------|-------------|---------|
| `['seven_zip']['home']` | String | 7-Zip installation directory. | |
| `['seven_zip']['syspath']` | Boolean | If true, adds 7-Zip directory to system PATH environment variable. | |
| `['seven_zip']['default_extract_timeout']` | Integer | The default timeout for an extract operation in seconds. This can be overridden by a resource attribute. | `600` |

# Usage
## default

Add `seven_zip::default` to your run\_list which will download and install 7-Zip for the current Windows platform.

# Resource/Provider
## seven_zip_archive
Extracts a 7-Zip compatible archive (iso, zip, 7z, etc.) to the specified destination directory.

#### Actions
- `:extract` - Extract a 7-Zip compatible archive.

#### Attribute Parameters
- `path` - Name attribute. The destination to extract to.
- `source` - The file path to the archive to extract.
- `overwrite` - Defaults to false. If true, the destination files will be overwritten.
- `checksum` - The archive file checksum.
- `timeout` - The extract action timeout in seconds, defaults to `node['seven_zip']['default_extract_timeout']`.

#### Examples
Extract 7-Zip source files to `C:\seven_zip_source`.

```ruby
seven_zip_archive 'seven_zip_source' do
  path      'C:\seven_zip_source'
  source    'https://www.7-zip.org/a/7z1805-src.7z'
  overwrite true
  checksum  'd9acfcbbdcad078435586e00f73909358ed8d714d106e064dcba52fa73e75d83'
  timeout   30
end
```

## seven_zip_tool
Download and install 7-zip for the current Windows platform.

#### Actions
- `:install` - Installs 7-zip
- `:add_to_path` - Add 7-zip to the PATH

#### Attribute Parameters
- `package` - The name of the package.
- `path` - The install directory of 7-zip.
- `source` - The source URL of the 7-zip package.
- `checksum` - The 7-zip package checksum.

#### Examples
Install 7-zip in `C:\7z` and add it to the path.

```ruby
seven_zip_tool '7z 15.14 install' do
  action    [:install, :add_to_path]
  package   '7-Zip 15.14'
  path      'C:\7z'
  source    'http://www.7-zip.org/a/7z1514.msi'
  checksum  'eaf58e29941d8ca95045946949d75d9b5455fac167df979a7f8e4a6bf2d39680'
end
```

# Recipes
## default

Installs 7-Zip and adds it to your system PATH.

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
