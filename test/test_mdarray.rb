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
    #
    #--------------------------------------------------------------------------------------

    should "convert a vector to an MDArray" do

      # Method 'get' converts a Vector to an MDArray
      vec = i3.get
      assert_equal(true, vec.is_a?(MDArray))
      assert_equal("int", vec.type)

      # For consistancy with R notation one can also call as__mdarray to convert a 
      # vector to an MDArray
      vec2 = i3.as__mdarray
      assert_equal(true, vec2.is_a?(MDArray))
      assert_equal("int", vec2.type)

      # Now 'vec' is an MDArray and its elements can be accessed through indexing, but
      # this time the first index is 0, and the element is an actual number
      assert_equal(10, vec[0])

      # Convert vector to an MDArray
      array = vec2.get
      
      # Use array as any other MDArray...
      array.each do |elmt|
        p elmt
      end

      # ... although there is no need to convert a vector to an MDArray to call each:
      # the each method is also defined for vectors
      vec1.each do |elmt|
        p elmt
      end
      
    end

=begin

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

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

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

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

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

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

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "assign MDArray to R transparently" do

      # MDArray instances created in Ruby namespace can also be access in the R
      # namespace with the r method:
      array = MDArray.typed_arange(:double, 18)
      R.eval("print(#{array.r})")

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "create MDArrays from R methods" do

      # R.c creates a MDArray.  In general it will be a double MDArray
      res = R.c(2, 3, 4, 5)
      assert_equal("double", res.type)
      assert_equal(4, res.size)

      # to create an int MDArray with R.c, all elements need to be integer.  To create an
      # int we need R.i method
      res = R.c(R.i(2), R.i(3), R.i(4))
      assert_equal("int", res.type)
      assert_equal(3, res.size)

      # using == method from MDArray.  It returns an boolean MDArray
      res = (R.c(2, 3, 4) == R.c(2, 3, 4))
      assert_equal("boolean", res.type)

      # array multiplication
      (R.c(2, 3, 4) * R.c(5, 6, 7)).pp

      # A sequence also becomes an MDArray
      res = R.seq(10, 40)
      res.print

      res = R.rep(R.c(1, 2, 3), 3)
      res.print

    end

    #======================================================================================
    #
    #======================================================================================

    should "be able to create a double vector in R" do

      vec = R.c(1, 2, 3, 4)

      
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


    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "use MDArray in R" do
      
      # create a double MDArray
      vec  = MDArray.typed_arange(:double, 12)
      vec.print

      # assign the MDArray to an R vector "my.vec"
      R.my__vec = vec

      # print R's "my.vec"
      R.eval("print(my.vec)")

      # use the .r method in MDArray's to get the MDArray value in R
      R.eval("print(#{vec.r})")

      # Passing an MDArray without assigning it in a R vector is also possible
      R.eval("print(#{MDArray.typed_arange(:double, 5).r})")

    end

  end

end
