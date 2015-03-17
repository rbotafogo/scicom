require 'rbconfig'

##########################################################################################
# Configuration. Remove setting before publishing Gem.
##########################################################################################

# set to true if development environment
$DVLP = true

# Set to 'cygwin' when in cygwin
$ENV = 'cygwin'

# Set development dependency: those are gems that are also in development and thus not
# installed in the gem directory.  Need a way of accessing them
$DEPEND=["MDArray"]

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
  # Return the cygpath of a path
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    `cygpath -a -p -m #{path}`.tr("\n", "")
  end
  
else
  
  #---------------------------------------------------------------------------------------
  # Return  the path
  #---------------------------------------------------------------------------------------
  
  def set_path(path)
    path
  end
  
end

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

# Add cran directory to the search path
mklib(SciCom.cran_dir, false)
