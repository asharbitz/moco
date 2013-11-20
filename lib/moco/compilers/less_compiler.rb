module MoCo

  class LessCompiler < CssCompiler

    require_library 'v8', 'therubyracer'
    require_library 'less'
    register 'less'

    def compiled_text
      Less::Parser.new(options).parse(source_text).to_css(options)
    end

  end

end
