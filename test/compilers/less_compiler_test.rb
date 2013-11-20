require 'test_helper'

module MoCo

  describe LessCompiler do

    it 'is registered for less files' do
      assert_equal LessCompiler, MoCo.compiler_for('less')
    end

    it 'is a CSS compiler' do
      assert LessCompiler < CssCompiler
      assert_equal 'css', LessCompiler.compiled_extension
    end

    describe 'compile' do

      css = <<-EOF
        .less {
          color: #d9eef2;
        }
      EOF

      less = <<-EOF
        @blue: #D9EEF2;
        .less {
          color: @blue;
        }
      EOF

      import = <<-EOF
        @import 'color';
        .less {
          color: @blue;
        }
      EOF

      [css, less, import].each { |style| style.gsub!(/^ {8}/, '') }

      it 'compiles less into css' do
        compiler = mock_compiler(LessCompiler, less)
        assert_equal css, compiler.compiled_text
      end

      it 'handles the @import directive' do
        LessCompiler.set_option(:paths, [fixtures_path])
        compiler = mock_compiler(LessCompiler, import)
        assert_equal css, compiler.compiled_text
        reset_options(LessCompiler)
      end

    end

    describe 'compile error' do

      let(:compiler) do
        mock_compiler(LessCompiler, '.less { color: @pink; }')
      end

      it 'raises a CompileError' do
        assert_raises(CompileError) { compiler.compile }
      end

      it 'has a line number' do
        assert_equal 1, (compiler.compile rescue $!).line
      end

    end

  end if run_compiler_tests?(LessCompiler)

end
