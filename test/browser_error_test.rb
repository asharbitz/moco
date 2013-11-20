require 'test_helper'

module MoCo

  describe BrowserError do

    class BrowserError
      define_method(:txmt_url_scheme?) { true }
    end

    let(:error) do
      error = StandardError.new("\e[1;31m eval \e[0m error \\n&")
      error.define_singleton_method(:line) { 2 }
      error.define_singleton_method(:column) { 7 }
      CompileError.new(error, File.expand_path('~') + '/file.txt')
    end

    describe 'the browser error message' do

      let(:msg) { BrowserError.message(error) }

      it 'contains the line number and filename' do
        assert_match "\n\nLine: 2\nFile: file.txt", msg
      end

      it 'shortens the filename by replacing the home directory with ~' do
        assert_match '>~/file.txt</a>', msg
      end

    end

    describe 'the CSS error message' do

      let(:msg) { CssError.message(error) }

      it 'is CSS' do
        assert_match 'body:before {', msg
      end

      it 'is escaped for CSS' do
        assert_match 'error \\\\n&\\a \\a Line: 2', msg
      end

      it 'removes ansi color codes completely' do
        refute_match '[1;31m', msg
        refute_match '<span>', msg
      end

      it 'has no link' do
        refute_match '<a href', msg
      end

    end

    describe 'the JavaScript error message' do

      let(:msg) { JsError.message(error) }

      it 'is JavaScript' do
        assert_match 'function() {', msg
      end

      it 'is escaped for Html' do
        assert_match 'error \\\\n&amp;<br><br>Line: 2', msg
      end

      it 'replaces ansi color codes with a span element' do
        refute_match '[1;31m', msg
        assert_match '<span> eval </span>', msg
      end

      it 'has a TextMate link to the exact error location' do
        link = "<a href='txmt://open/?url=file://~/file.txt&line=2&column=7'>"
        assert_match link, msg
      end

      it 'has no link if the TextMate url scheme is unsupported' do
        js_error = JsError.new(error)
        js_error.define_singleton_method(:txmt_url_scheme?) { false }
        refute_match '<a href', js_error.message
      end

    end

    describe 'the HTML error message' do

      let(:msg) { HtmlError.message(error) }

      it 'is Html' do
        assert_match '<!DOCTYPE html>', msg
      end

      it 'contains the JavaScript error message' do
        assert_match JsError.message(error), msg
      end

    end

  end

end
