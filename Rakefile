require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rake/testtask'

Rake::TestTask.new do |t|
    t.libs << 'test'
end

task :default => :test
