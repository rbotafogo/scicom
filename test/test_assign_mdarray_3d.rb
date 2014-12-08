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

    should "convert a 3D MDArray onto a R matrix" do

      # create a 1D MDArray
      arr1 = MDArray.typed_arange(:double, 12)
      arr1.reshape!([3, 2, 2])
      arr1.print
      
      # Dimensions definitions are treated differently between MDArray and R. In MDArray
      # a [3, 2, 2] specification indicates that there are 3 vector of 2 x 2 dimensions.
      # So arr1 is the following array:
      # [[[0.0 1.0]
      #   [2.0 3.0]]
      #
      #  [[4.0 5.0]
      #   [6.0 7.0]]
      #
      #  [[8.0 9.0]
      #   [10.0 11.0]]]
      # 
      # in R the same specification indicates that we have two vectors each of 3 x 2. So,
      # this would be the vector with the same [3, 2, 2] specification.
      #      [,1] [,2]
      # [1,]    1    2
      # [2,]    3    4
      # [3,]    5    6
      #
      # , , 2
      #
      #      [,1] [,2]
      # [1,]    7   8
      # [2,]    9   10
      # [3,]    11  12
      #
      # When converting a multi-dimensional array from MDArray to R, SciCom also fixes
      # the vector specification and the [3, 2, 2] MDArray specification becomes a 
      # [2, 2, 3] R vector specification.
      # In general converting from MDArray index to R index is done as follows: 
      # Let [i1, i2, i3, ... in] be the MDArray index, the corresponding R index is 
      # [i(n-1)+1, in+1, ..., i3+1, i2+1, i1+1].

      # convert to an R matrix
      r_matrix = R.md(arr1)

      # Renjin does not yet print correctly N > 2 dimensional vectors
      p "this is a 3D vector, but Renjin has a bug and prints it as a 1D vector"
      r_matrix.pp

      # In order to simplify access to the R vector with different dimension specification
      # SciCom implements method 'ri' (r-indexing), so that arr1[dim1, dim2, dim3] is
      # equal to r_matrix.ri(dim1, dim2, dim3)
      compare = MDArray.byte([3, 2, 2])
      (0..2).each do |dim1|
        (0..1).each do |dim2|
          (0..1).each do |dim3|
            # r_matrix.ri(dim1, dim2, dim3).pp
            compare[dim1, dim2, dim3] = 
              (arr1[dim1, dim2, dim3] == (r_matrix.ri(dim1, dim2, dim3).gz))? 1 : 0
          end
        end
      end
      comp = R.md(compare)
      assert_equal(true, comp.all.gt)

      p "dimension of r_matrix in R"
      R.vec = r_matrix
      R.eval("print(dim(vec))")

    end


    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "convert another 3D array" do

      dim = [6, 4, 3]

      # create a 1D MDArray
      arr1 = MDArray.typed_arange(:double, 72)
      arr1.reshape!(dim)

      # convert to an R matrix
      r_matrix = R.md(arr1)

      # In order to simplify access to the R vector with different dimension specification
      # SciCom implements method 'ri' (r-indexing), so that arr1[dim1, dim2, dim3] is
      # equal to r_matrix.ri(dim1, dim2, dim3)
      compare = MDArray.byte(dim)
      (0..dim[0] - 1).each do |dim1|
        (0..dim[1] - 1).each do |dim2|
          (0..dim[2] - 1).each do |dim3|
            # r_matrix.ri(dim1, dim2, dim3).pp
            compare[dim1, dim2, dim3] = 
              (arr1[dim1, dim2, dim3] == (r_matrix.ri(dim1, dim2, dim3).gz))? 1 : 0
          end
        end
      end
      comp = R.md(compare)
      assert_equal(true, comp.all.gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with MDArray slices" do

      # create a 3D MDArray
      # [[[0.0 1.0]
      #   [2.0 3.0]]
      #
      #  [[4.0 5.0]
      #   [6.0 7.0]]
      #
      #  [[8.0 9.0]
      #   [10.0 11.0]]]
      arr1 = MDArray.typed_arange(:double, 12)
      arr1.reshape!([3, 2, 2])
      arr1.print

      # This array has 3 vectors of size 2 x 2.  Getting slice(0, 0) returns the first
      # 2 x 2 vector.
      # [[0.0 1.0]
      #  [2.0 3.0]]
      p "slice(0, 0): this is a 2D slice of the original array"
      mat = arr1.slice(0, 0)
      mat.print

      # MDArray will be converted to the following R matrix
      #      [,1] [,2]
      # [1,]    0    1
      # [2,]    2    3
      p "now converting the slice into an R matrix"
      r_mat = R.md(mat)
      r_mat.pp

      # Getting slice(0, 2) returns the third 2 x 2 vector.
      # [[8.0 9.0]
      #  [10.0 11.0]]
      p "slice(0, 2): this is a 2D slice of the original array"
      mat = arr1.slice(0, 2)
      mat.print

      #      [,1] [,2]
      # [1,]    8    9
      # [2,]   10   11
      p "now converting the slice into an R matrix"
      r_mat = R.md(mat)
      r_mat.pp

      # slice(1, 0) gets the first row of all three vectors and thus returns a 3 x 2
      # vector:
      # [[0.0 1.0]
      #  [4.0 5.0]
      #  [8.0 9.0]]
      p "slice(1, 0): this is a 2D slice of the original array"
      mat = arr1.slice(1, 0)
      mat.print

      # The above will become the following R matrix
      #      [,1] [,2]
      # [1,]    0    1
      # [2,]    4    5
      # [3,]    8    9
      p "now converting the slice into an R matrix"
      r_mat = R.md(mat)
      r_mat.pp

      # Note that there is no data copying when an MDArray is sliced and this is an 
      # efficient operation.

    end

  end
  
end

