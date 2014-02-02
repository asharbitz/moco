$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'moco'
require 'rake/testtask'

Rake::TestTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
end

desc 'Compile files'
task :compile do
  args = %w[--force --no-monitor --no-reload]
  MoCo::Application.monitor_compile_and_reload(args)
end
