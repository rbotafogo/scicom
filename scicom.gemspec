# -*- coding: utf-8 -*-
require 'rubygems/platform'

require './version'

Gem::Specification.new do |gem|

  gem.name    = $gem_name
  gem.version = $version
  gem.date    = Date.today.to_s

  gem.summary     = "Scientific Computing for Ruby"
  gem.description = <<-EOF 
SciCom (Scientific Computing) for Ruby brings the power of R to the Ruby community. SciCom 
is based on Renjin, a JVM-based interpreter for the R language for statistical computing.

Over the past two decades, the R language for statistical computing has emerged as the de 
facto standard for analysts, statisticians, and scientists. Today, a wide range of 
enterprises – from pharmaceuticals to insurance – depend on R for key business uses. Renjin 
is a new implementation of the R language and environment for the Java Virtual Machine (JVM),
whose goal is to enable transparent analysis of big data sets and seamless integration with 
other enterprise systems such as databases and application servers.

Renjin is still under development, but it is already being used in production for a number 
of client projects, and supports most CRAN packages, including some with C/Fortran 
dependencies.

SciCom integrates with Renjin and allows the use of R inside a Ruby script. In a sense, 
SciCom is similar to other solutions such as RinRuby, Rpy2, PipeR, etc. However, since 
SciCom and Renjin both target the JVM there is no need to integrate both solutions and 
there is no need to send data between Ruby and R, as it all resides in the same JVM. 
Further, installation of SciCom does not require the installation of GNU R; Renjin is the 
interpreter and comes with SciCom. Finally, although SciCom provides a basic interface to 
Renjin similar to RinRuby, a much tighter integration is also possible.
EOF

  gem.authors  = ['Rodrigo Botafogo']
  gem.email    = 'rodrigo.a.botafogo@gmail.com'
  gem.homepage = 'http://github.com/rbotafogo/scicom/wiki'
  gem.license = 'GPL'
  
  gem.add_dependency('mdarray', '~> 0.5')
  gem.add_dependency('state_machine', '~> 1.2', [">= 1.2.0"])

  gem.add_development_dependency('shoulda', "~> 3.5")
  gem.add_development_dependency('simplecov', "~> 0.11")
  gem.add_development_dependency('yard', "~> 0.8")
  gem.add_development_dependency('kramdown', "~> 1.0")

  # ensure the gem is built out of versioned files
  gem.files = Dir['Rakefile', 'version.rb', 'config.rb', '{lib,test}/**/*.rb', 'test/**/*.csv',
                  'test/**/*.xlsx',
                  '{bin,doc,spec,vendor,target,cran}/**/*', 
                  'README*', 'LICENSE*'] # & `git ls-files -z`.split("\0")

  gem.test_files = Dir['test/*.rb']

  gem.platform='java'

end
