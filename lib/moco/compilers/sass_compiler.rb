module MoCo

  class SassCompiler < CssCompiler

    require_library 'sass'
    register 'sass'
    register 'scss'

    def compiled_text
      Sass::Engine.new(source_text, options).render
    rescue => e
      e.instance_eval { alias :line :sass_line } if defined? e.sass_line
      raise
    end

    def options
      { :syntax     => (source_file =~ /\.sass$/) ? :sass : :scss,
        :cache      => false,
        :read_cache => false
      }.merge(super)
    end

  end

end
