openssl Cookbook CHANGELOG
==========================
This file is used to list changes made in each version of the openssl cookbook.

v4.4.0 (2015-08-28)
-------------------
- NEW: x509 certificates are now signed via SHA-256 instead of SHA-1
- FIX: gen_dhparam error now correctly fails with TypeError instead of ArgumentError if Generator argument isn't an integer

v4.3.2 (2015-08-01)
-------------------
- FIX: Updated changelog

v4.3 (2015-08-01)
-------------------
- NEW: Add rsa_key lwrp
- FIX: dhparam lwrp now correctly honors the generator parameter

v4.2 (2015-06-23)
-------------------
- NEW: Add dhparam lwrp
- FIX: x509 lwrp now updates resource count correctly

v4.1.2 (2015-06-20)
-------------------
- Add Serverspec suite
- Removed update suite from .kitchen.yml
- Add explicit license to test cookbook recipes
- Add Whyrun support to x509 LWRP
- Expand Chefspec tests for x509 LWRP to step_into LWRP
- Add helper library
- Update x509 LWRP to verify existing keys, if specified

v4.1.1 (2015-06-11)
-------------------
- README.md fixes

v4.1.0 (2015-06-11)
-------------------
- Add new random_password Mixin (Thanks, Seth!)
- Rewritten README.md
- Refactor specs
- Clear Rubocop violations

v4.0.0 (2015-02-19)
-------------------
- Reverting to Opscode module namespace

v3.0.2 (2015-12-18)
-------------------
- Accidently released 2.0.2 as 3.0.2
- Re-namespaced `Opscode::OpenSSL::Password` module as `Chef::OpenSSL::Password`

v2.0.2 (2014-12-30)
-------------------
- Call cert.to_pem before recipe DSL

v2.0.0 (2014-06-11)
-------------------

- #1 - **[COOK-847](https://tickets.chef.io/browse/COOK-847)** - Add LWRP for generating self signed certs
- #4 - **[COOK-4715](https://tickets.chef.io/browse/COOK-4715)** - add upgrade recipe and complete test harness

v1.1.0
------
### Improvement
- **[COOK-3222](https://tickets.chef.io/browse/COOK-3222)** - Allow setting length for `secure_password`

v1.0.2
------
- Add name attribute to metadata
