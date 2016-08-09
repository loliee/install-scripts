require 'rake'
require 'yaml'
require 'rspec/core/rake_task'

namespace :serverspec do
  desc "Run serverspec"
  RSpec::Core::RakeTask.new('run') do |t|
    appname = ENV['appname'] || '*'
    t.pattern = "#{appname}/*_spec.rb"
  end
end
