module MoCo

  module AnsiEscape

    def self.bold(text)
      escape(text, '1')
    end

    def self.bold_red(text)
      escape(text, '1;31')
    end

    def self.green(text)
      escape(text, '32')
    end

    def self.unescape(text)
      text.gsub(/\e\[[\d;]+m(.*?)\e\[0*m/) do
        block_given? ? yield($1) : $1
      end
    end

  private

    def self.escape(text, code)
      if $stdout.tty?
        "\e[#{code}m#{text}\e[0m"
      else
        text
      end
    end

    private_class_method :escape

  end

end
