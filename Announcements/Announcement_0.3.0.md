# Announcement

SciCom version 0.3.0 has been released.  SciCom (Scientific Computing)
for Ruby brings the power of R to the Ruby community. SciCom is based
on Renjin, a JVM-based interpreter for the R language for statistical
computing.

R on the JVM
============

Over the past two decades, the R language for statistical computing
has emerged as the de facto standard for analysts, statisticians, and
scientists. Today, a wide range of enterprises – from pharmaceuticals
to insurance – depend on R for key business uses. Renjin is a new
implementation of the R language and environment for the Java Virtual
Machine (JVM), whose goal is to enable transparent analysis of big
data sets and seamless integration with other enterprise systems such
as databases and application servers.

Renjin is still under development, but it is already being used in
production for a number of client projects, and supports most CRAN
packages, including some with C/Fortran dependencies.

SciCom and Renjin
=================

SciCom integrates with Renjin and allows the use of R inside a Ruby
script. In a sense, SciCom is similar to other solutions such as
RinRuby, Rpy2, PipeR, etc. However, since SciCom and Renjin both
target the JVM there is no need to integrate both solutions and there
is no need to send data between Ruby and R, as it all resides in the
same JVM. Further, installation of SciCom does not require the
installation of GNU R; Renjin is the interpreter and comes with
SciCom. Finally, although SciCom provides a basic interface to Renjin
similar to RinRuby, a much tighter integration is also possible (see
examples below).

Whats New
=========


SciCom main properties are
==========================

* Transparently integrates Ruby and R and allows usage of R functions as if they were
Ruby methods on the R class;
* Can load many R packages (http://packages.renjin.org) from Renjin repository;
* Integrates with MDArray allowing multi-dimensional arrays to be slice and cut and
passed to an R script.
* Allows R scripts to access Ruby classes and call Ruby methods transparently;
* Allows R scripts to access Java classes and call Java methods transparently;
* Allows access to R scripts from inside Ruby scripts;

SciCom installation and download
================================
* Install Jruby
* jruby –S gem install scicom

## Home Pages

* SciCom can be downloaded from <http://rubygems.org/gems/scicom>
* GitHub page: <https://github.com/rbotafogo/scicom>
* Wiki: <https://github.com/rbotafogo/scicom/wiki>
* Issues: <https://github.com/rbotafogo/scicom/issues>

## Contributors

Contributors are wellcome!


