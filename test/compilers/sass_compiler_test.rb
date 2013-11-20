require 'test_helper'

module MoCo

  describe SassCompiler do

    it 'is registered for sass and scss files' do
      assert_equal SassCompiler, MoCo.compiler_for('sass')
      assert_equal SassCompiler, MoCo.compiler_for('scss')
    end

    it 'is a CSS compiler' do
      assert SassCompiler < CssCompiler
      assert_equal 'css', SassCompiler.compiled_extension
    end

    it 'selects the correct syntax' do
      assert_equal :sass, SassCompiler.new('style.sass').options[:syntax]
      assert_equal :scss, SassCompiler.new('style.scss').options[:syntax]
    end

    describe 'compile' do

      css = <<-EOF
        .sass {
          color: #ce4dd6; }
      EOF

      sass = <<-EOF
        $pink: #CE4DD6
        .sass
          color: $pink
      EOF

      scss = <<-EOF
        $pink: #CE4DD6;
        .sass { color: $pink; }
      EOF

      import = <<-EOF
        @import 'color';
        .sass { color: $pink; }
      EOF

      [css, sass, scss, import].each { |style| style.gsub!(/^ {8}/, '') }

      it 'compiles sass into css' do
        compiler = mock_compiler(SassCompiler, sass, 'style.sass')
        assert_equal css, compiler.compiled_text
      end

      it 'compiles scss into css' do
        compiler = mock_compiler(SassCompiler, scss, 'style.scss')
        assert_equal css, compiler.compiled_text
      end

      it 'handles the @import directive' do
        SassCompiler.set_option(:load_paths, [fixtures_path])
        compiler = mock_compiler(SassCompiler, import, 'style.scss')
        assert_equal css, compiler.compiled_text
        reset_options(SassCompiler)
      end

    end

    describe 'compile error' do

      let(:compiler) do
        mock_compiler(SassCompiler, '.sass { color: $blue; }', 'style.scss')
      end

      it 'raises a CompileError' do
        assert_raises(CompileError) { compiler.compile }
      end

      it 'has a line number' do
        assert_equal 1, (compiler.compile rescue $!).line
      end

    end

  end if run_compiler_tests?(SassCompiler)

end
