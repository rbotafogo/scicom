require 'rbconfig'
require 'java'

#
# In principle should not be in this file.  The right way of doing this is by executing
# bundler exec, but I don't know how to do this from inside emacs.  So, should comment
# the next line before publishing the GEM.  If not commented, this should be harmless
# anyway.
#

begin
  require 'bundler/setup'
rescue LoadError
end

=begin
##########################################################################################
# Configuration. Remove setting before publishing Gem.
##########################################################################################

# set to true if development environment
$DVLP = true

# Set to 'cygwin' when in cygwin
$ENV = 'cygwin'

# Set development dependency: those are gems that are also in development and thus not
# installed in the gem directory.  Need a way of accessing them if we are in development
# otherwise gem install will install the dependency
if $DVLP
  $DEPEND=["SciCom", "MDArray"]
end
=end

##########################################################################################

# the platform
@platform = 
  case RUBY_PLATFORM
  when /mswin/ then 'windows'
  when /mingw/ then 'windows'
  when /bccwin/ then 'windows'
  when /cygwin/ then 'windows-cygwin'
  when /java/
    require 'java' #:nodoc:
    if java.lang.System.getProperty("os.name") =~ /[Ww]indows/
      'windows-java'
    else
      'default-java'
    end
  else 'default'
  end

=begin
#---------------------------------------------------------------------------------------
# Add path to load path
#---------------------------------------------------------------------------------------

def mklib(path, home_path = true)
  
  if (home_path)
    lib = path + "/lib"
  else
    lib = path
  end
  
  $LOAD_PATH << lib
  
end

##########################################################################################
# Prepare environment to work inside Cygwin
##########################################################################################

if $ENV == 'cygwin'
  
  #---------------------------------------------------------------------------------------
  # Return the cygpath (windows format) of a path in POSIX format, i.e., /home/...
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    `cygpath -a -p -m #{path}`.tr("\n", "")
  end
  
else
  
  #---------------------------------------------------------------------------------------
  # Return the given path.  When not in cygwin then just use the given path
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    path
  end
  
end
=end

#---------------------------------------------------------------------------------------
# Set the project directories
#---------------------------------------------------------------------------------------

class SciCom

  @home_dir = File.expand_path File.dirname(__FILE__)

  class << self
    attr_reader :home_dir
  end

  @project_dir = SciCom.home_dir + "/.."
  @doc_dir = SciCom.home_dir + "/doc"
  @lib_dir = SciCom.home_dir + "/lib"
  @src_dir = SciCom.home_dir + "/src"
  @target_dir = SciCom.home_dir + "/target"
  @test_dir = SciCom.home_dir + "/test"
  @vendor_dir = SciCom.home_dir + "/vendor"
  @cran_dir = SciCom.home_dir + "/cran"
  
  class << self
    attr_reader :project_dir
    attr_reader :doc_dir
    attr_reader :lib_dir
    attr_reader :src_dir
    attr_reader :target_dir
    attr_reader :test_dir
    attr_reader :vendor_dir
    attr_reader :cran_dir
  end

  @build_dir = SciCom.src_dir + "/build"

  class << self
    attr_accessor :build_dir
  end

  @classes_dir = SciCom.build_dir + "/classes"

  class << self
    attr_reader :classes_dir
  end

end

=begin
#---------------------------------------------------------------------------------------
# Set dependencies
#---------------------------------------------------------------------------------------

def depend(name)
  
  dependency_dir = SciCom.project_dir + "/" + name
  mklib(dependency_dir)
  
end

##########################################################################################
# If development
##########################################################################################

if ($DVLP == true)

  mklib(SciCom.home_dir)
  
  # Add dependencies here
  # depend(<other_gems>)
  $DEPEND.each do |dep|
    depend(dep)
  end if $DEPEND

  #----------------------------------------------------------------------------------------
  # If we need to test for coverage
  #----------------------------------------------------------------------------------------
  
  if $COVERAGE == 'true'
  
    require 'simplecov'
    
    SimpleCov.start do
      @filters = []
      add_group "SciCom", "lib/scicom"
    end
    
  end

end


# Add cran directory to the $LOAD_PATH search path
mklib(SciCom.cran_dir, false)
=end

##########################################################################################
# Load necessary jar files
##########################################################################################

Dir["#{SciCom.vendor_dir}/*.jar"].each do |jar|
  require jar
end

Dir["#{SciCom.target_dir}/*.jar"].each do |jar|
  require jar
end
