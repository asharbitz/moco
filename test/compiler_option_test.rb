require 'test_helper'

module MoCo

  describe CompilerOption do

    def convert(option)
      value = option.split(':', 3)[2]
      CompilerOption.convert(value)
    end

    specify 'convert booleans' do
      assert_equal true,  convert('ext:key:true')
      assert_equal false, convert('ext:key:false')
    end

    specify 'the default option value is true' do
      assert_equal true, convert('ext:key')
    end

    specify 'convert integers' do
      assert_equal 100, convert('ext:key:100')
      assert_equal -10, convert('ext:key:-10')
      assert_equal   7, convert('ext:key:+007')
    end

    specify 'convert floats' do
      assert_equal  0.5, convert('ext:key:.5')
      assert_equal  0.5, convert('ext:key:+0.5')
      assert_equal -0.5, convert('ext:key:-.5')
    end

    specify 'exponential notation is unsupported' do
      assert_equal '1e2', convert('ext:key:1e2')
    end

    describe 'convert symbols' do

      specify do
        assert_equal :html5, convert('ext:key::html5')
        assert_equal :false, convert('ext:key::false')
        assert_equal :'007', convert('ext:key::007')
      end

      specify 'do not quote symbols' do
        assert_equal :'"dir/file"', convert('ext:key::"dir/file"')
        assert_equal :'dir/file',   convert('ext:key::dir/file')
      end

      specify 'symbols with colons are unsupported' do
        assert_equal [:'"foo', 'bar"'], convert('ext:key::"foo:bar"')
        assert_equal [:'foo\\', 'bar'], convert('ext:key::foo\\:bar')
      end

    end

    describe 'convert strings' do

      specify do
        assert_equal 'value', convert('ext:key:value')
        assert_equal 'v a l', convert('ext:key:v a l')
        assert_equal "cat's", convert("ext:key:cat's")
      end

      specify 'quoted strings' do
        assert_equal '007',   convert('ext:key:"007"')
        assert_equal 'true',  convert("ext:key:'true'")
        assert_equal 'a:b:c', convert('ext:key:"a:b:c"')
      end

      specify 'double quoted strings can include single quotes and vice versa' do
        assert_equal ":cat's", convert(%(ext:key:":cat's"))
        assert_equal "'cat'",  convert(%(ext:key:"'cat'"))
        assert_equal '"cat"',  convert(%(ext:key:'"cat"'))
      end

      specify 'quoted strings cannot include the same quote character' do
        assert_equal ["'", "cat's'"], convert(%(ext:key:':cat's'))
        assert_equal "''cat''",       convert(%(ext:key:''cat''))
        assert_equal '""cat""',       convert(%(ext:key:""cat""))
      end

      specify 'single and double quotes cannot be mixed' do
        assert_equal ["'not", 'quoted"'], convert(%(ext:key:'not:quoted"))
      end

    end

    specify 'convert empty strings and arrays' do
      assert_equal '',   convert('ext:key:')
      assert_equal [],   convert('ext:key::')
      assert_equal [''], convert('ext:key:"":')
    end

    describe 'convert arrays' do

      specify 'string arrays' do
        assert_equal ['one', 'two'], convert('ext:key:one:two')
        assert_equal ['one'],        convert('ext:key:one:')
      end

      specify 'symbol arrays' do
        assert_equal [:one, :two], convert('ext:key::one::two')
        assert_equal [:one],       convert('ext:key::one:')
      end

      specify 'array with mixed types' do
        assert_equal ["Cat's toy", true, :html5, -0.1, "007"],
          convert('ext:key:"Cat\'s toy":true::html5:-.1:"007"')
      end

      specify 'array values cannot include colons' do
        assert_equal ['"Title', ' MoCo"'], convert('ext:key:"Title: MoCo":')
        assert_equal ["'", "not_symbol'"], convert("ext:key:':not_symbol':")
      end

    end

  end

end
