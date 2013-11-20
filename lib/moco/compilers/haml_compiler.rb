module MoCo

  class HamlCompiler < HtmlCompiler

    require_library 'haml'
    register 'haml'

    def compiled_text
      Haml::Engine.new(source_text, options).render
    rescue => e
      e.instance_eval { @line += 1 if @line }
      raise
    end

    def options
      super.merge(:filename => source_file)
    end

  end

end
