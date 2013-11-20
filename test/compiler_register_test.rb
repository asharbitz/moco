require 'test_helper'

module MoCo

  describe CompilerRegister do

    before { Singleton.__init__(CompilerRegister) }
    after  { reset_register }

    it 'registers the compiler class for the source extension' do
      HtmlCompiler.register('haml')
      assert_equal HtmlCompiler, MoCo.compiler_for('haml')
    end

    describe 'compiler lookup' do

      before do
        MoCo.register(CssCompiler, 'sass')
        MoCo.register(CssCompiler, 'scss')
        MoCo.register(HtmlCompiler, 'md')
      end

      it 'works when more than one compiler is registered' do
        assert_equal CssCompiler,  MoCo.compiler_for('scss')
        assert_equal HtmlCompiler, MoCo.compiler_for('md')
        assert_equal CssCompiler,  MoCo.compiler_for('sass')
      end

      it 'accepts a filename' do
        assert_equal CssCompiler, MoCo.compiler_for('/dir/a style.css.sass')
      end

      it 'returns nil when the extension is unregistered' do
        assert_nil MoCo.compiler_for('dummy')
      end

    end

  end

end
