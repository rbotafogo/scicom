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

      # Extract or replace substrings in a character vector.
      x = "abcdef"
      assert_equal("bcd", R.substr(x, 2, 4)[0])

      # Returns a logical array vector
      vec = R.c(TRUE, TRUE, FALSE)
      vec = R.c(true, true, false)

      # returns a DoubleMDArray.  NA in MDArray is NaN.  There is no difference
      vec = R.c(NaN, NA, EPSILON)
      vec.print

      # grep(pattern, x, ignore.case=FALSE, fixed=FALSE).  Search for pattern in x. 
      # If fixed = FALSE then pattern is a regular expression. If fixed = TRUE then pattern 
      # is a text string. Returns matching indices.
      res = R.grep("A", R.c("b","A","c"), fixed: TRUE)
      assert_equal(2, res[0])

      # Split the elements of character vector x at split. 
      # Returns a ListVector
      split = R.strsplit(x, "")	

      # returns c("x1","x2" "x3")
      # Method in R is called as paste("x", 1:3, sep = "")
      str = R.paste("x", (1..3), sep: "") 
      str.print
      
      # returns c("xM1","xM2" "xM3")
      # Method in R is called as paste("x", 1:3, sep = "M")
      str = R.paste("x", (1..3), sep: "M") 
      str.print

      # date is a Closure
      date = R.date()

      # str = R.paste("Today is", R.date())
      str.print

      str = R.toupper("this is a string")
      assert_equal("THIS IS A STRING", str[0])

      str = R.tolower("THIS IS ALSO A STRING")
      assert_equal("this is also a string", str[0])

      # R.sub(pattern, replacement, x, ignore.case = FALSE, fixed = FALSE)	
      # Find pattern in x and replace with replacement text. If fixed=FALSE then pattern is a 
      # regular expression.  If fixed = TRUE then pattern is a text string. 
      # returns "Hello.There"
      str = R.sub("\\\\s",".","Hello There")
      assert_equal("Hello.There", str[0])

=begin
x <- "abcdef" 
substr(x, 2, 4) <- "22222" is "a222ef"
=end

    end

    #======================================================================================
    #
    #======================================================================================

    should "be able to call built-in R statistical probability functions" do

      # By prefixing a "d" to the function name in the table above, you can get probability 
      # density values (pdf). By prefixing a "p", you can get cumulative probabilities (cdf). 
      # By prefixing a "q", you can get quantile values. By prefixing an "r", you can get 
      # random numbers from the distribution. I will demonstrate using the normal distribution.

      # cumulative normal probability for q (area under the normal curve to the right of q)
      assert_equal(0.975, R.pnorm(1.96))

      # The dnorm( ) function returns the height of the normal curve at some value along the 
      # x-axis. 
      assert_equal(0.24197072451914337, R.dnorm(1)[0])

      # The pnorm( ) function is the cumulative density function or cdf. It returns the area 
      # below the given value of "x",
      assert_equal(0.841344746068543, R.pnorm(1)[0])

      # Once again, the defaults for mean and sd are 0 and 1 respectively. These can be set 
      # to other values as in the case of dnorm( ). To find the area above the cutoff x-value, 
      # either subtract from 1, or set the "lower.tail=" option to FALSE... 
      assert_equal(0.15865525393145696, 1 - R.pnorm(1)[0])
      assert_equal(0.15865525393145696, R.pnorm(1, "lower.tail" => FALSE))

      # To get quantiles or "critical values", you can use the qnorm( ) function as in the 
      # following examples... 
      # p = .05, one-tailed (upper)
      assert_equal(1.644854, R.qnorm(0.95))

      # p = .05, two-tailed
      R.qnorm(R.c(0.025,0.975)).print

      # deciles from the unit normal dist.
      R.qnorm(R.seq(0.1,0.9,0.1)).print

      # area below t = 2.101, df = 8
      assert_equal(0.9655848143495498, R.pt(2.101, df: 8)[0])

      # critical value of chi square, df = 1
      assert_equal(3.8414588206939566, R.qchisq(0.95, df: 1)[0])

      R.qf(R.c(0.025,0.975), df1: 3, df2: 12).print

      # a discrete binomial probability
      assert_equal(0.010843866711637968, R.dbinom(60, size: 100, prob: 0.5)[0])

      # Random numbers are generated from a given distribution like this... 

      # 9 uniformly distributed random nos.
      R.runif(9).print

      # 9 normally distributed random nos.
      R.rnorm(9).print

      # 9 t-distributed random nos.
      R.rt(9, df: 10).print

      R.eval("print(quantile(rivers))")
      quant = R.quantile(:rivers)
      quant.print
      summary = R.summary(:rivers)
      summary.print

      # quintiles
      quint = R.quantile(:rivers, probs: R.seq(0.2,0.8,0.2))
      quint.print

      # deciles
      dec = R.quantile(:rivers, probs: R.seq(0.1,0.9,0.1))
      dec.print

      # And then there is the "type=" option. It turns out there is some disagreement among 
      # different sources as to just how quantiles should be calculated from an empirical 
      # distribution. R doesn't take sides. It gives you nine different methods! Pick the 
      # one you like best by setting the "type=" option to a number between 1 and 9. Here 
      # are some details (and more are available on the help page): type=2 will give the results 
      # most people are taught to calculate in an intro stats course, type=3 is the SAS 
      # definition, type=6 is the Minitab and SPSS definition, type=7 is the default and the 
      # S definition and seems to work well when the variable is continuous.

      # deciles - Don't see any difference, shoud there be?
      dec = R.quantile(:rivers, probs: R.seq(0.1,0.9,0.1), type: 1)
      dec.print

      dec = R.quantile(:rivers, probs: R.seq(0.1,0.9,0.1), type: 2)
      dec.print

      dec = R.quantile(:rivers, probs: R.seq(0.1,0.9,0.1), type: 7o)
      dec.print

=begin


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
