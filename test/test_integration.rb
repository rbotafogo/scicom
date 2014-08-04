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

    #======================================================================================
    #
    #======================================================================================

    setup do 

      # creating a new instance of Renjin
      @r1 = R.new

    end

    #======================================================================================
    #
    #======================================================================================

    should "be able to call built-in R numeric functions" do

      # All R numeric functions are available to be called directly from a Ruby script.
      # Note that a numeric function in R always returns a vector (MDArray), in that case, 
      # of size 1, so we need to index the result with [0].
      assert_equal(20.5, R.abs(-20.5))
      assert_equal(Math.sqrt(84), R.sqrt(84)[0])
      assert_equal(4, R.ceiling(3.475)[0])
      assert_equal(3, R.floor(3.475)[0])
      assert_equal(5, R.trunc(5.99)[0])
      assert_equal(3.46, R.round(3.457, digits: 2)[0])
      assert_equal(3.5, R.signif(3.475, digits: 2)[0])
      assert_equal(Math.cos(10), R.cos(10)[0])
      assert_equal(Math.sin(0.53), R.sin(0.53)[0])
      assert_equal(Math.tan(0.53), R.tan(0.53)[0])
      assert_equal(Math.acos(0.53), R.acos(0.53)[0])
      assert_equal(Math.cosh(0.53), R.cosh(0.53)[0])
      assert_equal(Math.acosh(1), R.acosh(1)[0])
      assert_equal(Math.log(25.45), R.log(25.45)[0])
      # Math.log10 = 1.4056877866727773
      # R.log10    = 1.4056877866727775
      # assert_equal(Math.log10(25.45), R.log10(25.45)[0])
      assert_equal(Math.exp(2.43), R.exp(2.43)[0])

    end

    #======================================================================================
    #
    #======================================================================================

    should "be able to call built-in R character functions" do

      R.abs(-20.5)
      R.substr("abcdef", 2, 4)
      R.rnorm(30, m: 0, sd: 1)

=begin
substr(x, start=n1, stop=n2)	Extract or replace substrings in a character vector.
x <- "abcdef" 
substr(x, 2, 4) is "bcd" 
substr(x, 2, 4) <- "22222" is "a222ef"
grep(pattern, x , ignore.case=FALSE, fixed=FALSE)	Search for pattern in x. If fixed =FALSE then pattern is a regular expression. If fixed=TRUE then pattern is a text string. Returns matching indices.
grep("A", c("b","A","c"), fixed=TRUE) returns 2
sub(pattern, replacement, x, ignore.case =FALSE, fixed=FALSE)	Find pattern in x and replace with replacement text. If fixed=FALSE then pattern is a regular expression.
If fixed = T then pattern is a text string. 
sub("\\s",".","Hello There") returns "Hello.There"
strsplit(x, split)	Split the elements of character vector x at split. 
strsplit("abc", "") returns 3 element vector "a","b","c"
paste(..., sep="")	Concatenate strings after using sep string to seperate them.
paste("x",1:3,sep="") returns c("x1","x2" "x3")
paste("x",1:3,sep="M") returns c("xM1","xM2" "xM3")
paste("Today is", date())
toupper(x)	Uppercase
tolower(x)	Lowercase
=end

    end

    #======================================================================================
    #
    #======================================================================================

    should "be able to call built-in R statistical probability functions" do

      # cumulative normal probability for q (area under the normal curve to the right of q)

=begin
      assert_equal(0.975, R.pnorm(1.96))

dnorm(x)	normal density function (by default m=0 sd=1)
# plot standard normal curve
x <- pretty(c(-3,3), 30)
y <- dnorm(x)
plot(x, y, type='l', xlab="Normal Deviate", ylab="Density", yaxs="i")
qnorm(p)	normal quantile. 
value at the p percentile of normal distribution 
qnorm(.9) is 1.28 # 90th percentile
rnorm(n, m=0,sd=1)	n random normal deviates with mean m 
and standard deviation sd. 
#50 random normal variates with mean=50, sd=10
x <- rnorm(50, m=50, sd=10)
dbinom(x, size, prob)
pbinom(q, size, prob)
qbinom(p, size, prob)
rbinom(n, size, prob)	binomial distribution where size is the sample size 
and prob is the probability of a heads (pi) 
# prob of 0 to 5 heads of fair coin out of 10 flips
dbinom(0:5, 10, .5) 
# prob of 5 or less heads of fair coin out of 10 flips
pbinom(5, 10, .5)
dpois(x, lamda)
ppois(q, lamda)
qpois(p, lamda)
rpois(n, lamda)	poisson distribution with m=std=lamda
#probability of 0,1, or 2 events with lamda=4
dpois(0:2, 4)
# probability of at least 3 events with lamda=4 
1- ppois(2,4)
dunif(x, min=0, max=1)
punif(q, min=0, max=1)
qunif(p, min=0, max=1)
runif(n, min=0, max=1)	uniform distribution, follows the same pattern 
as the normal distribution above. 
#10 uniform random variates
x <- runif(10)
=end

    end
=begin
    #======================================================================================
    #
    #======================================================================================

    should "integrate Ruby sequence with R sequence" do
      
      seq = R.seq(2, 10)

      res = R.eval <<EOF
      print(#{seq.r});
      print(#{seq.r});
print(ls());
EOF

      # remove the variable from R
      seq.destroy

      R.eval("print(ls())")

    end

    #======================================================================================
    #
    #======================================================================================

    should "integrate MDArray with R vector" do
      
      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 60)
      # MDArray is stored in row-major order
      arr.reshape!([5, 3, 4])
      # arr.print

      R.eval <<EOF
      print(#{arr.r});
      vec = #{arr.r};
print(vec);
print(vec[1, 1, 1]);

EOF

    end
=end
  end

end
