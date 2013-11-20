module MoCo

  class Browser

    def self.extensions
      %w[css html js]
    end

    def self.browsers
      %w[Canary Chrome Firefox Opera Safari WebKit]
    end

    def self.localhost
      %w[
        file:///
        file://localhost/
        http://localhost/
        http://localhost:
        http://127.0.0.1/
        http://127.0.0.1:
        http://0.0.0.0/
        http://0.0.0.0:
      ]
    end

    def initialize(extensions, browsers, urls)
      @extensions = extensions
      @args = browsers + urls(urls)
      @reload = false
      at_exit { do_reload }
    end

    def should_reload?(file)
      @extensions.include?(FileUtil.normalized_extension(file))
    end

    def reload
      return if @reload
      @reload = true
      Thread.new do
        sleep 0.2
        do_reload
      end
    end

  private

    SCRIPT = File.expand_path('../support/reload.scpt', __FILE__)

    def urls(urls)
      return [] if urls.include?('all')
      urls += Browser.localhost if urls.delete('localhost')
      urls.uniq
    end

    def do_reload
      return unless @reload
      @reload = false
      system('osascript', SCRIPT, *@args)
    end

  end

end
