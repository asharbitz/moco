module MoCo

  module Log

    @quiet = false

    def self.quiet=(quiet)
      @quiet = quiet
    end

    def self.load(files)
      files.each do |file|
        log([:Loading, file, files])
      end
    end

    def self.monitor
      log
      log('Press Ctrl-C to stop monitoring')
    end

    def self.compile(compiler)
      log
      log([:Compile, compiler.source_file, files(compiler)])
    end

    def self.update(compiler)
      updated_files(compiler).each do |file|
        log([:Updated, file, files(compiler)])
      end
    end

    def self.error(e)
      if @quiet
        log(nil, true)
        log([:Compile, e.file], true)
      end
      log(error_on_line(e), true)
      log(error_message(e), true)
    end

  private

    def self.log(status = nil, force = false)
      return if @quiet && ! force
      if Array === status
        status, file, files = status
        dir = FileUtil.short_path(File.dirname(file))
        file = File.basename(file)
        file = file.ljust(max_length(files)) if files
        status = "#{status}: #{file} (#{dir})"
      end
      puts status || ''
    end

    private_class_method :log

    def self.max_length(files)
      files = files.map { |file| File.basename(file) }
      files.max_by(&:length).length
    end

    private_class_method :max_length

    def self.files(compiler)
      [compiler.source_file] + compiled_files(compiler)
    end

    private_class_method :files

    def self.compiled_files(compiler)
      [compiler.compiled_file, source_map_file(compiler)].compact
    end

    private_class_method :compiled_files

    def self.source_map_file(compiler)
      klass = compiler.class
      if klass < SourceMap && klass.options[klass.source_map_key]
        compiler.source_map_file
      end
    end

    private_class_method :source_map_file

    def self.updated_files(compiler)
      compiled_files(compiler).select do |file|
        FileUtil.up_to_date?(file, compiler.source_file)
      end
    end

    private_class_method :updated_files

    def self.error_on_line(e)
      AnsiEscape.bold_red(e.line ? "Error on line #{e.line}:" : 'Error:')
    end

    private_class_method :error_on_line

    def self.error_message(e)
      $stdout.tty? ? e.message : AnsiEscape.unescape(e.message)
    end

    private_class_method :error_message

  end

end
