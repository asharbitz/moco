require 'test_helper'

module MoCo

  describe Browser do

    describe 'urls' do

      def urls(*urls)
        Browser.new([], [], urls).instance_variable_get(:@args)
      end

      it "expands 'localhost' into all the localhost urls" do
        assert_equal Browser.localhost, urls('localhost')
      end

      it "empties the urls if it contains 'all'" do
        assert_empty urls('localhost', 'all')
      end

      it 'removes duplicates' do
        assert_equal 1, urls('file:///', 'file:///').size
      end

    end

  end

end
