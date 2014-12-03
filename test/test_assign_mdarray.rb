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
=begin
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
=end
=begin


    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "convert a 3D MDArray onto a R matrix" do

      # create a 1D MDArray
      arr1 = MDArray.typed_arange(:double, 12)
      arr1.reshape([3, 2, 2]).print
      
      # convert to a 1D R vector
      vec = R.md(arr1)
      vec.pp

      # changing the dimension of vec should work fine
      vec.attr.dim = R.c(3, 2, 2)
      # Renjin does not yet print correctly 3D vectors
      vec.pp
      (1..3).each do |dim1|
        (1..2).each do |dim2|
          (1..2).each do |dim3|
            p "(#{dim1}, #{dim2}, #{dim3})"
            vec[dim1, dim2, dim3].pp 
          end
        end
      end

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