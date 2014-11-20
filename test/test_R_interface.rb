# -*- coding: utf-8 -*-

##########################################################################################
# Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
# OR MODIFICATIONS.
##########################################################################################

require 'rubygems'
require "test/unit"
require 'shoulda'

require 'env'
require 'scicom'

class SciComTest < Test::Unit::TestCase

  context "R environment" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end

    #--------------------------------------------------------------------------------------
    # Creating a variable in R and assign a value to it.  In this case assign the NULL 
    # value.  There are two ways of assign variables in R, through method assign or with
    # the '=' method.  To retrieve an R variable just acess it in the R namespace.
    #--------------------------------------------------------------------------------------

    should "use R.eval to evaluate an R expression" do

      # The NULL value

      # variable null is NULL.  Variable 'null' exists in the R namespace and can be 
      # access normally in a call to 'eval'
      R.eval("null = NULL")
      R.eval("print(null)")

      # Basic integration with R can always be done by calling eval and passing it a valid
      # R expression.
      R.eval("r.i = 10L")
      R.eval("print(r.i)")

      R.eval("vec = c(10, 20, 30, 40, 50)")
      R.eval("print(vec)")
      R.eval("print(vec[1])")

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "use assign and pull to set and get data from R" do

      # Using method assign, to assign NULL to variable 'null' in R namespace.
      R.assign("null", nil)
      assert_equal(nil, R.null)
      R.eval("print(null)")

      # Variable 'res' is available only in the Ruby namespace and not in the R namespace.
      # a NULL object in R is converted to nil in Ruby.
      res = R.pull("null")
      assert_equal(nil, res)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assing value to R variables as Ruby attributes" do

      # Assign a value to an R variable, 'n2'.  
      R.n2 = nil
      assert_equal(nil, R.n2)

      # One can access variables created in R namespace by using R.<var>.  Variable in
      # R that have a '.' such as 'r.i3' need to have the '.' substituted by '__'
      R.eval("r.i3 = 10.235")
      R.r__i3.pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "accept here docs " do

      R.eval <<EOF
        r.i2 = 10L
        print(r.i2)  
EOF

      # Variables created in Ruby can be accessed in an eval clause:
      val = "10L"
      R.eval <<EOF
        r.i3 = #{val}
        print(r.i3)
EOF

      R.eval <<EOF

        # This dataset comes from Baseball-Reference.com.
        baseball = read.csv("baseball.csv")
        # str is bogus on Renjin
        # str(data)

        # prints the index of maximum and minimum years for the dataset
        print(which.max(baseball$Year))
        print(which.min(baseball$Year))

        # Lets look at the data available for Momeyball.
        moneyball = subset(baseball, Year < 2002)

        # Let's see if we can predict the number of wins, by lookin at
        # runs allowed (RA) and runs scored (RS).  RD is the runs difference.
        # We are making a linear model from predicting wins (W) based on RD
        moneyball$RD = moneyball$RS - moneyball$RA
        WinsReg = lm(W ~ RD, data=moneyball)
        print(summary(WinsReg))
EOF

    end

  end

end

# Result of calling print(summary(WinsRed)):
#
# Call:
# lm(data = moneyball, formula = W ~ RD)
#
# Residuals:
#    Min      1Q  Median      3Q     Max
# -14,266  -2,651   0,123   2,936  11,657
#
# Coefficients:
#            Estimate   Std. Error t value    Pr(>|t|)             
# (Intercept) 80,881     0,131      616,675    <0         ***       
#          RD 0,106      0,001       81,554    <0         ***       
# ---
# Signif. codes:  0 '***' 0,001 '**' 0,01 '*' 0,05 '.' 0,1 ' ' 1 
#
# Residual standard error: 3,939 on 900 degrees of freedom
# Multiple R-squared: 0,8808,	Adjusted R-squared: 0,8807 
# F-statistic: 6.650,9926 on 1 and 900 DF,  p-value: < 0 
