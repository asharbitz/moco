require 'test_helper'

module MoCo

  describe Monitor do

    before { skip unless __FILE__ == $0 }

    def tmp
      Pathname.new(tmp_dir).realpath().to_s
    end

    def updated(&block)
      updated = []
      thread = Thread.new do
        monitor.monitor { |file| updated << file }
      end
      sleep 0.05
      yield
      sleep 0.5
      thread.kill
      updated.sort
    end

    let(:dirs) { [tmp, tmp].sort }
    let(:files) { %W[#{dirs[0]}/file.haml #{dirs[1]}/nested/dir/file.sass] }
    let(:txt_file) { "#{dirs[1]}/file.txt" }

    describe 'monitor directories' do

      let(:monitor) { Monitor.new([], dirs, [:sass, :haml]) }

      it 'captures new files' do
        assert_equal files, updated { touch(files) }
      end

      it 'captures file updates' do
        touch(files, :mtime => 0)
        assert_equal files, updated { touch(files) }
      end

      it 'ignores files with other extensions' do
        assert_empty updated { touch(txt_file) }
      end

      it 'lists all the files currently being monitored' do
        Dir.mkdir("#{dirs[0]}/dir.sass")
        assert_empty monitor.files
        touch(files + [txt_file])
        assert_equal files, monitor.files.sort
      end

    end

    describe 'monitor files' do

      let(:monitor) { Monitor.new(files, [], []) }

      it 'captures file updates' do
        touch(files, :mtime => 0)
        assert_equal files, updated { touch(files + [txt_file]) }
      end

    end

  end

end
