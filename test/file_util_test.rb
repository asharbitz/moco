require 'test_helper'

module MoCo

  describe FileUtil do

    describe 'normalized extension' do

      specify do
        assert_equal 'less', FileUtil.normalized_extension('less')
      end

      it 'removes the period' do
        assert_equal 'less', FileUtil.normalized_extension('.less')
      end

      it 'accepts a symbol' do
        assert_equal 'less', FileUtil.normalized_extension(:less)
      end

      it 'accepts a filename' do
        assert_equal 'sass', FileUtil.normalized_extension('/dir/file.sass')
      end

      it 'works with spaces' do
        assert_equal 'sass', FileUtil.normalized_extension(' file with spaces .sass ')
      end

      it 'works with nested extensions' do
        assert_equal 'sass', FileUtil.normalized_extension('file.css.sass')
      end

    end

  end

end
