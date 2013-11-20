module MoCo

  class Compiler

    def self.register(source_extension)
      MoCo.register(self, source_extension)
    end

    def self.require_library(lib, gem_name = lib, version = nil)
      @libraries ||= []
      @libraries << [lib, gem_name, version]
    end

    def self.set_option(key, value = true)
      @options ||= {}
      @options[key] = value
    end

    def self.options
      (@options || {}).dup
    end

    def self.convert_option(key, value)
      [key.to_sym, CompilerOption.convert(value)]
    end

    def self.compiled_extension
      raise NotImplementedError
    end

    attr_reader :source_file
    attr_reader :compiled_file

    def initialize(source_file, compiled_file = nil, compiled_dir = nil)
      @source_file = source_file
      @compiled_file = compiled_file || compiled_filename(compiled_dir)
      validate_filenames
      require_libraries
    end

    def should_compile?
      ! FileUtil.up_to_date?(@compiled_file, @source_file)
    end

    def compile
      write_compiled(compiled_text)
    rescue SyntaxError, StandardError => e
      error = CompileError.new(e, @source_file)
      error.set_backtrace(e.backtrace)
      write_compiled(error_text(error))
      raise error
    end

    def options
      self.class.options
    end

    def source_text
      File.read(@source_file)
    end

    def compiled_text
      raise NotImplementedError
    end

  private

    def compiled_filename(compiled_dir)
      compiled_ext = self.class.compiled_extension
      compiled_file = FileUtil.replace_extension(@source_file, compiled_ext)
      FileUtil.replace_directory(compiled_file, compiled_dir)
    end

    def validate_filenames
      if File.expand_path(@source_file) == File.expand_path(@compiled_file)
        raise Error, 'The source and compiled filenames are identical'
      end
    end

    def require_libraries
      self.class.ancestors.each do |klass|
        if libs = klass.instance_variable_get(:@libraries)
          libs.each { |lib| require_library(*lib) }
          libs.clear
        end
      end
    end

    def require_library(lib, gem_name = lib, version = nil)
      gem gem_name, version if version
      require lib
    rescue LoadError => e
      if e.message !~ /\b(#{lib}|#{gem_name})\b/
        raise  # Another library failed to load
      else
        version = " -v '#{version}'" if version
        raise e, "#{e.message}\nTry: gem install #{gem_name}#{version}"
      end
    end

    def write_compiled(text)
      write_file(@compiled_file, text)
    end

    def write_file(filename, text)
      FileUtil.write(filename, text)
    end

    def error_text(error)
      error.message
    end

  end

  class HtmlCompiler < Compiler

    def self.compiled_extension
      'html'
    end

    def error_text(error)
      HtmlError.message(error)
    end

  end

  class CssCompiler < Compiler

    def self.compiled_extension
      'css'
    end

    def error_text(error)
      CssError.message(error)
    end

  end

  class JsCompiler < Compiler

    def self.compiled_extension
      'js'
    end

    def error_text(error)
      JsError.message(error)
    end

  end

end
