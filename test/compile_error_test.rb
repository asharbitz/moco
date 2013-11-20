require 'test_helper'

module MoCo

  describe CompileError do

    describe 'the error message' do

      let(:error) do
        message = 'script.coffee:4:8: Error: syntax error'
        CompileError.new(StandardError.new(message), 'script.coffee')
      end

      it 'removes the filename and line number' do
        refute_match 'script.coffee', error.message
        refute_match /\d/, error.message
      end

      it 'removes error: from the start of the message' do
        refute_match 'Error:', error.message
      end

      it 'capitalizes the first letter' do
        assert_equal 'Syntax error', error.message
      end

    end

    describe 'the line number' do

      def line_from(options)
        error = StandardError.new(options[:message])
        error.define_singleton_method(:line) { options[:line_method] }
        error.set_backtrace(options[:backtrace])
        CompileError.new(error, 'index.haml').line
      end

      it 'uses the line method of the original error' do
        assert_equal 2, line_from(:line_method => 2)
      end

      it 'finds the line number in the error message' do
        assert_equal 42, line_from(:message => 'index.haml:42 ...')
      end

      it 'finds the line number in the backtrace' do
        assert_equal 4, line_from(:backtrace => 'index.haml:4:2: ...')
      end

      it 'ignores line numbers from other files' do
        assert_nil line_from(:backtrace => 'about.haml:2: ...')
      end

      it 'works with filenames containing special characters' do
        file = 'index( |*).haml'
        error = CompileError.new(StandardError.new(file + ':7:'), file)
        assert_equal 7, error.line
      end

    end

    describe 'the column' do

      def column_from(options)
        error = StandardError.new(options[:message])
        error.define_singleton_method(:column) { options[:column_method] }
        CompileError.new(error, 'index.haml').column
      end

      it 'uses the column method of the original error' do
        assert_equal 4, column_from(:column_method => 4)
      end

      it 'finds the column in the error message' do
        assert_equal 2, column_from(:message => 'index.haml:4:2: ...')
      end

    end

  end

end
