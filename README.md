Announcement
============

SciCom (Scientific Computing) for Ruby brings the power of R to the Ruby community. SciCom 
is based on Renjin, a JVM-based interpreter for the R language for statistical computing.

R on the JVM
------------

Over the past two decades, the R language for statistical computing has emerged as the de 
facto standard for analysts, statisticians, and scientists. Today, a wide range of 
enterprises – from pharmaceuticals to insurance – depend on R for key business uses. Renjin 
is a new implementation of the R language and environment for the Java Virtual Machine (JVM),
whose goal is to enable transparent analysis of big data sets and seamless integration with 
other enterprise systems such as databases and application servers.

Renjin is still under development, but it is already being used in production for a number 
of client projects, and supports most CRAN packages, including some with C/Fortran 
dependencies.

SciCom and Renjin
-----------------

SciCom integrates with Renjin and allows the use of R inside a Ruby script. In a sense, 
SciCom is similar to other solutions such as RinRuby, Rpy2, PipeR, etc. However, since 
SciCom and Renjin both target the JVM there is no need to integrate both solutions and 
there is no need to send data between Ruby and R, as it all resides in the same JVM. 
Further, installation of SciCom does not require the installation of GNU R; Renjin is the 
interpreter and comes with SciCom. Finally, although SciCom provides a basic interface to 
Renjin similar to RinRuby, a much tighter integration is also possible.

SciCom and Renjin Limitations
------------------------------

Renjin is in development and still has some limitations

  + Renjin does not allow dynamic loading of libaries.  My understanding is that Renjin 
  developers are actually working on a new version on which loading of libraries will be
  possible.
  + Renjin does not implement any of the graphical libaries such as plot or ggplot. We
  hope that this limitation will be solved not by implementing those libraries but by the
  use of Ruby libraries from SciRuby such as NyaPlot (https://github.com/domitry/nyaplot) 
  or daru (https://github.com/v0dro/daru).
  

SciCom installation and download:
==================================

  + Install Jruby
  + jruby –S gem install scicom

SciCom Homepages:
==================

  + http://rubygems.org/gems/scicom
  + https://github.com/rbotafogo/scicom/wiki

Contributors:
=============
Contributors are welcome.

SciCom History:
================

  + 19/11/2014: Version 0.2.2 - Printing in Jirb
  + 17/11/2014: Version 0.2.1 - Added MDArray dependency
  + 17/11/2014: Version 0.2.0 - Most R functionality available to SciCom	
  + 21/06/2014: Version 0.0.1 - Initial release
