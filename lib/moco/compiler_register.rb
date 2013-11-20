require 'singleton'

module MoCo

  class CompilerRegister

    include Singleton

    def initialize
      @compilers = {}
    end

    def register(compiler, extension)
      extension = FileUtil.normalized_extension(extension)
      @compilers[extension] = compiler
    end

    def compiler_for(file)
      extension = FileUtil.normalized_extension(file)
      @compilers[extension]
    end

    def compilers
      @compilers.dup
    end

  end

end
