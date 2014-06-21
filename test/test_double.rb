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

      # creating two distinct instances of SciCom
      @r1 = R.new
      @r2 = R.new

    end

#=begin
    #======================================================================================
    #
    #======================================================================================

    should "create a double (single value) in R" do

      @r1.eval("i1 = 10.2387")
      # the returned value is an MDArray and all methods on MDArray can be called
      i1 = @r1.i1

      # by default type is double
      assert_equal("double", i1.type_name)

      # i1 from r2 should not interfere with i1 from r1
      @r2.i1 = 20.18 # store data in R engine r2
      r2_i1 = @r2.i1 # retrive i1 from R engine r2

      assert_equal(10.2387, i1[0])
      assert_equal(20.18, r2_i1[0])

      # assign to an R variable the MDArray returned previously.  The original variable
      # is still valid
      @r1.assign("i2", i1)
      assert_equal(10.2387, @r1.i2)
      assert_equal(10.2387, @r1.i1)

      # p @r1.eval("typeof(i2)")

    end

    #======================================================================================
    #
    #======================================================================================

    should "make MDArrays returned by R immutable" do

      i1 = @r1.eval("i1 = 10.2387")

      assert_raise ( RuntimeError ) { i1[0] = 20 }
      assert_raise ( RuntimeError ) { i1.set(0, 20) }
      assert_raise ( RuntimeError ) { i1.set_next(20) }

    end

    #======================================================================================
    #
    #======================================================================================

    should "cast an R object to different types" do

      i1 = @r1.eval("i1 = 10.2387")

      # double cannot be converted to boolean
      assert_raise ( RuntimeError ) { i1.get_as(:boolean) }

      assert_equal(10, i1.get_as(:byte))
      assert_equal(10, i1.get_as(:char))
      assert_equal(10, i1.get_as(:short))
      assert_equal(10, i1.get_as(:int))
      assert_equal(10, i1.get_as(:long))
      assert_equal(10.238699913024902, i1.get_as(:float))
      assert_equal(10.2387, i1.get_as(:double))
      assert_equal("10.2387", i1.get_as(:string))

      # logical, raw_logical and complex are not types known to MDArray
      # assert_equal(true, i1.get_as(:logical))
      # assert_equal(1, i1.get_as(:raw_logical))
      # assert_equal(Complex(10.2387, 0), i1.get_as(:complex))

    end

    #======================================================================================
    #
    #======================================================================================

    should "be able to create a double vector in R" do

      vec = @r1.eval("c(1, 2, 3, 4)")

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

      vec2 = @r1.eval("c(1, NA, 3, 4)")
      vec2.print

      vec3 = @r1.eval("c(1, NaN, 3, 4)")
      vec3.print

    end
#=end
    #======================================================================================
    #
    #======================================================================================

    should "receive 1 Dimensional MDArrays in R" do
      
      vec = MDArray.double([6], [1, 3, 5, 7, 11, 13])
      # vec is just a normal MDArray that can be changed at anytime
      vec[0] = 2

      @r1.prime = vec

      # now vec is immutable, since it is now in Renjin and Renjin requires an immutable
      # vector
      assert_raise ( RuntimeError ) { vec[0] = 1 }

      vec2 = @r1.eval("print(prime)")
      vec2.print

      assert_raise ( RuntimeError ) { vec2[1] = 7 }
      
    end
    
  end
  
end
