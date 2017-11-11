# CHANGELOG for ulimit

This file is used to list changes made in each version of ulimit.

## 0.3.2

* Resolves issue some users were having with a resource-loading race condition, thanks to Chris Roberts (https://github.com/chrisroberts)

## 0.3.1

* Fix domain typo, thanks to David Radcliffe (https://github.com/dwradcliffe) (also reported by Lewis Thompson (https://github.com/lewisthompson))
* Add support for split hard/soft nofile limits, thanks to Troy Ready (https://github.com/troyready)
* Fix license boilerplate, thanks to Troy Ready (https://github.com/troyready)
* Fix limits.d file extension, thanks to https://github.com/soul-rebel

## 0.3.0

* Add Domain LWRP for arbitrary rule creation. Thanks for Chris Roberts (https://github.com/chrisroberts)

## 0.2.0

* Support specifying users via attributes (as long as your runlist includes the ulimit::default recipe). Thanks to Dmytro Shteflyuk (https://github.com/kpumuk)

## 0.1.5

* Allow setting core_limit. Thanks to Aaron Nichols (https://github.com/adnichols)

## 0.1.4:

* Does not set any ulimit parameter by default - only when specified. Thanks to Graham Christensen (https://github.com/zippykid)

## 0.1.3:

* Adds node attribute node['ulimit']['pam_su_template_cookbook'] to allow users to provide a su pam.d template from another cookbook

## 0.1.2:

* Add memory limit handling, courtesy of Sean Porter (https://github.com/bmhatfield/chef-ulimit/pull/3)

## 0.1.0:

* Initial release of ulimit

- - - 
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
