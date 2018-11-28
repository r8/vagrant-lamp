# openssl Cookbook CHANGELOG

This file is used to list changes made in each version of the openssl cookbook.

## 8.5.5 (2018-09-04)

All resources in this cookbook are now built into Chef 14.4+. When Chef 15.4 is released (April 2019) the resources will be removed from this cookbook as all users should be running Chef 14.4 or later at that point.

## 8.5.4 (2018-08-29)

- Add missing email documentation for the request property
- Fix x509_crl to work on non-Linux platforms
- Attribute -> Property in the readme
- revokation -> revocation in the readme
- Update group/owner documentation
- Avoid deprecation warnings on Chef 14.3+

## 8.5.3 (2018-08-15)

- Call ::OpenSSL not OpenSSL to be more defensive in the helpers

## 8.5.2 (2018-08-14)

- Back out mode change in ec_private_key

## 8.5.1 (2018-08-14)

- Add license headers to the resources
- Remove default_action setup from the resources since this is done automatically in custom resources now
- Make sure to use the path name_property when creating the ec public key file
- Make sure we're using openssl and not Chef's Openssl class
- Simplify how we handle user/group properties

## 8.5.0 (2018-08-02)

- Use the system provided owner/group defaults in resources
- Added new openssl_x509_crl resource
- Fix openssl_ec_public_key with documentation & tests
- Few corrections in the documentation
- Fix backward compatibility with chef client 12

## 8.4.0 (2018-07-30)

This release is brought to you by Institut National de l'Audiovisuel, which contributed the following changes:

- openssl_x509 is renamed to openssl_x509_certificate with backwards compatibility for the old name
- openssl_x509_certificate can now generate a signed certificate with a provided CA cert & key
- openssl_x509_certificate now support x509 extensions
- openssl_x509_certificate now support x509 csr
- openssl_x509_certificate now generate a random serial for the certificate
- openssl_x509_certificate expires has now a default value : 365
- country field is now mandatory in x509_request
- the private key file is not rewrited in x509_request if it already exist

## 8.3.0 (2018-07-25)

- Add resource x509_request

## 8.2.0 (2018-07-23)

- Add ec_private_key & ec_public_key resources

## 8.1.2 (2018-02-09)

- Fix typo in resources that caused failures on Windows.
- Properly reference key_cipher in the readme

## 8.1.1 (2018-01-05)

- Add YARD comments to all the helpers
- Move valid ciphers directly into the equal_to check
- Remove the Chefspec matchers since modern ChefSpec does this automatically
- Fix failures on Windows nodes

## 8.1.0 (2017-12-28)

- Adding x509 support for /ST and /L
- Allow passing private key content to rsa_public_key resource via property
- Fix openssl_rsa_public_key converging on every run
- Fix undefied method "cipher" error in openssl_rsa_private_key resource

## 8.0.0 (2017-12-11)

- Added a new openssl_rsa_public_key resource which generates a public key from a private key
- Rename openssl_rsa_key to openssl_rsa_private_key, while still allowing the old name to function. This resource actually generates private keys, but the previous name didn't make that clear
- Added owner, group, and mode properties to all of the resources so you could control who owned the files you generated
- Set the default modes of generated files to 640 instead of 644
- Set the files to generate using node['root_group'] not 'root' for compatibility on other *nix systems such as FreeBSD and macOS
- Added a new property to openssl_rsa_private_key for specifying the cipher to use
- Converted integration tests to InSpec and moved all resources to a single Kitchen suite for quicker testing
- Added a force property to allow overwriting any existing key that may exist
- Fixed upgrade recipe failures on Debian 9
- Added a new path property which allows you to set the path there instead of in the resource's name
- Improved input validation in some of the helpers
- Added a deprecation message in Opscode::OpenSSL::Password helper "secure_password" and removed readme documentation
- Added a warning in the upgrade recipe if we're on an unsupported platform
- Switched the upgrade recipe to a multipackage upgrade to speed up Chef runs

