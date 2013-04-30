name             "composer"
maintainer       "Escape Studios"
maintainer_email "dev@escapestudios.com"
license          "MIT"
description      "Installs/Configures Composer"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.4"

%w{ debian ubuntu redhat centos fedora scientific amazon }.each do |os|
supports os
end

depends "php"

recipe "composer", "Installs composer."