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

    should "convert a 1D MDArray onto a R matrix" do

      # create a 1D MDArray
      arr1 = MDArray.typed_arange(:double, 12)
      
      # convert to a 1D R vector
      vec = R.md(arr1)
      vec.pp

      # changing the dimension of vec should work fine
      vec.attr.dim = R.c(3, 4)
      vec.pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "convert a 2D MDArray onto a R matrix" do

      # create an MDArray
      arr1 = MDArray.typed_arange(:double, 12)
      arr1.reshape!([4, 3])
      arr1.print

      # use method md to convert an MDArray onto an R vector
      r_matrix = R.md(arr1)
      r_matrix.pp

      # both arr1 and r_matrix should have the same elements. Also, elements in both
      # MDArray and R vector can be indexed in the same way (correcting for initial
      # elements).
      # First index in R is 1 and not 0. So we need to be careful when comparing
      # MDArray and R vectors (arrays)
      compare = MDArray.boolean([4,3])
      (0..3).each do |row|
        (0..2).each do |col|
          compare[row, col] = 
            (arr1[row, col] == (r_matrix[row + 1, col + 1].gz))? true : false
        end
      end
      compare.print

      # change an element of the MDArray
      arr1[0, 0] = 10

      # WITH GREAT POWER COMES GREAT RESPONSABILITIES!
      # r_matrix also changes... arr1 and r_matrix have the same backing store. Changing
      # the content of an MDArray that points to the same backing store as an R vector
      # should be done with care.  Renjin assumes that the vector will never change and
      # delays calculation of the vector to the latest possible time.  In this case, since
      # the value of the vector is changing, one can get unexpected behaviour.  Use with
      # care.  We could prevent MDArray from being editable, however, we believe that
      # allowing access to the backing store will have important implications for 
      # performance.  If we have indication that this is not a good thing, then we will
      # remove MDArrays ability to change the backing store of a Vector.
      compare = MDArray.boolean([4,3])
      (0..3).each do |row|
        (0..2).each do |col|
          compare[row, col] = 
            (arr1[row, col] == (r_matrix[row + 1, col + 1].gz))? true : false
        end
      end
      compare.print

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "change backing store of R vector when changing the vector" do

      # create an MDArray
      arr1 = MDArray.typed_arange(:double, 12)
      arr1.reshape!([4, 3])
      arr1.print

      r_matrix = R.md(arr1)

      # change the r_matrix dimension.  Now r_matrix and arr1 point to different
      # backstores, as any change in a Renjin object actually creates a new object.
      r_matrix.attr.dim = R.c(3, 4)
      arr1[1, 1] = 1000.34

      # arrays are now different
      r_matrix.pp
      arr1.print

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "convert a 3D MDArray onto a R matrix" do

      # create a 1D MDArray
      arr1 = MDArray.typed_arange(:double, 12)
      
      # convert to a 1D R vector
      vec = R.md(arr1)
      vec.pp

      # changing the dimension of vec should work fine
      vec.attr.dim = R.c(3, 2, 2)
      # Renjin does not yet print correctly 3D vectors
      vec.pp

    end

=begin
    #--------------------------------------------------------------------------------------
    # Assign an MDArray to an R vector (array)
    #--------------------------------------------------------------------------------------

    should "accept 2D MDArray as data" do

      # method R.ri converts an MDArray index to a R index (in string format) ready
      # to evaluate
      arr.each_with_counter do |val, ct|
        assert_equal(val, R.eval("vec#{R.ri(ct)}").gz)
        # assert_equal(val, vec[R.ri(ct)])
      end

      # Creating a vector in R and changing its shape will yield a different array as
      # the one created from MDArray.
      vec = R.seq(0, 11)
      vec.attr.dim = R.c(4, 3)
      vec.pp

      compare = MDArray.boolean([4,3])
      (0..3).each do |row|
        (0..2).each do |col|
          compare[row, col] = (arr[row, col] == (vec[row + 1, col + 1].gz))? true : false
        end
      end
      compare.print
      
    end

=end

=begin

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 3D arrays to Renjin" do


      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 60)
      # MDArray is stored in row-major order
      arr.reshape!([5, 3, 4])
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

      # shape of R.vec is [3, 4, 5].  
      R.vec = arr
      R.eval("print(dim(vec))")
      # R.eval("print(vec)")

      # The data in the array can be accessed both in MDArray as in the R vector.  
      # To access the same element, indexing has to be properly converted from MDArray
      # indexing to R indexing.  In general converting from MDArray index to R index
      # is done as follows: Let [i1, i2, i3, ... in] be the MDArray index, the 
      # corresponding R index is [i(n-1)+1, in+1, ..., i3+1, i2+1, i1+1].  As ane example
      # arr[3, 0, 1] is the R vector vec[1, 2, 4]
      assert_equal(arr[3, 0, 1], R.eval("vec[1, 2, 4]")[0])
      # arr[3, 1, 2] is vec[2, 3, 4]
      assert_equal(arr[3, 1, 2], R.eval("vec[2, 3, 4]")[0])

      # method R.ri converts an MDArray index to a R index (in string format) ready
      # to evaluate
      arr.each_with_counter do |val, ct|
        assert_equal(arr.get(ct), R.eval("vec#{R.ri(ct)}"))
      end
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 4D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 120)
      arr.reshape!([2, 4, 3, 5])
      R.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, R.eval("vec#{R.ri(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 5D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 360)
      arr.reshape!([2, 4, 3, 5, 3])
      R.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, R.eval("vec#{R.ri(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 6D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 720)
      arr.reshape!([2, 4, 3, 5, 3, 2])
      R.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, R.eval("vec#{R.ri(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 7D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 2160)
      arr.reshape!([2, 4, 3, 5, 3, 2, 3])
      R.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, R.eval("vec#{R.ri(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send larger than 7D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 8640)
      arr.reshape!([2, 4, 3, 5, 3, 2, 3, 4])
      R.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, R.eval("vec#{R.ri(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "receive multidimensional arrays from Renjin" do

      # returned value is column major but MDArray is interpreting as row major
      mat = R.eval(" mat = matrix(rnorm(20), 4)")
      mat.print
      R.eval("print(mat)")
    end
=end

  end
  
end
