require File.expand_path('../../lib/moco', __FILE__)
require 'minitest/autorun'
require 'tmpdir'

COMPILERS = MoCo.compilers
TMP_DIR   = Dir.mktmpdir('MoCo')

MiniTest::Unit.after_tests do
  FileUtils.rm_rf(TMP_DIR)
end

def tmp_dir
  Dir.mktmpdir(nil, TMP_DIR)
end

def fixtures_path(file = nil)
  fixtures_dir = File.expand_path('../fixtures', __FILE__)
  file ? File.join(fixtures_dir, file) : fixtures_dir
end

def touch(files, options = {})
  Array(files).each do |file|
    FileUtils.makedirs(File.dirname(file))
    FileUtils.touch(file, options)
  end
end

def reset_register
  register = MoCo::CompilerRegister.instance
  register.instance_variable_set(:@compilers, COMPILERS.dup)
end

def reset_options(klass)
  klass.instance_variable_set(:@options, {})
end

def run_compiler_tests?(klass)
  klass.new('')
rescue LoadError => e
  warn "Skipping #{klass} tests (#{e.message.split("\n").first})"
end

def mock_compiler(klass, source_text, source_file = nil, compiled_file = nil)
  source_file ||= "mock.#{MoCo.compilers.invert[klass]}"
  mock = klass.new(source_file, compiled_file)
  mock.define_singleton_method(:source_text) { source_text }
  mock.define_singleton_method(:write_file) { |filename, text| }
  mock
end

unless respond_to?(:define_singleton_method)
  Object.send(:define_method, :define_singleton_method) do |name, &block|
    singleton = class << self; self end
    singleton.send(:define_method, name, &block)
  end
  Object.send(:public, :define_singleton_method)
end
