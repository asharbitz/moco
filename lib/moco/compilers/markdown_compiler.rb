module MoCo

  class MarkdownCompiler < HtmlCompiler

    if RUBY_VERSION < '1.9'
      require_library 'redcarpet', 'redcarpet', '~> 2.0'
    else
      require_library 'redcarpet'
    end

    register 'markdown'
    register 'md'

    def self.set_option(key, value = true)
      if key == :pygments
        value = pygments_options(value)
      end
      super
    end

    def compiled_text
      if options[:layout]
        layout(toc, body)
      else
        toc + body
      end
    end

  private

    def self.pygments_options(value)
      return unless value
      unless Hash === value
        key, *value = Array(value)
        value = value.first if value.size < 2
        value = true if value.nil?
        value = { key => value }
        value.delete(true)
      end
      options[:pygments] ? options[:pygments].merge(value) : value
    end

    private_class_method :pygments_options

    def layout(toc, body)
      layout = read_layout
      layout = layout.gsub('{{TITLE}}', header(body) || file)
      layout = layout.gsub('{{FILE}}', file)
      if layout.include?('{{TOC}}')
        layout.sub('{{TOC}}', toc.chop).sub('{{BODY}}', body)
      else
        layout.sub('{{BODY}}', toc + body)
      end
    end

    def read_layout
      File.read(options[:layout])
    end

    def header(body)
      h1 = body[/<h1\b[^>]*>(.*?)<\/h1>/m, 1]
      h1.gsub(/<[^>]+>/, '').gsub(/\s+/, ' ').strip if h1
    end

    def file
      File.basename(source_file)
    end

    def toc
      if options[:toc]
        toc = render(Redcarpet::Render::HTML_TOC.new)
        toc << "\n" unless toc.empty?
      end
      toc || ''
    end

    def body
      if options[:pygments]
        renderer = pygments_renderer(options[:pygments])
      else
        renderer = Redcarpet::Render::HTML
      end
      options = render_options
      render(renderer.new(options), options)
    end

    def render(renderer, extensions = {})
      renderer.extend(Redcarpet::Render::SmartyPants) if options[:smarty]
      Redcarpet::Markdown.new(renderer, extensions).render(source_text)
    end

    def render_options
      options = options().dup
      options[:with_toc_data]      = true if options[:toc]
      options[:fenced_code_blocks] = true if options[:pygments]
      [:pygments, :smarty, :toc, :layout, :title].each do |key|
        options.delete(key)
      end
      options
    end

    def pygments_renderer(options)

      require_library('pygments', 'pygments.rb') unless defined? Pygments

      Class.new(Redcarpet::Render::HTML) do

        define_method(:options) do
          options.dup
        end

        def block_code(code, language)
          lexer = Pygments::Lexer.find(language) if language
          if lexer
            "\n" + lexer.highlight(code, :options => options) + "\n"
          else
            klass = %( class="#{escape_html(language)}") if language
            "\n<pre><code#{klass}>#{escape_html(code)}</code></pre>\n"
          end
        end

        def escape_html(text)
          escaped = {
            "'" => '&#39;',
            '<' => '&lt;',
            '&' => '&amp;',
            '>' => '&gt;',
            '"' => '&quot;'
          }
          text.gsub(/['<&>"]/) { |char| escaped[char] }
        end

      end

    end

  end

end
