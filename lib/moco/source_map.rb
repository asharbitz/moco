module MoCo

  module SourceMap

    def self.source_map_key
      raise NotImplementedError
    end

    attr_reader :source_map_text

    def compile
      super
      write_file(source_map_file, source_map_text) if source_map_text
    end

    def source_map_file
      compiled_file + '.map'
    end

  end

end
