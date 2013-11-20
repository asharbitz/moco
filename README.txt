Usage:
  moco [options] SOURCE ...
  moco [options] SOURCE:COMPILED ...

Description:
  MoCo monitors web templates. On updates the templates are compiled and
  the browser reloaded. MoCo currently supports CoffeeScript, Sass, LESS,
  Markdown and Haml.

Files and directories:
  The given source files and directories will be monitored for updates.
  Use the SOURCE:COMPILED format to save the compiled files to another
  directory or to change the compiled filename:
  moco .:/www sass:/www/css README.md:/www/index.html

Options:
      --monitor             Keep running until Ctrl-C is pressed [DEFAULT]
      --no-monitor          Exit after the initial compilation

  -c, --compile             Compile all the supported file types [DEFAULT]
  -c, --compile EXT,EXT     Compile the given file types
      --no-compile          Disable compilation
                            moco -c coffee -c sass,scss .

  -f, --force               Force recompilation at startup
      --no-force            Do not compile up-to-date files [DEFAULT]

  -m, --source-map          Make source maps if the compiler supports it
      --no-source-map       Do not make source maps [DEFAULT]

  -o, --option EXT:KEY:VAL  Set a compiler option
                            moco -o coffee:header       # header = true
                                 -o haml:ugly:false     # ugly   = false
                                 -o haml:format::xhtml  # format = :xhtml
                                 -o md:layout:md.html   # layout = 'md.html'
                                 -o less:paths:css: .   # paths  = ['css']

  -r, --reload              Reload after css/html/js file updates [DEFAULT]
  -r, --reload EXT,EXT      Set the file types that triggers reloading
      --no-reload           Disable reloading
                            moco -r rb -r css,html,js .

  -b, --browser BRO,BRO     The browsers to reload [all by DEFAULT]
                            moco -b safari -b chrome,canary .

  -u, --url all             Reload all active tabs
  -u, --url localhost       Reload active tabs with localhost urls [DEFAULT]
  -u, --url URL,URL         Reload active tabs where the url starts with URL
                            moco -u localhost -u http://app.dev/ .

      --require LIB         Require the library
                            moco --require path/to/compiler.rb .

  -q, --quiet               Log errors only
      --no-quiet            Log errors and file updates [DEFAULT]

  -l, --list                List the supported file types and browsers

  -h, --help                Display this message

The moco file:
  MoCo looks for files named '.moco' and 'moco.rb' in the working directory
  and in the home directory. The purpose of these files is to set options
  and to define new compilers. The command line options have precedence.

More information:
  https://github.com/asharbitz/moco#readme
