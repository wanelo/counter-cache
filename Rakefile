require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

`bundle exec appraisal install`

task :default do
  sh 'bundle exec appraisal rspec'
end

