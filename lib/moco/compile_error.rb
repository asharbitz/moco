module MoCo

  class CompileError < Error

    attr_reader :error
    attr_reader :file
    attr_reader :line
    attr_reader :column

    def initialize(error, file)
      @error  = error
      @file   = file
      @line   = get_line
      @column = get_column
      super(get_message)
    end

  private

    def get_line
      line = line_from_method || line_from_message || line_from_backtrace
      line.to_i if line
    end

    def line_from_method
      @error.line if @error.respond_to?(:line)
    end

    def line_from_message
      @error.message[source_pattern, 1]
    end

    def line_from_backtrace
      if @error.backtrace && @error.backtrace[0]
        @error.backtrace[0][source_pattern, 1]
      end
    end

    def get_column
      column = column_from_method || column_from_message
      column.to_i if column
    end

    def column_from_method
      @error.column if @error.respond_to?(:column)
    end

    def column_from_message
      @error.message[source_pattern, 2]
    end

    def source_pattern
      file = Regexp.escape(@file)
      /^#{file}:(\d+):?(\d+)?[:\s]*/
    end

    def get_message
      message = @error.message.gsub(source_pattern, '')
      message = message.sub(/\Aerror: /i, '')
      message[0, 1] = message[0, 1].upcase
      message
    end

  end

end
