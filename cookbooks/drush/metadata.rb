maintainer       "Mark Sonnabaum"
maintainer_email "mark.sonnabaum@acquia.com"
license          "Apache 2.0"
description      "Installs drush head"
version          "0.9.0"
#depends           "php::pear"
#depends           "php::php5"
recipe "drush", "Installs drush head"

%w{ debian ubuntu arch }.each do |os|
  supports os
end
