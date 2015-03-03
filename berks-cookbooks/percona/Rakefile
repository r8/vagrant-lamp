task default: "test"

desc "Run all tests except `kitchen`"
task test: [:rubocop, :foodcritic, :chefspec]

desc "Run all tests"
task all_tests: [:rubocop, :foodcritic, :chefspec, "kitchen:all"]

# rubocop style checker
require "rubocop/rake_task"
RuboCop::RakeTask.new

# foodcritic chef lint
require "foodcritic"
FoodCritic::Rake::LintTask.new do |t|
  t.options = { fail_tags: ["any"] }
end

# chefspec unit tests
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:chefspec) do |t|
  t.rspec_opts = "--color --format progress"
end

# test-kitchen integration tests
begin
  require "kitchen/rake_tasks"
  Kitchen::RakeTasks.new
rescue LoadError
  task("kitchen:all") { puts "Unable to run `test-kitchen`" }
end
