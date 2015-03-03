source 'https://rubygems.org'

gem 'rake'

group :lint do
  gem 'rubocop', '~> 0.18'
  gem 'foodcritic', '~> 3.0'
end

group :unit, :integration do
  gem 'berkshelf',  '~> 3.0'
end

group :unit do
  gem 'chefspec'
end

group :integration do
  gem 'chef'
  gem 'test-kitchen'
  gem 'kitchen-vagrant'
  gem 'serverspec'
end
