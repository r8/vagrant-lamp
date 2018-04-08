# mingw Cookbook CHANGELOG

This file is used to list changes made in each version of the mingw cookbook.

## 2.0.2 (2018-02-15)

- Remove kind_of usage in the custom resources (FC117)

## 2.0.1 (2017-04-26)

- Test with Local Delivery instead of Rake
- Add chef_version to the metadata
- Use standardize Apache 2 license string

## 2.0.0 (2017-02-27)

- Require Chef 12.5 and remove compat_resource dependency

## 1.2.5 (2017-01-18)

- Require a working compat_resource

## v1.2.4 (2016-07-26)

- New msys2 shells do not inherit PATH from windows. Provide a way for
  clients to do this.

## v1.2.3 (2016-07-25)

- If PKG_CONFIG_PATH is already defined, honor it in the msys2 shell.

## v1.2.2 (2016-06-24)

- Download msys2 from the primary download url (instead of a specific mirror).

## v1.2.1 (2016-06-23)

- Fix msys2 initial install/upgrade steps that dependended on file modification time.
- Make msys2_package :install idempotent - it should not reinstall packages.
- Do not allow bash.exe to be called if MSYSTEM is undefined.

## v1.2.0 (2016-06-03)
- Updating to fix the issue where msys2 bash does not inherit the cwd correctly

## v1.1.0 (2016-06-03)
- Add msys2 based compiler support using the new msys2_package resource

## v1.0.0 (2016-05-11)

- Remove unnecessary default_action from the resources
- Depend on compat_resource cookbook to add Chef 12.1 - 12.4 compatbility
- Add this changelog file
- Fix license metadata in metadata.rb
- Disable FC016 check
