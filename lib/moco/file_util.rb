require 'fileutils'
require 'pathname'

module MoCo

  class FileUtil < File

    def self.normalized_extension(file)
      file = file.to_s
      extension = extname(file)
      extension = basename(file) if extension.empty?
      extension.delete('.').strip
    end

    def self.replace_extension(file, ext)
      return file unless ext
      file = file.chomp(extname(file))
      unless ext.empty?
        ext = '.' << ext unless ext.start_with?('.')
        file << ext unless file.end_with?(ext)
      end
      file
    end

    def self.replace_directory(file, dir)
      return file unless dir
      file = basename(file)
      file = join(dir, file) unless dir.empty?
      file
    end

    def self.short_path(path)
      home = File.expand_path('~')
      path.sub(home, '~')
    end

    def self.relative_path(from_file, to_file)
      from = Pathname.new(from_file)
      to = Pathname.new(to_file)
      to.relative_path_from(from.dirname).to_s
    end

    def self.up_to_date?(file, compared_to_file)
      exist?(file) && mtime(file) >= mtime(compared_to_file)
    end

    def self.write(file, text)
      FileUtils.makedirs(dirname(file))
      open(file, 'w') { |f| f.write(text) }
    end

  end

end
