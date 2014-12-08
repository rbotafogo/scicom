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

    should "have the same backing store" do

      p "arr1 and r_matrix have both the same backing store when data is converted from \
MDArray to R"
      arr1 = MDArray.typed_arange(:double, 12)
      arr1.reshape!([4, 3])
      arr1.print

      p "r_matrix has the same data as arr1"
      r_matrix = R.md(arr1)
      r_matrix.pp

      # change an element of the MDArray
      arr1[0, 0] = 10.34567
      p "changing element is arr1 will cause the same change in r_matrix"
      arr1.print

      p "element [0, 0] of r_matrix has also changed"
      r_matrix.pp

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
      compare = MDArray.byte([4,3])
      (0..3).each do |row|
        (0..2).each do |col|
          compare[row, col] = 
            (arr1[row, col] == (r_matrix[row + 1, col + 1].gz))? 1 : 0
        end
      end
      comp = R.md(compare)
      assert_equal(true, comp.all.gt)

    end

    #--------------------------------------------------------------------------------------
    # Assign an MDArray to an R vector (array)
    #--------------------------------------------------------------------------------------

    should "MDArray is organized row-major while R vectors are column-major" do

      # this is a row-major matrix
      p "arr1 is in row-major order"
      arr1 = MDArray.typed_arange(:double, 12)
      arr1.reshape!([4, 3])
      arr1.print

      # a vector in R is column-major
      p "however vec is in column-major order as vec was created in R"
      vec = R.seq(0, 11)
      vec.attr.dim = R.c(4, 3)
      vec.pp

      # arr1 and vec are not identical, since one is organized in row-major order while
      # the other is organized in column-major order
      compare = MDArray.byte([4,3])
      (0..3).each do |row|
        (0..2).each do |col|
          compare[row, col] = (arr1[row, col] == (vec[row + 1, col + 1].gz))? 1 : 0
        end
      end
      comp = R.md(compare)
      assert_equal(false, comp.all.gt)

      # Note that when creating a matrix in MDArray and converting to an R vector, the 
      # same order is preserved, i.e., the R vector will see the data as in row-major
      # order.  On the other hand, when a vector is created in R, it will have column-
      # major order.  Maintaining the order from MDArray to R allows for easy and 
      # compatible use of array in both views.

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "change backing store of R vector when changing the vector" do

      # create an MDArray
      arr1 = MDArray.typed_arange(:double, 12)
      arr1.reshape!([4, 3])
      p "Making any changes in an Renjin object changes the object itself"
      arr1.print
      r_matrix = R.md(arr1)
      p "r_matrix has the same data as arr1"

      # Both arr1 and r_matrix point to the same backing store as seen above.

      # Now, changing the r_matrix dimension will create a new r_matrix and arr1 and 
      # r_matrix will now point to different backstores.  By design, any changes in a Renjin 
      # object actually creates a new object.
      r_matrix.attr.dim = R.c(4, 3)
      p "just by setting the dimension, even with the same values as before, creates a new object"
      r_matrix.pp

      # changing the value of arr1 will have no impact in r_matrix
      arr1[1, 1] = 1000.34
      p "changing arr1 element will not change r_matrix element anymore"
      arr1.print
      p "r_matrix is unchanged"
      r_matrix.pp

      compare = MDArray.byte([4,3])
      (0..3).each do |row|
        (0..2).each do |col|
          compare[row, col] = (arr1[row, col] == (r_matrix[row + 1, col + 1].gz))? 1 : 0
        end
      end
      comp = R.md(compare)
      assert_equal(false, comp.all.gt)

    end

  end
  
end
