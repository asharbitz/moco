module MoCo

  class Application

    def self.monitor_compile_and_reload(args)
      options = parse_options(args)
      new(options).monitor_compile_and_reload
    end

    def initialize(options)
      @options = options
    end

    def monitor_compile_and_reload
      monitor = monitor_instance
      monitor.files.each { |file| compile(file, @options[:force]) }
      reload
      if @options[:monitor]
        Log.monitor
        monitor.monitor { |file| compile_and_reload(file) }
        puts
      end
    end

  private

    def self.parse_options(args)
      options = Options.parse(args)
      Log.quiet = options[:quiet]
      Log.load(Options.moco_files)
      options
    rescue OptionError, LoadError => e
      Log.load(Options.moco_files)
      abort e.message
    end

    private_class_method :parse_options

    def monitor_instance
      exts = []
      exts += @options[:compile_exts] if @options[:compile]
      exts += @options[:reload_exts]  if @options[:reload]
      Monitor.new(@options[:source_files], @options[:source_dirs], exts.uniq)
    end

    def compile_and_reload(file)
      if compiler = compile(file, true)
        reload(compiler.compiled_file)
      end
      reload(file)
    end

    def compile(file, force)
      if @options[:compile]
        compiler = compiler_for(file)
        if compiler && (force || compiler.should_compile?)
          do_compile(compiler)
          compiler
        end
      end
    end

    def compiler_for(file)
      if compiler = MoCo.compiler_for(file)
        compiler.new(file, compiled_file(file), compiled_dir(file))
      end
    rescue LoadError => e
      abort e.message
    end

    def compiled_file(file)
      @options[:compiled_files][file]
    end

    def compiled_dir(file)
      @options[:compiled_dirs].keys.sort.reverse.each do |source_dir|
        if file.start_with?(source_dir)
          compiled_dir = @options[:compiled_dirs][source_dir]
          if compiled_dir
            compiled_dir = File.dirname(file).sub(source_dir, compiled_dir)
          end
          return compiled_dir
        end
      end
      nil
    end

    def do_compile(compiler)
      Log.compile(compiler)
      compiler.compile
      Log.update(compiler)
    rescue CompileError => e
      Log.error(e)
    end

    def reload(file = nil)
      if @options[:reload]
        @browser ||= browser_instance
        @browser.reload if file.nil? || @browser.should_reload?(file)
      end
    end

    def browser_instance
      Browser.new(@options[:reload_exts], @options[:browsers], @options[:urls])
    end

  end

end
