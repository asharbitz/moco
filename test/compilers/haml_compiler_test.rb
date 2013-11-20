require 'test_helper'

module MoCo

  describe HamlCompiler do

    let(:compiler) { mock_compiler(HamlCompiler, '#haml= 2 + 2') }

    it 'is registered for haml files' do
      assert_equal HamlCompiler, MoCo.compiler_for('haml')
    end

    it 'is a Html compiler' do
      assert HamlCompiler < HtmlCompiler
      assert_equal 'html', HamlCompiler.compiled_extension
    end

    it 'compiles haml into html' do
      assert_equal "<div id='haml'>4</div>", compiler.compiled_text.strip
    end

    specify 'options are passed on to the haml compiler' do
      HamlCompiler.set_option(:attr_wrapper, '@')
      assert_match '<div id=@haml@>', compiler.compiled_text
      reset_options(HamlCompiler)
    end

    describe 'compile error' do

      def compile(haml)
        mock_compiler(HamlCompiler, haml, 'mock.haml').compile
      rescue CompileError => error
        error
      end

      it 'removes the filename and line number from the error message' do
        error = compile('.haml= [}')
        refute_match 'mock.haml', error.message
        refute_match /[:\d]/, error.message

        # The original error
        assert_match 'mock.haml:1:', error.error.message
        assert_match 'mock.haml:2:', error.error.message
      end

      describe 'the line number' do

        specify 'line numbers fetched from @line start at 1' do
          error = compile(' %p')
          assert_equal 1, error.line

          # The original error
          assert error.error.line
        end

        it 'finds the line number in the backtrace' do
          error = compile("\n.time= Date.tomorrow")
          assert_equal 2, error.line

          # The original error
          refute defined? error.error.line
          assert_match 'mock.haml:2:', error.error.backtrace.first
        end

        it 'finds the line number in the error message' do
          error = compile("\n\n.unbalanced= [}")
          assert_equal 3, error.line

          # The original error
          assert_nil error.error.line
          refute_match ':3:', error.error.backtrace.to_s
          assert_match 'mock.haml:3:', error.error.message
        end

        specify 'line can be nil' do
          error = compile("%p= eval '2 *** 10'")
          assert_nil error.line
        end

      end

    end

  end if run_compiler_tests?(HamlCompiler)

end
