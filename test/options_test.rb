require 'test_helper'

module MoCo

  describe Options do

    class MockOptions < Options
      define_method(:load_moco_files) {}
      define_method(:validate_files) {}
      define_method(:display_help) {}
    end

    def parse(args = '')
      MockOptions.parse(args.shellsplit)
    end

    describe 'parse command line options' do

      it 'sets the default options' do
        assert_equal Options.new.default_options, parse
      end

      it 'sets boolean options' do
        assert_equal true,  parse('--force')[:force]
        assert_equal false, parse('--no-force')[:force]
      end

      it 'sets array options' do
        assert_equal %w[Chrome],       parse('-b Chrome')[:browsers]
        assert_equal %w[Chrome],       parse('-b Chrome,Chrome')[:browsers]
        assert_equal %w[Chrome Opera], parse('-b Chrome,Opera')[:browsers]
        assert_equal %w[Chrome Opera], parse('-b Chrome -b Opera')[:browsers]
      end

      describe 'the compile option' do

        it 'sets the compile flag' do
          assert_equal true,  parse('-c sass')[:compile]
          assert_equal true,  parse('--compile')[:compile]
          assert_equal false, parse('--no-compile')[:compile]
        end

        it 'sets the compile extensions' do
          assert_equal ['sass'], parse('--compile .sass')[:compile_exts]
        end

        it 'raises an OptionError if an extension is unregistered' do
          assert_raises(OptionError) { parse('-c cofe') }
        end

      end

      describe 'setting compiler options' do

        it 'sets the options' do
          parse('--option haml:ugly -o haml:preserve:pre:code')
          assert_equal true,         HamlCompiler.options[:ugly]
          assert_equal %w[pre code], HamlCompiler.options[:preserve]
          reset_options(HamlCompiler)
        end

        it 'raises an OptionError if the option key is missing' do
          assert_raises(OptionError) { parse('-o haml') }
        end

        it 'raises an OptionError if the extension is unregistered' do
          assert_raises(OptionError) { parse('-o aml:ugly') }
        end

      end

      it 'sets the source map flag' do
        parse('--source-map')
        assert_equal true, CoffeeCompiler.options[:sourceMap]
        reset_options(CoffeeCompiler)
      end

      it 'requires the library' do
        refute defined? OptionsLib
        parse('--require ' + fixtures_path('options_lib'))
        assert defined? OptionsLib
      end

    end

    describe 'parse command line path arguments' do

      before { MockOptions.send(:define_method, :validate_files) { super() } }
      after  { MockOptions.send(:define_method, :validate_files) {} }

      let(:dir)  { fixtures_path }
      let(:file) { fixtures_path('moco.rb') }

      it 'sets the source files and directories' do
        assert_equal [file], parse("#{dir} #{file}")[:source_files]
        assert_equal [dir],  parse("#{dir} #{file}")[:source_dirs]
      end

      it 'sets the compiled files and directories' do
        assert_equal '/file', parse("#{file}:/file")[:compiled_files][file]
        assert_equal '/dir',  parse("#{dir}:/dir")[:compiled_dirs][dir]
      end

      it 'raises an OptionError if no path is provided' do
        assert_raises(OptionError) { parse }
      end

      it 'raises an OptionError if the path does not exists' do
        assert_raises(OptionError) { parse('no_such_file') }
      end

      it 'raises an OptionError if the compiled file is a directory' do
        assert_raises(OptionError) { parse("#{file}:#{dir}") }
      end

      it 'raises an OptionError if the compiled directory is a file' do
        assert_raises(OptionError) { parse("#{dir}:#{file}") }
      end

    end

    describe 'the moco file' do

      before do
        moco_file = fixtures_path('moco.rb')
        MockOptions.send(:define_method, :load_moco_files) { load moco_file }
      end

      after do
        MockOptions.send(:define_method, :load_moco_files) {}
        Options.instance_variable_set(:@args, nil)
        reset_register
      end

      it 'can register new compilers' do
        parse
        assert_equal TextCompiler, MoCo.compiler_for('txt')
      end

      it 'sets compiler options' do
        parse
        assert_equal ['pre'], TextCompiler.options[:preserve]
        assert_equal :html5,  TextCompiler.options[:format]
        assert_equal true,    TextCompiler.options[:ugly]
      end

      it 'sets general options' do
        assert_equal false, parse[:reload]
      end

      specify 'the command line options have precedence' do
        assert_equal true,  parse('-r -o txt:format:xml')[:reload]
        assert_equal 'xml', TextCompiler.options[:format]
      end

      specify 'MoCo.args expects a shell escaped string' do
        MoCo.args(%(-o txt:foo:'The "Quote"'))
        MoCo.args(%(-o txt:bar:The\\ \\"Quote\\"))
        parse
        assert_equal 'The "Quote"', TextCompiler.options[:foo]
        assert_equal 'The "Quote"', TextCompiler.options[:bar]
      end

      it 'finds the moco files in the current working directory' do
        current_dir = Dir.pwd
        Dir.chdir(tmp_dir)
        touch([Dir.pwd + '/moco.rb', Dir.pwd + '/.moco'])
        assert_includes Options.moco_files, Dir.pwd + '/moco.rb'
        assert_includes Options.moco_files, Dir.pwd + '/.moco'
        Dir.chdir(current_dir)
      end

    end

  end

end
