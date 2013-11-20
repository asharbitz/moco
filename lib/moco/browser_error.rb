require 'cgi'

module MoCo

  class BrowserError

    def self.message(error)
      new(error).message
    end

    def initialize(error)
      @message = error.message
      @file    = file(error)
      @line    = error.line
      @column  = error.column
    end

    def message
      escaped_message + on_line + in_file
    end

  private

    def file(error)
      FileUtil.short_path(error.file)
    end

    def read_file(file)
      File.read(File.expand_path('../support/error/' + file, __FILE__))
    end

    def escaped_message(message = @message)
      message = remove_ansi_color(message)
      message = message.gsub('\\') { '\\\\' }.gsub('"', '\"')
      message + "\n\n"
    end

    def remove_ansi_color(message)
      AnsiEscape.unescape(message) do |escaped|
        html_allowed? ? "<span>#{escaped}</span>" : escaped
      end
    end

    def html_allowed?
      true
    end

    def on_line
      @line ? "Line: #{@line}\n" : ''
    end

    def in_file
      "File: #{File.basename(@file)} (#{edit_link || @file})"
    end

    def edit_link
      if html_allowed? && txmt_url_scheme?
        href = "txmt://open/?url=file://#{@file}"
        href << "&line=#{@line}" if @line
        href << "&column=#{@column}" if @column
        "<a href='#{href}'>#{@file}</a>"
      end
    end

    def txmt_url_scheme?
      return @@txmt if defined? @@txmt
      @@txmt = `defaults read com.apple.LaunchServices` =~
               /LSHandlerURLScheme["\s]*=["\s]*txmt["\s]*;/
    end

  end

  class CssError < BrowserError

    def message
      read_file('error.css') % super.gsub(/\n/, '\a ')
    end

    def html_allowed?
      false
    end

  end

  class JsError < BrowserError

    def message
      read_file('error.js') % super.gsub(/\n/, '<br>')
    end

    def escaped_message
      super(CGI.escapeHTML(@message))
    end

  end

  class HtmlError < JsError

    def message
      read_file('error.html') % super
    end

  end

end
