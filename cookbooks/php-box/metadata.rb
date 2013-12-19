name             "php-box"
maintainer       "Sergey Storchay"
maintainer_email "r8@r8.com.ua"
license          "MIT"
description      "Installs/Configures box.phar"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.2"

%w{ debian ubuntu redhat centos fedora scientific amazon }.each do |os|
  supports os
end

depends "php"

recipe "php-box", "Installs box.phar"
