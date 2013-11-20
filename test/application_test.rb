require 'test_helper'

module MoCo

  describe Application do

    describe 'the compiled directory' do

      def compiled_dir(file)
        compiled_dirs = {
          '/one'           => '/1',
          '/one/two'       => nil,
          '/one/two/three' => '/3',
        }
        Application.new(:compiled_dirs => compiled_dirs).compiled_dir(file)
      end

      before { Application.send(:public,  :compiled_dir) }
      after  { Application.send(:private, :compiled_dir) }

      it 'returns the directory that closest matches the filename' do
        assert_equal '/1', compiled_dir('/one/file')
        assert_equal '/3', compiled_dir('/one/two/three/file')
      end

      it 'keeps the nested directory structure' do
        assert_equal '/1/nested', compiled_dir('/one/nested/file')
        assert_equal '/3/nested', compiled_dir('/one/two/three/nested/file')
      end

      it 'returns nil when the compiled directory is unspecified' do
        assert_nil compiled_dir('/one/two/file')
        assert_nil compiled_dir('/one/two/nested/file')
      end

    end

  end

end
