# -*- mode: ruby -*-

require 'rake/testtask'

task :default => [:test_all]

# Run a specific unit test with `rake test TEST=test/Datalib/test_datalib.rb`
Rake::TestTask.new do |t|

  t.libs << "test"
  t.test_files = FileList['test/*/test_*.rb']
  t.verbose = true

end
