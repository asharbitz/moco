module MoCo

  VERSION = '0.1.0'

  class Error < StandardError
  end

  def self.compilers
    CompilerRegister.instance.compilers
  end

  def self.register(compiler, extension)
    CompilerRegister.instance.register(compiler, extension)
  end

  def self.compiler_for(file)
    CompilerRegister.instance.compiler_for(file)
  end

  def self.args(args)
    Options.args(args)
  end

end

require 'moco/ansi_escape'
require 'moco/application'
require 'moco/browser_error'
require 'moco/browser'
require 'moco/compile_error'
require 'moco/compiler_option'
require 'moco/compiler_register'
require 'moco/compiler'
require 'moco/file_util'
require 'moco/log'
require 'moco/monitor'
require 'moco/options'
require 'moco/source_map'

require 'moco/compilers/coffee_compiler'
require 'moco/compilers/haml_compiler'
require 'moco/compilers/less_compiler'
require 'moco/compilers/markdown_compiler'
require 'moco/compilers/sass_compiler'
