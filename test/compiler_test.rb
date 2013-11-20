require 'test_helper'

module MoCo

  describe Compiler do

    describe 'require libraries' do

      $LOAD_PATH.unshift(fixtures_path)

      it 'will not require the library at the time of registration' do
        JsCompiler.require_library('js_lib')
        refute defined? JsLib
      end

      it 'requires the library when the compiler is instantiated' do
        CssCompiler.require_library('css_lib')
        refute defined? CssLib
        CssCompiler.new('')
        assert defined? CssLib
      end

      it 'requires the superclass libraries' do
        HtmlCompiler.require_library('html_lib')
        refute defined? HtmlLib
        Class.new(Class.new(HtmlCompiler)).new('')
        assert defined? HtmlLib
      end

    end

    describe 'require uninstalled libraries' do

      class CorruptCompiler < HtmlCompiler
        require_library 'not_installed', 'not-installed-gem', '~> 2'
      end

      it 'raises a LoadError with installation instructions' do
        e = assert_raises(Gem::LoadError) { CorruptCompiler.new('') }
        assert_match "gem install not-installed-gem -v '~> 2'", e.message
      end

    end

    describe 'compiler options' do

      after { reset_options(HtmlCompiler) }

      it 'sets the option' do
        HtmlCompiler.set_option(:format, :html5)
        assert_equal :html5, HtmlCompiler.options[:format]
        assert_equal :html5, HtmlCompiler.new('').options[:format]
      end

      specify 'the default value is true' do
        HtmlCompiler.set_option(:ugly)
        assert_equal true, HtmlCompiler.options[:ugly]
      end

      specify 'updating the options hash directly has no effect' do
        HtmlCompiler.options[:format] = :xhtml
        compiler = HtmlCompiler.new('')
        compiler.options[:format] = :xhtml
        assert_empty HtmlCompiler.options
        assert_empty compiler.options
      end

    end

    describe 'the compiled filename' do

      it 'cannot be equal to the source filename' do
        e = assert_raises(Error) do
          HtmlCompiler.new('index.html', Dir.pwd + '/index.html')
        end
        assert_match 'validate_filenames', e.backtrace.first
      end

      it 'will keep the compiled filename unchanged, if provided' do
        compiler = HtmlCompiler.new('source.md', 'compiled.xml', 'dir')
        assert_equal 'compiled.xml', compiler.compiled_file
      end

    end

    describe 'the compiled filename extension' do

      def compiled_file(source_file)
        JsCompiler.new(source_file).compiled_file
      end

      it 'has the compiled extension' do
        assert_equal 'script.js', compiled_file('script.coffee')
      end

      specify 'the compiler must implement compiled_extension' do
        e = assert_raises(NotImplementedError) { Compiler.new('') }
        assert_match 'compiled_extension', e.backtrace.first
      end

      describe 'nested source extension' do

        it 'will not duplicate the compiled extension' do
          assert_equal 'script.js', compiled_file('script.js.coffee')
        end

        it 'will keep other extensions' do
          assert_equal 'script.min.js', compiled_file('script.min.coffee')
        end

        specify 'not duplicate extension' do
          assert_equal 'about_js.js', compiled_file('about_js.coffee')
        end

      end

      describe 'nested compiled extension' do

        class Minify < JsCompiler
          define_singleton_method(:compiled_extension) { '.min.js' }
        end

        specify do
          assert_equal 'script.min.js', Minify.new('script.js').compiled_file
        end

      end

      describe 'no extensions' do

        class Readme < Compiler
          define_singleton_method(:compiled_extension) { '' }
        end

        specify 'the compiled extension is empty' do
          assert_equal 'README', Readme.new('README.txt').compiled_file
        end

        specify 'the source file has no extension' do
          assert_equal 'README.html', HtmlCompiler.new('README').compiled_file
        end

      end

    end

    describe 'the compiled filename directory' do

      def compiled_file(source_file, compiled_dir = nil)
        CssCompiler.new(source_file, nil, compiled_dir).compiled_file
      end

      it 'has the same directory as the source file by default' do
        assert_equal 'css/style.css', compiled_file('css/style.sass')
      end

      it 'replaces the directory if one is provided' do
        assert_equal 'css/style.css', compiled_file('style.scss', 'css')
        assert_equal 'css/style.css', compiled_file('/sass/style.scss', 'css/')
      end

      it 'removes the source directory if compiled_dir is empty' do
        assert_equal 'style.css', compiled_file('templates/style.scss', '')
      end

    end

    describe 'compile' do

      class GoodCompiler < Compiler
        define_method(:compiled_text) { 'The compiled text' }
      end

      let(:compiler) do
        GoodCompiler.new(fixtures_path('source.txt'), tmp_dir + '/dir/out.txt')
      end

      it 'reads the source file' do
        assert_equal 'The source text', compiler.source_text
      end

      it 'makes the necessary directories for the compiled file' do
        compiler.compile
        assert File.directory?(File.dirname(compiler.compiled_file))
      end

      it 'writes the compiled text to the compiled file' do
        compiler.compile
        assert_equal 'The compiled text', File.read(compiler.compiled_file)
      end

    end

    describe 'failed compilation' do

      class BadCompiler < Compiler
        define_method(:compiled_text) { raise 'The error text' }
      end

      let(:compiler) { BadCompiler.new('', tmp_dir + '/dir/out.txt') }

      it 'raises a CompileError' do
        assert_raises(CompileError) { compiler.compile }
      end

      it 'writes the error message to the compiled file' do
        compiler.compile rescue
        assert_equal 'The error text', File.read(compiler.compiled_file)
      end

      specify 'the compiler must implement compiled_text' do
        e = assert_raises(NotImplementedError) { JsCompiler.new('').compile }
        assert_match 'compiled_text', e.backtrace.first
      end

    end

    describe 'should_compile?' do

      let(:compiler) { JsCompiler.new(tmp_dir + '/script.coffee') }

      it 'is true if the compiled file does not exist' do
        touch(compiler.source_file)
        assert compiler.should_compile?
      end

      it 'is true when the source file is updated' do
        touch(compiler.compiled_file, :mtime => 0)
        touch(compiler.source_file,   :mtime => 1)
        assert compiler.should_compile?
      end

      it 'is false if the compiled file is up to date' do
        touch(compiler.source_file)
        touch(compiler.compiled_file)
        refute compiler.should_compile?
      end

    end

  end

end
