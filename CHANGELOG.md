# Change Log

## [1.0.2] - 2015-09-25

### Fixed
- Check if vagrant-berkshelf plugin is installed before trying to disable it
- Fix keyserver override for Percona repository
- Replace Apache event MPM with prefork
- Fix phpmyadmin installation

### Changed
- Update name of base box provided by Chef
- Upgrade vendor cookbooks
- Upgrade node.js version
- Use nodejs cookbook to install npm modules

### Removed
- Remove deprecated apache template

## [1.0.1] - 2015-04-12

### Fixed
- Fix MySQL socket path

## [1.0.0] - 2015-03-24

### Changed
- Use Chef provided boxes and Omnibus
- Manage vendor cookbooks with Berkshelf
- Replace MailCatcher with MailHog and Postfix
- Use cookbook for Percona toolkit installation
- Update nodejs version to 0.12.0
- Remove Drush

### Fixed
- Upgrade cookbook for latest Chef

### Removed
- Remove oh-my-zsh
- Remove Drush
