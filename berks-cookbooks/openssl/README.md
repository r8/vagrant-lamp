# OpenSSL Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/openssl.svg?branch=master)](http://travis-ci.org/chef-cookbooks/openssl) [![Cookbook Version](https://img.shields.io/cookbook/v/openssl.svg)](https://supermarket.chef.io/cookbooks/openssl)

This cookbook provides tools for working with the Ruby OpenSSL library. It includes:

- A library method to generate secure random passwords in recipes, using the Ruby SecureRandom library.
- A resource for generating RSA private keys.
- A resource for generating RSA public keys.
- A resource for generating x509 certificates.
- A resource for generating dhparam.pem files.
- An attribute-driven recipe for upgrading OpenSSL packages.

## Platforms

- Debian / Ubuntu derivatives
- Fedora
- FreeBSD
- macOS
- openSUSE / SUSE Linux Enterprises
- RHEL/CentOS/Scientific/Amazon/Oracle
- Solaris

## Chef

- Chef 12.7+

## Cookbooks

- none

## Attributes

- `node['openssl']['restart_services']` - An array of service resources that depend on the openssl packages. This array is empty by default, as Chef has no reasonable way to detect which applications or services are compiled against these packages. _Note_ Each service listed in this array should represent a "`service`" resource specified in the recipes of the node's run list.

## Recipes

### upgrade

The upgrade recipe iterates over the list of packages in the `node['openssl']['packages']` attribute, and manages them with the `:upgrade` action. Each package will send a `:restart` notification to service resources named in the `node['openssl']['restart_services']` attribute.

#### Example Usage

In this example, assume the node is running the `stats_collector` daemon, which depends on the openssl library. Imagine that a new openssl vulnerability has been disclosed, and the operating system vendor has released an update to openssl to address this vulnerability. In order to protect the node, an administrator crafts this recipe:

```ruby
node.default['openssl']['restart_services'] = ['stats_collector']

# other recipe code here...
service 'stats_collector' do
  action [:enable, :start]
end

include_recipe 'openssl::upgrade'
```

When executed, this recipe will ensure that openssl is upgraded to the latest version, and that the `stats_collector` service is restarted to pick up the latest security fixes released in the openssl package.

## Libraries

There are two mixins packaged with this cookbook.

### random_password (`OpenSSLCookbook::RandomPassword`)

The `RandomPassword` mixin can be used to generate secure random passwords in Chef cookbooks, usually for assignment to a variable or an attribute. `random_password` uses Ruby's SecureRandom library and is customizable.

#### Example Usage

```ruby
Chef::Recipe.send(:include, OpenSSLCookbook::RandomPassword)
node.normal['my_secure_attribute'] = random_password
node.normal_unless['my_secure_attribute'] = random_password
node.normal['my_secure_attribute'] = random_password(length: 50)
node.normal['my_secure_attribute'] = random_password(length: 50, mode: :base64)
node.normal['my_secure_attribute'] = random_password(length: 50, mode: :base64, encoding: 'ASCII')
```

Note that node attributes are widely accessible. Storing unencrypted passwords in node attributes, as in this example, carries risk.

## Resources

### openssl_x509

This resource generates self-signed, PEM-formatted x509 certificates. If no existing key is specified, the resource will automatically generate a passwordless key with the certificate.

#### Properties

Name               | Type                         | Description
------------------ | ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
`path`             | String (Optional)            | Optional path to write the file to if you'd like to specify it here instead of in the resource name
`common_name`      | String (Required)            | Value for the `CN` certificate field.
`org`              | String (Required)            | Value for the `O` certificate field.
`org_unit`         | String (Required)            | Value for the `OU` certificate field.
`city`             | String (Optional)            | Value for the `L` certificate field.
`state`            | String (Optional)            | Value for the `ST` certificate field.
`country`          | String (Required)            | Value for the `C` ssl field.
`expire`           | Integer (Optional)           | Value representing the number of days from _now_ through which the issued certificate cert will remain valid. The certificate will expire after this period.
`subject_alt_name` | Array (Optional)             | Array of _Subject Alternative Name_ entries, in format `DNS:example.com` or `IP:1.2.3.4` _Default: empty_
`key_file`         | String (Optional)            | The path to a certificate key file on the filesystem. If the `key_file` attribute is specified, the resource will attempt to source a key from this location. If no key file is found, the resource will generate a new key file at this location. If the `key_file` attribute is not specified, the resource will generate a key file in the same directory as the generated certificate, with the same name as the generated certificate.
`key_pass`         | String (Optional)            | The passphrase for an existing key's passphrase
`key_length`       | Integer (Optional)           | The desired Bit Length of the generated key. _Default: 2048_
`owner`            | String (optional)            | The owner of all files created by the resource. _Default: "root"_
`group`            | String (optional)            | The group of all files created by the resource. _Default: "root"_
`mode`             | String or Integer (Optional) | The permission mode of all files created by the resource. _Default: "0400"_

#### Example Usage

In this example, an administrator wishes to create a self-signed x509 certificate for use with a web server. In order to create the certificate, the administrator crafts this recipe:

```ruby
openssl_x509 '/etc/httpd/ssl/mycert.pem' do
  common_name 'www.f00bar.com'
  org 'Foo Bar'
  org_unit 'Lab'
  country 'US'
end
```

