require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task :default => :spec
task :all do
  sh 'bundle exec appraisal install'
  sh 'bundle exec appraisal rspec'
end

