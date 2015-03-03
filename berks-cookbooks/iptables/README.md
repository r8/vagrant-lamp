Description
===========

Sets up iptables to use a script to maintain firewall rules. However
this cookbook may be deprecated or heavily modified in favor of the
general firewall cookbook, see __Roadmap__.

Roadmap
-------

* [COOK-652] - create a firewall cookbook
* [COOK-688] - create iptables providers for all resources

Requirements
============

## Platform:

* Ubuntu/Debian
* RHEL/CentOS

Recipes
=======

default
-------

The default recipe will install iptables and provides a ruby script
(installed in `/usr/sbin/rebuild-iptables`) to manage rebuilding
firewall rules from files dropped off in `/etc/iptables.d`.

Definitions
===========

See __Roadmap__ for plans to replace the definition with LWRPs.

iptables\_rule
--------------

The definition drops off a template in `/etc/iptables.d` after the
`name` parameter. The rule will get added to the local system firewall
through notifying the `rebuild-iptables` script. See __Examples__ below.

Usage
=====

Ensure that the system is set up to use the definition and rebuild
script with `recipe[iptables]`. Then create templates with the
firewall rules in the cookbook where the definition will be used. See
__Examples__.

Since certain chains can be used with multiple tables (e.g., _PREROUTING_),
you might have to include the name of the table explicitly (i.e., _*nat_,
_*mangle_, etc.), so that the `/usr/sbin/rebuild-iptables` script can infer
how to assemble final ruleset file that is going to be loaded. Please note,
that unless specified otherwise, rules will be added under the __filter__
table by default.

Examples
--------

To enable port 80, e.g. in an `httpd` cookbook, create the following
template:

    # Port 80 for http
    -A FWR -p tcp -m tcp --dport 80 -j ACCEPT

This would go in the cookbook,
`httpd/templates/default/http.erb`. Then to use it in
`recipe[httpd]`:

    iptables_rule "http"

To redirect port 80 to local port 8080, e.g., in the aforementioned `httpd`
cookbook, created the following template:

    *nat
    # Redirect anything on eth0 coming to port 80 to local port 8080
    -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080

Please note, that we explicitly add name of the table (being _*nat_ in this
example above) where the rules should be added.

This would most likely go in the cookbook,
`httpd/templates/default/http_8080.erb`. Then to use it in
`recipe[httpd]`:

    iptables_rule "http_8080"

Attributes
==========

    default["iptables"]["install_rules"] = true  # install the default rules

License and Author
==================

Author:: Adam Jacob <adam@opscode.com>
Author:: Joshua Timberman <joshua@opscode.com>

Copyright:: 2008-2011, Opscode, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