When executed, this recipe will generate a key certificate at `/etc/httpd/ssl/mycert.key`. It will then use that key to generate a new certificate file at `/etc/httpd/ssl/mycert.pem`.

### openssl_dhparam

This resource generates dhparam.pem files. If a valid dhparam.pem file is found at the specified location, no new file will be created. If a file is found at the specified location but it is not a valid dhparam file, it will be overwritten.

#### Properties

Name         | Type                         | Description
------------ | ---------------------------- | ---------------------------------------------------------------------------------------------------
`path`       | String (Optional)            | Optional path to write the file to if you'd like to specify it here instead of in the resource name
`key_length` | Integer (Optional)           | The desired Bit Length of the generated key. _Default: 2048_
`generator`  | Integer (Optional)           | The desired Diffie-Hellmann generator. Can be _2_ or _5_.
`owner`      | String (optional)            | The owner of all files created by the resource. _Default: "root"_
`group`      | String (optional)            | The group of all files created by the resource. _Default: "root"_
`mode`       | String or Integer (Optional) | The permission mode of all files created by the resource. _Default: "0640"_

#### Example Usage

In this example, an administrator wishes to create a dhparam.pem file for use with a web server. In order to create the .pem file, the administrator crafts this recipe:

```ruby
openssl_dhparam '/etc/httpd/ssl/dhparam.pem' do
  key_length 2048
  generator 2
end
```

When executed, this recipe will generate a dhparam file at `/etc/httpd/ssl/dhparam.pem`.

### openssl_rsa_private_key

This resource generates rsa private key files. If a valid rsa key file can be opened at the specified location, no new file will be created. If the RSA key file cannot be opened, either because it does not exist or because the password to the RSA key file does not match the password in the recipe, it will be overwritten.

Note: This resource was renamed from openssl_rsa_key to openssl_rsa_private_key. The legacy name will continue to function, but cookbook code should be updated for the new resource name.

#### Properties

Name         | Type                         | Description
------------ | ---------------------------- | -----------------------------------------------------------------------------------------------------------------------------------
`path`       | String (Optional)            | Optional path to write the file to if you'd like to specify it here instead of in the resource name
`key_length` | Integer (Optional)           | The desired Bit Length of the generated key. _Default: 2048_
`key_cipher` | String (Optional)            | The designed cipher to use when generating your key. Run `openssl list-cipher-algorithms` to see available options. _Default: des3_
`key_pass`   | String (Optional)            | The desired passphrase for the key.
`owner`      | String (optional)            | The owner of all files created by the resource. _Default: "root"_
`group`      | String (optional)            | The group of all files created by the resource. _Default: "root or wheel depending on platform"_
`mode`       | String or Integer (Optional) | The permission mode of all files created by the resource. _Default: "0640"_
`force`      | true/false (Optional)        | Force creating the key even if the existing key exists. _Default: false_

#### Example Usage

In this example, an administrator wishes to create a new RSA private key file in order to generate other certificates and public keys. In order to create the key file, the administrator crafts this recipe:

```ruby
openssl_rsa_private_key '/etc/httpd/ssl/server.key' do
  key_length 2048
end
```

When executed, this recipe will generate a passwordless RSA key file at `/etc/httpd/ssl/server.key`.

### openssl_rsa_public_key

This resource generates rsa public key files given a private key.

#### Properties

Name                  | Type                                              | Description
--------------------- | ------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------
`path`                | String (Optional)                                 | Optional path to write the file to if you'd like to specify it here instead of in the resource name
`private_key_path`    | String (Required unless private_key_content used) | The path to the private key to generate the public key from
`private_key_content` | String (Required unless private_key_path used)    | The content of the private key including new lines. Used if you don't want to write a private key to disk and use `private_key_path`.
`private_key_pass`    | String (Optional)                                 | The passphrase of the provided private key
`owner`               | String (optional)                                 | The owner of all files created by the resource. _Default: "root"_
`group`               | String (optional)                                 | The group of all files created by the resource. _Default: "root or wheel depending on platform"_
`mode`                | String or Integer (Optional)                      | The permission mode of all files created by the resource. _Default: "0640"_

**Note**: To use `private_key_content` the private key string must be properly formatted including new lines. The easiest way to get the right string is to run the following from irb (/opt/chefdk/embedded/bin/irb from ChefDK)

```ruby
File.read('/foo/bar/private.pem')
```

#### Example Usage

```ruby
openssl_rsa_public_key '/etc/foo/something.pub' do
  priv_key_path '/etc/foo/something.pem'
end
```

## Maintainers

This cookbook is maintained by Chef's Community Cookbook Engineering team. Our goal is to improve cookbook quality and to aid the community in contributing to cookbooks. To learn more about our team, process, and design goals see our [team documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/COOKBOOK_TEAM.MD). To learn more about contributing to cookbooks like this see our [contributing documentation](https://github.com/chef-cookbooks/community_cookbook_documentation/blob/master/CONTRIBUTING.MD), or if you have general questions about this cookbook come chat with us in #cookbok-engineering on the [Chef Community Slack](http://community-slack.chef.io/)

## License

**Copyright:** 2009-2017, Chef Software, Inc.

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
