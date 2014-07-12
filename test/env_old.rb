require 'rbconfig'

# Home directory for SciCom.
if $INSTALL_DIR
  $SCICOM_HOME_DIR = $INSTALL_DIR
else
  $SCICOM_HOME_DIR = ".."
end  

# SciCom Test directory
$SCICOM_TEST_DIR = "./scicom"

# Tmp directory
$TMP_TEST_DIR = "./tmp"

# Need to change this variable before publication
$SCICOM_ENV = 'cygwin'

##########################################################################################
# If we need to test for coverage
##########################################################################################

if $COVERAGE == 'true'

  require 'simplecov'
  
  SimpleCov.start do
    @filters = []
    add_group "SCICOM", "lib/scicom"
  end

end

##########################################################################################
# Prepare environment to work inside Cygwin
##########################################################################################

if $SCICOM_ENV == 'cygwin'

  # RbConfig::CONFIG['host_os'] # returns mswin32 on Windows, for example
  # p Config::CONFIG
  
  #---------------------------------------------------------------------------------------
  # Return the cygpath of a path
  #---------------------------------------------------------------------------------------

  def cygpath(path)
    `cygpath -a -p -m #{path}`.tr("\n", "")
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
    
    $LOAD_PATH << `cygpath -p -m #{lib}`.tr("\n", "")
    
  end
      
  mklib($SCICOM_HOME_DIR)

  $SCICOM_TEST_DIR = cygpath($SICOM_TEST_DIR)

else

  def cygpath(path)
    path
  end

end
