require 'test_helper'

module MoCo

  describe AnsiEscape do

    def stdout_tty(tty, &block)
      $stdout = $stdout.dup
      $stdout.define_singleton_method(:tty?) { tty }
      yield
    ensure
      $stdout = STDOUT
    end

    it 'escapes the message when stdout points to a terminal' do
      stdout_tty(true) do
        assert_equal    "\e[1mHello\e[0m", AnsiEscape.bold('Hello')
        assert_equal "\e[1;31mHello\e[0m", AnsiEscape.bold_red('Hello')
      end
    end

    it 'leaves the message alone if stdout is redirected to a file' do
      stdout_tty(false) do
        assert_equal 'Hello', AnsiEscape.bold('Hello')
        assert_equal 'Hello', AnsiEscape.bold_red('Hello')
      end
    end

    describe 'unescape' do

      let(:hello) { "\e[1mHello\e[0m \e[1;31mWorld\e[00m!" }

      it 'removes ANSI escape sequences' do
        assert_equal 'Hello World!', AnsiEscape.unescape(hello)
      end

      it 'can replace ANSI escape sequences' do
        unescaped = AnsiEscape.unescape(hello) { |msg| "<b>#{msg}</b>" }
        assert_equal '<b>Hello</b> <b>World</b>!', unescaped
      end

      it 'does not support nested escape sequences' do
        nested = "\e[;31mNested \e[1mEscape\e[m\e[0m"
        refute_equal 'Nested Escape',           AnsiEscape.unescape(nested)
        assert_equal "Nested \e[1mEscape\e[0m", AnsiEscape.unescape(nested)
      end

    end

  end

end
