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

require '../config' if @platform == nil
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

    should "create array with the creator function" do

      # You have two different options for constructing matrices or arrays. Either you use 
      # the creator functions matrix() and array(), or you simply change the dimensions 
      # using the dim() function.

      # Use the creator functions in R
      # You can create an array easily with the array() function, where you give the data 
      # as the first argument and a vector with the sizes of the dimensions as the second 
      # argument. The number of dimension sizes in that argument gives you the number of 
      # dimensions. For example, you make an array with four columns, three rows, and 
      # two “tables” like this:
      my_array = R.array((1..24), dim: R.c(3,4,2))
      # Renjin has a bug and does not print correctly multi-dimensional array, printing
      # them as one-dimensional vector.
      # Correct output should be something like:
      # , , 1
      # [,1] [,2] [,3] [,4]
      # [1,]  1  4  7  10
      # [2,]  2  5  8  11
      # [3,]  3  6  9  12
      # , , 2
      # [,1] [,2] [,3] [,4]
      # [1,]  13  16  19  22
      # [2,]  14  17  20  23
      # [3,]  15  18  21  24
      my_array.pp
      my_array.dim.pp

      # This array has three dimensions. Notice that, although the rows are given as the 
      # first dimension, the tables are filled column-wise. So, for arrays, R fills the 
      # columns, then the rows, and then the rest.

      # Change the dimensions of a vector in R
      # Alternatively, you could just add the dimensions using the dim() function. This is 
      # a little hack that goes a bit faster than using the array() function; it’s especially 
      # useful if you have your data already in a vector. (This little trick also works for 
      # creating matrices, by the way, because a matrix is nothing more than an array with 
      # only two dimensions.)

      # Say you already have a vector with the numbers 1 through 24, like this:
      my_vector = R.c((1..24))
      my_vector.pp
      
      # You can easily convert that vector to an array exactly like my_array simply by 
      # assigning the attribute dimensions, like this:
      my_vector.attr.dim = R.c(3, 4, 2)
      my_vector.attr.dim.pp

      # You can check whether two objects are identical by using the identical function. To 
      # check, for example, whether my_vector and my_array are identical, you simply do the 
      # following:
      my_array.identical(my_vector).pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "access array elements with indexing" do

      my_array = R.array((1..24), dim: R.c(3,4,2))

      # getting a subarray of the original array: is a 4 * 2 array with dimension vector 
      # c(4,2) and data vector containing the values
      sub = my_array[2, nil, nil]
      sub.pp
      sub.attr.dim.pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "allow usage of index arrays" do

      # As well as an index vector in any subscript position, a matrix may be used with a 
      # single index matrix in order either to assign a vector of quantities to an irregular 
      # collection of elements in the array, or to extract an irregular collection as a vector.

      # A matrix example makes the process clear. In the case of a doubly indexed array, an 
      # index matrix may be given consisting of two columns and as many rows as desired. The 
      # entries in the index matrix are the row and column indices for the doubly indexed 
      # array. Suppose for example we have a 4 by 5 array X and we wish to do the following:

      # Extract elements X[1,3], X[2,2] and X[3,1] as a vector structure, and
      # Replace these entries in the array X by zeroes.
      # In this case we need a 3 by 2 subscript array, as in the following example.
      x = R.array((1..20), dim: R.c(4,5))   # Generate a 4 by 5 array.
      x.pp

      # Now create an index array: i is a 3 by 2 index array.
      i = R.array(R.c((1..3), (3..1)), dim: R.c(3,2))
      i.pp

      # Extract all elements in the index array
      x[i].pp 

      # Now replace those elements by zeros
      x[i] = 0
      x.pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "apply outer function to arrays" do

      # outer() function applies a function to two arrays.
      # outer(x, y, FUN="*", ...)
      # x %o% y

      # x,y: arrays
      # FUN: function to use on the outer products, default is multiply

      x = R.c(1, 2.3, 2, 3, 4, 8, 12, 43)
      y = R.c(2, 4)

      # Calculate logarithm value of array x elements using array y as bases:
      R.outer(x, y, "log").pp

      # calling outer on the vector directly
      x.outer(y, "log").pp

      # Add array x elements with array y elements:
      x.outer(y, "+").pp

      # Multiply array x elements with array y elements:
      mult = x._ :o, y  #equal to outer(x,y,"*")
      mult.pp

      # same as above
      x.outer(y, "*").pp

      # Concatenate characters to the array elements:
      z = R.c("a","b")
      x.outer(z, "paste").pp

    end

  end

end
