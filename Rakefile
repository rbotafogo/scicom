require 'rake/testtask'
require 'jars/installer'
require 'jars/classpath'
require 'rake/javaextensiontask'

require './version'

name = "#{$gem_name}-#{$version}.gem"

task :install_jars do
  Jars::JarInstaller.new.vendor_jars
end

desc 'Compiles extension and run specs'
task :default => [ :compile, :spec ]

spec = eval File.read( 'scicom.gemspec' )

desc 'compile src/main/java/** into target/scicom_support.jar'
Rake::JavaExtensionTask.new("scicom_support", spec) do |ext|
  ext.ext_dir = 'src/main/java'
end

require 'rubygems/package_task'
Gem::PackageTask.new( spec ) do
  desc 'Pack gem'
  task :package => [:install_jars, :compile]
end

rule '.class' => '.java' do |t|
  sh "javac #{t.source}"
end

desc 'Makes a Gem'
task :make_gem do
  sh "gem build #{$gem_name}.gemspec"
end

desc 'Install the gem in the standard location'
task :install_gem => [:make_gem] do
  sh "gem install #{$gem_name}-#{$version}-java.gem"
end

desc 'Make documentation'
task :make_doc do
  sh "yard doc lib/*.rb lib/**/*.rb"
end

desc 'Push project to github'
task :push do
  sh "git push origin master"
end

desc 'Push gem to rubygem'
task :push_gem do
  sh "push #{name} -p $http_proxy"
end

desc 'Counts the number of lines of ruby code'
task :count do
  sh "find . -name '*.rb' | xargs wc -l"
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/complete.rb']
  t.ruby_opts = ["--server", "-Xinvokedynamic.constants=true", "-J-Xmn512m", 
                 "-J-Xms1024m", "-J-Xmx1024m"]
  t.verbose = true
  t.warning = true
end

