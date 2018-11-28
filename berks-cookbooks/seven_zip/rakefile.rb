require 'cookstyle'
require 'foodcritic'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: [:rubocop, :foodcritic, :spec]

FoodCritic::Rake::LintTask.new do |t|
  t.options = {
    cookbook_paths: '.',
    search_gems: true,
  }
end

RSpec::Core::RakeTask.new do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.rspec_opts = ['--color', '-f documentation', '-tunit']
end

RuboCop::RakeTask.new

begin
  require 'stove/rake_task'
  Stove::RakeTask.new
rescue LoadError => e
  puts ">>> Gem load error: #{e}, omitting #{task.name}" unless ENV['CI']
end
