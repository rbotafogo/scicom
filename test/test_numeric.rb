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

    end

    #======================================================================================
    #
    #======================================================================================

    should "create a double numeric (single value) in R" do

      R.eval("i1 = 10.2387")
      # the returned value is a Renjin::Vector
      i1 = R.i1
      assert_equal(10.2387, i1.gz)

      # assign to an R variable the Vector returned previously.  The original variable
      # is still valid
      R.assign("i2", i1)
      assert_equal(10.2387, R.i2.gz)
      assert_equal(10.2387, R.i1.gz)

      # type of i2 is a double
      assert_equal("double", R.eval("typeof(i2)").gz)
      # same call can be done easier.  Remember, i2 is defined only in the R namespace.
      assert_equal("double", R.typeof(R.i2).gz)

      # create a double without calling eval.  Method .d creates a double vector with
      # one element. Variable i2 is now defined in the Ruby namespace
      i2 = R.d(345.7789)
      assert_equal("double", i2.typeof)
      assert_equal(345.7789, i2.gz)

    end

    #======================================================================================
    #
    #======================================================================================

    should "create an integer numeric (single value) in R" do

      # Integer nuberic Vectors are created with method .i
      # the returned value is a Renjin::Vector
      my_int = R.i(10)
      assert_equal(10, my_int.gz)
      # method typeof returns the type of this vector
      assert_equal("integer", my_int.typeof)
      
    end

  end
  
end
