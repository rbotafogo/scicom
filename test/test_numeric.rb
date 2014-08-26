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

    should "create a numeric (single value) in R" do

      R.eval("i1 = 10.2387")
      # the returned value is an MDArray and all methods on MDArray can be called
      i1 = R.i1

      # by default type is double
      assert_equal("double", i1.type)
      assert_equal(10.2387, i1[0])
      assert_equal(10.2387, i1.z)

      # assign to an R variable the MDArray returned previously.  The original variable
      # is still valid
      R.assign("i2", i1)
      assert_equal(10.2387, R.i2)
      assert_equal(10.2387, R.i1)

      # Returned value is a string MDArray
      R.eval("typeof(i2)").pp

      # create a double with calling eval with a string
      i2 = R.d(345.7789)
      assert_equal(345.7789, i2.z)

      # The same can be done for integer type.  However, creating an integer in harder as
      # by default a double is created
      my_int = R.i(10)
      assert_equal(10, my_int.z)
      assert_equal("int", my_int.type)
      
    end

    #======================================================================================
    #
    #======================================================================================

    should "guarantee that MDArrays returned by R are immutable" do

      # can pass a double to eval.  It will be evaluated to a double vector
      i1 = R.eval("10.387")

      assert_raise ( RuntimeError ) { i1[0] = 20 }
      assert_raise ( RuntimeError ) { i1.set(0, 20) }
      assert_raise ( RuntimeError ) { i1.set_next(20) }

    end

    #======================================================================================
    #
    #======================================================================================

    should "cast MDArray numeric value to different types" do

      i1 = R.d(10.2387)

      # double cannot be converted to boolean
      assert_raise ( RuntimeError ) { i1.get_as(:boolean) }

      # method .get_as returns the current element of MDArray, which, in this case, is the
      # first element
      assert_equal(10, i1.get_as(:byte))
      assert_equal(10, i1.get_as(:char))
      assert_equal(10, i1.get_as(:short))
      assert_equal(10, i1.get_as(:int))
      assert_equal(10, i1.get_as(:long))
      assert_equal(10.238699913024902, i1.get_as(:float))
      assert_equal(10.2387, i1.get_as(:double))
      assert_equal("10.2387", i1.get_as(:string))

    end

    #======================================================================================
    #
    #======================================================================================

    should "be able to create a double vector in R" do

      vec = R.c(1, 2, 3, 4)

      # The vector created in R returns as a MDArray in Ruby and can be treated as such
      assert_equal("1.0 2.0 3.0 4.0 ", vec.to_string)

      # All methods on MDArray can be called normally
      vec.reset_statistics
      assert_equal(2.5, vec.mean)
      assert_equal(1.118033988749895, vec.standard_deviation)
      assert_equal("11.0 12.0 13.0 14.0 ", (vec + 10).to_string)

    end

    #======================================================================================
    # Need to check how MDArray works exactly with NaN
    #======================================================================================

    should "work with NA and NaN in double vectors" do

      vec2 = R.c(1, NA, 3, 4)
      vec2.print

      vec3 = R.c(1, NaN, 3, 4)
      vec3.print

    end

    #======================================================================================
    #
    #======================================================================================

    should "receive 1 Dimensional MDArrays in R" do
      
      vec = MDArray.double([6], [1, 3, 5, 7, 11, 13])
      # vec is just a normal MDArray that can be changed at anytime
      vec[0] = 2

      R.prime = vec

      # now vec is immutable, since it is now in Renjin and Renjin requires an immutable
      # vector
      assert_raise ( RuntimeError ) { vec[0] = 1 }

      vec2 = R.eval("print(prime)")
      vec2.print

      assert_raise ( RuntimeError ) { vec2[1] = 7 }
      
    end
    
  end
  
end