## 7.1.0 (2017-05-30)

- Add supported platforms to the metdata
- Fix amazon support
- Remove class_eval usage and require Chef 12.7+

## 7.0.1 (2017-03-21)

- Fix compatibility with Chef 12.5.1

## 7.0.0 (2017-03-06)

- Converted LWRPs to custom resources, increasing the chef-client dependency to 12.5+. This fixes the bus where each resource notified on every run even if it didn't actually update the files on disk.
- Added testing for Chef 13
- Test with Local Delivery instead of Rake

## 6.1.1 (2017-01-19)

- Resolve deprecation warnings in chefspec
- Use proper ::File class and fix ^2 validation of dhparam key length
- Disable .zero? in cookstyle for now

## 6.1.0 (2017-01-18)

- [#37] Support for Subject Alternative Names on generated self-signed certificates
- rubocop
- Cookstyle fixes

## 6.0.0 (2016-09-08)

- Update the minimum chef release to 12.1

## 5.0.1 (2016-09-01)
- Update docs from node.normal as node.set has been deprecated
- Testing updates

## 5.0.0 (2016-08-27)

- Remove the need for the chef-sugar cookbook
- Remove the default['openssl']['packages'] attribute in the upgrades recipe and instead use the correct openssl packages based on platform
- Remove support for Debian 6 and Ubuntu 10.04 in the upgrade recipe
- Add support for Fedora and Suse in the upgrade recipe
- Prevent errors with unset variable in error raising within the random password helper
- Add cookstyle and resolve all warnings
- Add testing, contributing, and maintainers documentation
- Add integration testing in Travis CI with kitchen-dokken
- Add issues_url, source_url and chef_version metadata
- Update the requirements section of the README
- Update the Chefspecs to avoid errors and run using caching for faster runs
- Add issues and PR templates for Github

## v4.4.0 (2015-08-28)

- NEW: x509 certificates are now signed via SHA-256 instead of SHA-1
- FIX: gen_dhparam error now correctly fails with TypeError instead of ArgumentError if Generator argument isn't an integer

## v4.3.2 (2015-08-01)

- FIX: Updated changelog

## v4.3 (2015-08-01)

- NEW: Add rsa_key lwrp
- FIX: dhparam lwrp now correctly honors the generator parameter

## v4.2 (2015-06-23)

- NEW: Add dhparam lwrp
- FIX: x509 lwrp now updates resource count correctly

## v4.1.2 (2015-06-20)

- Add Serverspec suite
- Removed update suite from .kitchen.yml
- Add explicit license to test cookbook recipes
- Add Whyrun support to x509 LWRP
- Expand Chefspec tests for x509 LWRP to step_into LWRP
- Add helper library
- Update x509 LWRP to verify existing keys, if specified

## v4.1.1 (2015-06-11)

- README.md fixes

## v4.1.0 (2015-06-11)

- Add new random_password Mixin (Thanks, Seth!)
- Rewritten README.md
- Refactor specs
- Clear Rubocop violations

## v4.0.0 (2015-02-19)

- Reverting to Opscode module namespace

## v3.0.2 (2015-12-18)

- Accidently released 2.0.2 as 3.0.2
- Re-namespaced `Opscode::OpenSSL::Password` module as `Chef::OpenSSL::Password`

## v2.0.2 (2014-12-30)

- Call cert.to_pem before recipe DSL

## v2.0.0 (2014-06-11)

- # 1 - **[COOK-847](https://tickets.chef.io/browse/COOK-847)** - Add LWRP for generating self signed certs

- # 4 - **[COOK-4715](https://tickets.chef.io/browse/COOK-4715)** - add upgrade recipe and complete test harness

## v1.1.0

### Improvement

- **[COOK-3222](https://tickets.chef.io/browse/COOK-3222)** - Allow setting length for `secure_password`

## v1.0.2

- Add name attribute to metadata
