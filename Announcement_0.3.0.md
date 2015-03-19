# Announcement

SciCom version 0.2.3.1 has been released.  SciCom (Scientific Computing)
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

Version 3.0.0 adds two new methods to SciCom, install\_\_package and library.
Method install\_\_package will install a new package from Renjin package repository
and method library loads the package.  This is still a simple implementation,
so, every time install__package is called it will download the package again, even
if the package was already installed.  There is no way of controlling the
package version; it will always download the latest available version in the repository.

SciCom main properties are
==========================

* Allows access to R scripts from inside Ruby scripts;
* Allows for R scripts written in R by accessing method ‘R.eval’;
* Allows R scripts to be embedded inside here docs in Ruby;
* Creates a new ‘language’ that allows regular Ruby scripts to call R methods in such a way that programmers can be unaware of the fact that they are using R (although, of course, knowing R is of great benefit).;
* ntegrates with MDArray allowing multi-dimensional arrays to be slice and cut and passed to an R script.

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


