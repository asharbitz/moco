MoCo.args '--no-reload -o txt:preserve:pre: .'

class TextCompiler < MoCo::HtmlCompiler
  register 'txt'
  set_option :ugly
end

TextCompiler.set_option(:format, :html5)
