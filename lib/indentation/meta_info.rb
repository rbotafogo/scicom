# must not have the word m-o-d-u-l-e above the next line (so that a Regexp can figure out the m-o-d-u-l-e name)
module Indentation
  
  # For more information about meta_info.rb, please see project Foundation, lib/Foundation/meta_info.rb
  
  # SUGGESTION: Treat "Optional" as meaning "can be nil", and define all constants, even if the value happens to be nil.
  
  # Required String
  GEM_NAME = "indentation"
  # Required String
  VERSION = '0.1.1'
  # Optional String or Array of Strings
  AUTHORS = ["Sam Dana"]
  # Optional String or Array of Strings
  EMAILS = ["s.dana@prometheuscomputing.com"]
  # Optional String
  HOMEPAGE = "http://samueldana.github.com/indentation/"
  # Required String
  SUMMARY = %q{A library of extensions to Ruby's Array and String classes that allow indentation manipulation of Strings and Arrays of Strings.}
  # Optional String
  DESCRIPTION = SUMMARY
  
  # Required Symbol
  # This specifies the language the project is written in (not including the version, which is in LANGUAGE_VERSION).
  # A project should only have one LANGUAGE (not including, for example DSLs such as templating languages).
  # If a project has more than one language (not including DSLs), it should be split.
  # TEMPORARY EXCEPTION: see :frankenstein choice below.
  # The reason is that mixing up languages in one project complicates packaging, deployment, metrics, directory structure, and many other aspects of development.
  # Choices are currently:
  #   * :ruby (implies packaging as gem - contains ZERO java code)
  #   * :java (implies packaging as jar, ear, war, sar, etc (depending on TYPE) - contains ZERO ruby code, with exception of meta_info.rb)
  #   * :frankenstein (implies packaging as gem - contains BOTH ruby and java code - will probably deprecate this in favor of two separate projects)
  LANGUAGE = :ruby
  # This differs from Runtime version - this specifies the version of the syntax of LANGUAGE
  LANGUAGE_VERSION = ['> 1.8.1', '< 1.9.3']
  # This is different from aGem::Specification.platform, which appears to be concerned with OS.
  # This defines which implentation of Ruby, Java, etc can be used.
  # Required Hash, in same format as DEPENDENCIES_RUBY.
  # The version part is used by required_ruby_version
  # Allowable keys depend on LANGUAGE. They are in VALID_<language.upcase>_RUNTIMES
  RUNTIME_VERSIONS = {
    :mri => ['> 1.8.1', '< 1.9.3'],
    :jruby => ['1.6.4']
  }
  # Required Symbol
  # Choices are currently:
  #   * :library - reusable functionality, not intended to stand alone
  #   * :utility - intended for use on command line
  #   * :web_app - an application that uses a web browser for it's GUI
  #   * :service - listens on some port. May include command line tools to manage the server.
  #   * :gui - has a Swing, Fox, WXwidget, etc GUI
  TYPE = :library
  
  # Optional Hashes - if nil, presumed to be empty.
  # There may be additional dependencies, for platforms (such as :maglev) other than :mri and :jruby
  # In the case of JRuby platform Ruby code that depends on a third party Java jar, where do we specify that?
  
  # Trying to install this under Ruby 1.8.7 I get:
  #   Error installing MM-0.0.6.gem:
  #   simplecov requires multi_json (~> 1.0.3, runtime)
  # So I have commented out some dependencies.
  # FIX: these dependency collections need to be specific to a LANGUAGE_VERSION. Maybe RUNTIME_VERSIONS as well.
  #      We also need :simplecov => nil, but only on Ruby > 1.8 }
  DEPENDENCIES_RUBY = { }
  DEPENDENCIES_MRI = { }
  DEPENDENCIES_JRUBY = { }
  DEVELOPMENT_DEPENDENCIES_RUBY = { } # test-unit is reccomended but not required (color codes Test::Unit test results)
  DEVELOPMENT_DEPENDENCIES_MRI = { }
  DEVELOPMENT_DEPENDENCIES_JRUBY = { }
  
  # An Array of strings that YARD will interpret as regular expressions of files to be excluded.
  YARD_EXCLUDE = []
  
end