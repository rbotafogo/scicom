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

      # creating two distinct instances of SciCom
      @r1 = R.new
      @r2 = R.new

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create Renjin vectors" do

      arr = MDArray.typed_arange(:double, 12)
      arr.reshape!([4, 3])
      # arr.print

      vector = R.build_vector(arr)
      (0...arr.size).each do |index|
        vector.getElementAsDouble(index)
      end

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 60)
      # MDArray is stored in row-major order
      arr.reshape!([5, 3, 4])
      # arr.print
      
      vector = R.build_vector(arr)
      (0...arr.size).each do |index|
        vector.getElementAsDouble(index)
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 2D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 12)
      arr.reshape!([4, 3])
      # arr.print

      # assign MDArray to R vector.  MDArray shape is converted to R shape: two dimensions
      # are identical in MDArray and R.
      @r1.vec = arr

      # When accessing a vector with the wrong indexes, return nil
      res = @r1.eval("vec[0]")
      assert_equal(nil, res)

      # @r1.eval("print(vec[1, 1])")
      # @r1.eval("print(vec[1, 2])")


      # First index in R is 1 and not 0.
      # method R.ri converts an MDArray index to a R index (in string format) ready
      # to evaluate
      arr.each_with_counter do |val, ct|
         assert_equal(val, @r1.eval("vec#{R.ri(ct)}"))
      end
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 3D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 60)
      # MDArray is stored in row-major order
      arr.reshape!([5, 3, 4])
      # arr.print

      # shape of @r1.vec is [3, 4, 5].  
      @r1.vec = arr
      @r1.eval("print(dim(vec))")
      # @r1.eval("print(vec)")

      # The data in the array can be accessed both in MDArray as in the R vector.  
      # To access the same element, indexing has to be properly converted from MDArray
      # indexing to R indexing.  In general converting from MDArray index to R index
      # is done as follows: Let [i1, i2, i3, ... in] be the MDArray index, the 
      # corresponding R index is [i(n-1)+1, in+1, ..., i3+1, i2+1, i1+1].  As ane example
      # arr[3, 0, 1] is the R vector vec[1, 2, 4]
      assert_equal(arr[3, 0, 1], @r1.eval("vec[1, 2, 4]")[0])
      # arr[3, 1, 2] is vec[2, 3, 4]
      assert_equal(arr[3, 1, 2], @r1.eval("vec[2, 3, 4]")[0])

      # method R.ri converts an MDArray index to a R index (in string format) ready
      # to evaluate
      arr.each_with_counter do |val, ct|
        assert_equal(arr.get(ct), @r1.eval("vec#{R.ri(ct)}"))
      end
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 4D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 120)
      arr.reshape!([2, 4, 3, 5])
      @r1.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, @r1.eval("vec#{R.ri(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 5D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 360)
      arr.reshape!([2, 4, 3, 5, 3])
      @r1.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, @r1.eval("vec#{R.ri(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 6D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 720)
      arr.reshape!([2, 4, 3, 5, 3, 2])
      @r1.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, @r1.eval("vec#{R.ri(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 7D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 2160)
      arr.reshape!([2, 4, 3, 5, 3, 2, 3])
      @r1.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, @r1.eval("vec#{R.ri(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send larger than 7D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 8640)
      arr.reshape!([2, 4, 3, 5, 3, 2, 3, 4])
      @r1.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, @r1.eval("vec#{R.ri(ct)}"))
      end

    end

=begin

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "receive multidimensional arrays from Renjin" do

      # returned value is column major but MDArray is interpreting as row major
      mat = @r1.eval(" mat = matrix(rnorm(20), 4)")
      mat.print
      @r1.eval("print(mat)")
    end
=end

  end
  
end
