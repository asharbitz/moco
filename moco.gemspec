Gem::Specification.new do |spec|
  spec.name        = 'moco'
  spec.version     = '0.1.1'
  spec.license     = 'MIT'

  spec.author      = 'AS Harbitz'
  spec.email       = 'asharbitz@gmail.com'
  spec.homepage    = 'https://github.com/asharbitz/moco'

  spec.summary     = 'Monitors and compiles web templates. Reloads the browser.'
  spec.description = 'MoCo monitors web templates. On updates the templates ' +
                     'are compiled and the browser reloaded. MoCo currently ' +
                     'supports CoffeeScript, Sass, LESS, Markdown and Haml. ' +
                     'Mac OS X only.'

  spec.files       = Dir['LICENSE', 'moco.gemspec', 'moco.rb', 'Rakefile',
                         'README.txt', '{lib,src}/**/*.*']
  spec.test_files  = Dir['test/**/*.*']
  spec.executables << 'moco'

  spec.add_dependency             'rb-fsevent',           '~> 0.9'

  spec.add_development_dependency 'minitest',             '~> 4.0'
  spec.add_development_dependency 'coffee-script-source', '>= 1.6.2'
  spec.add_development_dependency 'runjs'
  spec.add_development_dependency 'haml'
  spec.add_development_dependency 'less'
  spec.add_development_dependency 'therubyracer'
  spec.add_development_dependency 'redcarpet'
  spec.add_development_dependency 'pygments.rb'
  spec.add_development_dependency 'sass'

  spec.required_ruby_version = '>= 1.8.7'
  spec.requirements         << 'Mac OS X'
end
