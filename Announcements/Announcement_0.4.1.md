# Announcement

SciCom version 0.4.1 has been released.  SciCom (Scientific Computing)
for Ruby brings the power of R to the Ruby community. SciCom is based
on Renjin, a JVM-based interpreter for the R language for statistical
computing.  SciCom allows for transparently calling R functions as
if they were Ruby methods on the R class.  Here is an example:

      # This dataset comes from Baseball-Reference.com.
      baseball = R.read__csv("baseball.csv")
      
      # Lets look at the data available for Moneyball.
      moneyball = baseball.subset(baseball.Year < 2002)

      # Let's see if we can predict the number of wins, by looking at
      # runs allowed (RA) and runs scored (RS).  RD is the runs difference.
      # We are making a linear model for predicting wins (W) based on RD
      moneyball.RD = moneyball.RS - moneyball.RA
      wins_reg = R.lm("W ~ RD", data: moneyball)
      wins_reg.summary.pp

The result of running this script on SciCom is:

    Call:
    lm(data = sc_eb64235e698bad2c, formula = "W ~ RD")

    Residuals:
        Min      1Q  Median      3Q     Max
    -14,266  -2,651   0,123   2,936  11,657

    Coefficients:
                Estimate   Std. Error t value    Pr(>|t|)             
    (Intercept) 80,881     0,131      616,675    <0         ***       
             RD 0,106      0,001       81,554    <0         ***       
    ---
    Signif. codes:  0 '***' 0,001 '**' 0,01 '*' 0,05 '.' 0,1 ' ' 1 

    Residual standard error: 3,939 on 900 degrees of freedom
    Multiple R-squared: 0,8808,	Adjusted R-squared: 0,8807 
    F-statistic: 6.650,9926 on 1 and 900 DF,  p-value: < 0 


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

* Support for Renjin version 0.8
* Support for JRuby 9k
* R scripts can call Ruby transparently
* New wiki page: https://github.com/rbotafogo/scicom/wiki/A-(not-so)-Short-Introduction-to-SciCom

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
* Allows interaction with data wherever it's stored, whether that's on disk, in a
remote database, or in the cloud;
* Improves performance over GnuR using techniques such as deferred computation, implicit
paralellism, and just-in-time compilation;
* Allows deployment to Platform-as-a-Service providers like Google Appengine, Amazon
Beanstalk or Heroku.

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

