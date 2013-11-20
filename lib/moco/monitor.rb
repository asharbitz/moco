require 'rb-fsevent'
require 'find'

module MoCo

  class Monitor

    def initialize(files, directories, extensions)
      @files = files
      @pattern = pattern(directories, extensions)
      @directories = directories + files.map { |file| File.dirname(file) }
      @directories = delete_nested(@directories)
    end

    def files
      set_timestamps
      @timestamps.keys
    end

    def monitor(&callback)
      set_timestamps
      options = { :no_defer => true, :latency => 0.1 }
      fsevent = FSEvent.new
      fsevent.watch(@directories, options) do |updated_dirs|
        on_update(updated_dirs, &callback)
      end
      fsevent.run
    end

  private

    def pattern(dirs, exts)
      return nil if dirs.empty? || exts.empty?
      dirs = delete_nested(dirs.dup)
      dirs = escape(dirs).join('|')
      exts = escape(exts).join('|')
      /^(#{dirs}).*\.(#{exts})$/
    end

    def escape(values)
      values.map { |value| Regexp.escape(value.to_s) }
    end

    def delete_nested(dirs)
      dirs.delete_if do |nested_dir|
        dirs.any? do |dir|
          nested_dir != dir && nested_dir.start_with?(dir)
        end
      end.uniq
    end

    def set_timestamps
      @timestamps = {}
      Find.find(*@directories) do |file|
        store_timestamp(file) if monitor?(file)
      end
    end

    def store_timestamp(file)
      @timestamps[file] = File.mtime(file)
    end

    def monitor?(file)
      @files.include?(file) || (@pattern && file =~ @pattern && File.file?(file))
    end

    def updated?(file)
      @timestamps[file] != File.mtime(file)
    end

    def on_update(dirs, &callback)
      dirs = delete_nested(dirs)
      Find.find(*dirs) do |file|
        if monitor?(file) && updated?(file)
          store_timestamp(file)
          yield file
        end
      end
    end

  end

end
