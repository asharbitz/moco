require 'optparse'
require 'shellwords'

module MoCo

  class Options

    def self.moco_files
      files = ['~/.moco', '~/moco.rb', './.moco', './moco.rb']
      files = files.map { |file| File.expand_path(file) }
      files.select { |file| File.file?(file) }
    end

    def self.args(args)
      @args ||= []
      @args += args.shellsplit
    end

    def self.parse(args)
      new.parse(args)
    end

    def parse(command_line_args)
      @options = {}
      args = moco_file_args + command_line_args
      display_help if args.empty?
      option_parser.order(args) { |option| path(option) }
      validate_options
      default_options.merge(@options)
    rescue OptionParser::ParseError => e
      raise OptionError.new(e)
    end

    def option_parser
      OptionParser.new do |op|
        op.version = MoCo::VERSION
        op.on(      '--[no-]monitor',           method(:monitor))
        op.on('-c', '--[no-]compile [EXT,EXT]', method(:compile), Array)
        op.on('-f', '--[no-]force',             method(:force))
        op.on('-m', '--[no-]source-map',        method(:source_map))
        op.on('-o', '--option EXT:KEY:VAL',     method(:compiler_option))
        op.on('-r', '--[no-]reload [EXT,EXT]',  method(:reload), Array)
        op.on('-b', '--browser BRO,BRO',        method(:browsers), Array)
        op.on('-u', '--url URL,URL',            method(:urls), Array)
        op.on(      '--require LIB',            method(:require_lib))
        op.on('-q', '--[no-]quiet',             method(:quiet))
        op.on('-l', '--list',                   method(:display_list))
        op.on('-h', '--help',                   method(:display_help))
      end
    end

    def default_options
      {
        :monitor        => true,
        :compile        => true,
        :compile_exts   => MoCo.compilers.keys.sort,
        :force          => false,
        :source_map     => false,
        :reload         => true,
        :reload_exts    => Browser.extensions,
        :browsers       => Browser.browsers,
        :urls           => Browser.localhost,
        :quiet          => false,
        :source_files   => [],
        :source_dirs    => [],
        :compiled_files => {},
        :compiled_dirs  => {}
      }
    end

    def help
      <<-EOF.gsub(/^ {8}/, '').gsub(/`(.+?)`/, AnsiEscape.green('\1'))
        Usage:
          `moco [options] SOURCE ...`
          `moco [options] SOURCE:COMPILED ...`

        Description:
          MoCo monitors web templates. On updates the templates are compiled and
          the browser reloaded. MoCo currently supports CoffeeScript, Sass, LESS,
          Markdown and Haml.

        Files and directories:
          The given source files and directories will be monitored for updates.
          Use the SOURCE:COMPILED format to save the compiled files to another
          directory or to change the compiled filename:
          `moco .:/www sass:/www/css README.md:/www/index.html`

        Options:
              --monitor             Keep running until Ctrl-C is pressed [DEFAULT]
              --no-monitor          Exit after the initial compilation

          -c, --compile             Compile all the supported file types [DEFAULT]
          -c, --compile EXT,EXT     Compile the given file types
              --no-compile          Disable compilation
                                    `moco -c coffee -c sass,scss .`

          -f, --force               Force recompilation at startup
              --no-force            Do not compile up-to-date files [DEFAULT]

          -m, --source-map          Make source maps if the compiler supports it
              --no-source-map       Do not make source maps [DEFAULT]

          -o, --option EXT:KEY:VAL  Set a compiler option
                                    `moco -o coffee:header`       # header = true
                                    `     -o haml:ugly:false`     # ugly   = false
                                    `     -o haml:format::xhtml`  # format = :xhtml
                                    `     -o md:layout:md.html`   # layout = 'md.html'
                                    `     -o less:paths:css: .`   # paths  = ['css']

          -r, --reload              Reload after css/html/js file updates [DEFAULT]
          -r, --reload EXT,EXT      Set the file types that triggers reloading
              --no-reload           Disable reloading
                                    `moco -r rb -r css,html,js .`

          -b, --browser BRO,BRO     The browsers to reload [all by DEFAULT]
                                    `moco -b safari -b chrome,canary .`

          -u, --url all             Reload all active tabs
          -u, --url localhost       Reload active tabs with localhost urls [DEFAULT]
          -u, --url URL,URL         Reload active tabs where the url starts with URL
                                    `moco -u localhost -u http://app.dev/ .`

              --require LIB         Require the library
                                    `moco --require path/to/compiler.rb .`

          -q, --quiet               Log errors only
              --no-quiet            Log errors and file updates [DEFAULT]

          -l, --list                List the supported file types and browsers

          -h, --help                Display this message

        The moco file:
          MoCo looks for files named '.moco' and 'moco.rb' in the working directory
          and in the home directory. The purpose of these files is to set options
          and to define new compilers. The command line options have precedence.

        More information:
          https://github.com/asharbitz/moco#readme
      EOF
    end

  private

    def moco_file_args
      load_moco_files
      Options.instance_variable_get(:@args) || []
    end

    def load_moco_files
      Options.moco_files.each do |file|
        load file
      end
    end

    [:monitor, :force, :browsers, :urls].each do |key|
      define_method(key) do |option|
        set_option(key, option)
      end
    end

    [:compile, :reload].each do |key|
      define_method(key) do |option|
        case option
        when Array
          option.map! { |ext| FileUtil.normalized_extension(ext) }
          set_option("#{key}_exts".to_sym, option)
          set_option(key, true)
        when nil
          set_option(key, true)
        else
          set_option(key, option)
        end
      end
    end

    def set_option(key, option)
      case option
      when Array
        @options[key] ||= []
        @options[key] += option
        @options[key].uniq!
      when Hash
        @options[key] ||= {}
        @options[key].merge!(option)
      else
        @options[key] = option
      end
    end

    def compiler_option(option)
      ext, key, value = option.split(':', 3)
      compiler = MoCo.compiler_for(ext)
      raise OptionError.new(:missing_option_key) unless key
      raise OptionError.new(:invalid_extension, ext) unless compiler
      key, value = compiler.convert_option(key, value)
      compiler.set_option(key, value)
    end

    def source_map(option)
      MoCo.compilers.each_value do |compiler|
        if compiler < SourceMap
          compiler.set_option(compiler.source_map_key, option)
        end
      end
    end

    def require_lib(option)
      require option
    rescue LoadError
      require File.expand_path(option)
    end

    def quiet(option)
      set_option(:quiet, option)
      SassCompiler.set_option(:quiet, option)
    end

    def display_list(option)
      display(list)
    end

    def display_help(option = nil)
      display(help)
    end

    def display(text)
      puts
      puts text
      puts
      exit 0
    end

    def list
      [ ['Compile:',   :compile_exts],
        ['Reload:',    :reload_exts],
        ['Browsers:',  :browsers],
        ['Localhost:', :urls]
      ].map do |header, key|
        [header, *default_options[key]].join("\n  ")
      end.join("\n\n")
    end

    def path(option)
      source, compiled = option.split(':')
      source   = File.expand_path(source)
      compiled = File.expand_path(compiled) if compiled
      if File.directory?(source)
        set_option(:source_dirs, [source])
        set_option(:compiled_dirs, source => compiled)
      elsif File.file?(source)
        set_option(:source_files, [source])
        set_option(:compiled_files, source => compiled)
      else
        raise OptionError.new(:invalid_file, source)
      end
    end

    def validate_options
      validate_files
      validate_compilers
      validate_browsers
    end

    def validate_files
      unless @options[:source_dirs] || @options[:source_files]
        raise OptionError.new(:missing_file)
      end
      (@options[:compiled_dirs] || {}).each_value do |dir|
        if dir && File.file?(dir)
          raise OptionError.new(:dir_expected, dir)
        end
      end
      (@options[:compiled_files] || {}).each_value do |file|
         if file && File.directory?(file)
           raise OptionError.new(:file_expected, file)
         end
      end
    end

    def validate_compilers
      (@options[:compile_exts] || []).each do |ext|
        unless MoCo.compiler_for(ext)
          raise OptionError.new(:invalid_extension, ext)
        end
      end
    end

    def validate_browsers
      supported_browsers = Browser.browsers.map(&:downcase)
      (@options[:browsers] || []).each do |browser|
        unless supported_browsers.include?(browser.downcase)
          raise OptionError.new(:invalid_browser, browser)
        end
      end
    end

  end

  class OptionError < Error

    def initialize(error, *args)
      super(error_message(error) % args)
    end

  private

    def error_message(error)
      case error
      when :missing_file
        [ 'No directory or file provided. ' +
          'To monitor files in the current directory:',
          'moco .' ]
      when :invalid_file
        [ "No such file or directory: '%s'" ]
      when :dir_expected
        [ "Expected a directory, but got a filename: '%s'" ]
      when :file_expected
        [ "Expected a filename, but got a directory: '%s'" ]
      when :invalid_extension
        [ "No compiler registered for '%s' files. The supported file types are:",
          MoCo.compilers.keys.sort.join(' ') ]
      when :missing_option_key
        [ 'The option key is missing. Set compiler options like this:',
          '-o coffee:header -o haml:format::xhtml' ]
      when :invalid_browser
        [ "Unknown browser '%s'. The supported browsers are:",
          Browser.browsers.join(' ') ]
      when Exception
        [ error.message ]
      end.join("\n")
    end

  end

end
