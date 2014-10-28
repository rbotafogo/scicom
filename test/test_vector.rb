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

  context "R Vectors" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create vectors of different types" do

      # double vector
      dbl_var = R.c(1, 2.5, 4.5)
      assert_equal(2.5, dbl_var[2].gz)
      assert_equal("double", dbl_var.typeof)
      assert_equal(3, dbl_var.length)
      assert_equal(false, dbl_var.integer?)
      assert_equal(true, dbl_var.double?)
      assert_equal(true, dbl_var.numeric?)

      # int vector: with the R.i, you get an integer rather than a double
      int_var = R.c(R.i(1), R.i(6), R.i(10))
      assert_equal("integer", int_var.typeof)
      assert_equal(3, int_var.length)
      assert_equal(true, int_var.integer?)
      
      # logical vector: Use TRUE and FALSE to create logical vectors
      log_var = R.c(TRUE, FALSE, TRUE, FALSE)
      assert_equal("logical", log_var.typeof)
      assert_equal(4, log_var.length)
      assert_equal(true, log_var.logical?)

      # string vector: create string (character) vectors
      chr_var = R.c("these are", "some strings")
      assert_equal("character", chr_var.typeof)
      assert_equal(2, chr_var.length)
      assert_equal(true, chr_var.character?)
      assert_equal(true, chr_var.atomic?)
      assert_equal(false, chr_var.numeric?)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create vectors with basic R functions" do

      # R.c "flattens" the vectors
      v1 = R.c(1, R.c(2, R.c(3, 4)))
      assert_equal(true, (R.c(1, 2, 3, 4).eq v1).gt)

      # R.rep repeats the given vector
      vec2 = R.rep(R.c("A", "B", "C"), 3)
      assert_equal(true, (R.c("A", "B", "C", "A", "B", "C", "A", "B", "C").eq vec2).gt)

      # R.table calculates the frequencies of elements
      vec3 = R.c("A", "B", "C", "A", "A", "A", "A", "B", "B")
      table = R.table(vec3)
      assert_equal(true, (R.c(R.i(5), R.i(3), R.i(1)) == table).gt)

      # Ruby does not allow the ":" notation such as "1:3", this can be obtained
      # by Ruby's range notation (1..3) or (1...3)
      # does not include the last element
      v2 = R.c((1...3))
      assert_equal(true, (R.c(1, 2) == v2).gt)

      # includes the last element
      v3 = R.c((1..3))
      assert_equal(true, (R.c(1, 2, 3) == v3).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "access vector elements" do

      i1 = R.i(10)
      # In R, and with SciCom vectors, indexing a vector returns a vector.  First index for 
      # vector is 1 and not 0 as it is usual with Ruby, this is so, in order to be 
      # consistent with R.
      i3 = i1[1]
      assert_equal(true, (i3 == i1).gt)

      # double vector
      dbl_var = R.c(1, 2.5, 4.5)
      assert_equal(2.5, dbl_var[2].gz)
      assert_equal(4.5, dbl_var[3].gz)

      # indexing a vector outside of bound returns NA
      assert_equal(NA, dbl_var[4].gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "do basic vector arithmetic" do

      vec1 = R.c(1, 2.5, 4.5)
      vec2 = R.c(3, 4, 5)

      res = -vec1
      assert_equal(true, (R.all(R.c(-1, -2.5, -4.5) == res)).gt)
      assert_equal(false, (R.all(R.c(1, -2.5, -4.5) == res)).gt)

      res = +vec1
      assert_equal(false, (R.all(R.c(-1, -2.5, -4.5) == res)).gt)
      assert_equal(true, (R.all(R.c(1, 2.5, 4.5) == res)).gt)

      res = vec1 + vec2
      assert_equal(true, (R.all(R.c(4, 6.5, 9.5) == res)).gt)
      assert_equal(false, (R.all(R.c(4, 6.5, 9) == res)).gt)

      res = vec1 - vec2
      assert_equal(true, (R.all(R.c(-2, -1.5, -0.5) == res)).gt)

      res = vec1 * vec2
      assert_equal(true, (R.all(R.c(3, 10, 22.5) == res)).gt)

      res = vec1 / vec2
      assert_equal(true, (R.all(R.c(0.333333333333333333333333, 0.625, 0.9) == res)).gt)

      res = vec1 % vec2
      assert_equal(true, (R.all(R.c(1, 2.5, 4.5) == res)).gt)

      res = vec2 % vec1
      assert_equal(true, (R.all(R.c(0, 1.5, 0.5) == res)).gt)

      res = vec1.int_div(vec2)
      assert_equal(true, (R.all(R.c(0, 0, 0) == res)).gt)

      res = vec2.int_div(vec1)
      assert_equal(true, (R.all(R.c(3, 1, 1) == res)).gt)

      res = vec1 ** vec2
      assert_equal(true, (R.all(R.c(1, 39.0625, 1845.28125) == res)).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "do vector comparison" do

      vec1 = R.c(1, 2.5, 4.5)
      vec2 = R.c(3, 4, 5)
      vec3 = R.c(1, 3, 4.5)

      # R.all checks to see if every element of the vector is TRUE. R.any checks to see if at
      # least one element of the vector is TRUE.

      res = vec1 < vec2
      assert_equal(true, R.all(res).gt)

      res = vec1 < vec3
      assert_equal(false, R.all(res).gt)

      res = vec1 <= vec3
      assert_equal(true, R.all(res).gt)

      res = vec1 > vec2
      assert_equal(false, R.all(res).gt)

      res = vec1 > vec3
      assert_equal(false, R.all(res).gt)

      res = vec2 > vec3
      assert_equal(true, R.all(res).gt)

      res = vec3 >= vec1
      assert_equal(true, R.all(res).gt)

      res = vec3 > vec1
      assert_equal(false, R.all(res).gt)
      assert_equal(true, R.any(res).gt)

      res = vec2 != vec1
      assert_equal(true, R.all(res).gt)

      # comparison is done element by element.  R.all is true only if all elements on the 
      # vector are true.  Is this case, there are elements that are equal
      res = vec3 != vec1
      assert_equal(false, R.all(res).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "do logical vector operations" do

      vec1 = R.c(TRUE, TRUE, FALSE, FALSE)
      vec2 = R.c(TRUE, FALSE, TRUE, FALSE)

      p "logical"
      res = !vec1
      assert_equal(true, (R.c(FALSE, FALSE, TRUE, TRUE) == res).gt)

      res = vec1 & vec2
      assert_equal(true, (R.c(TRUE, FALSE, FALSE, FALSE) == res).gt)
      assert_equal(false, (R.c(FALSE, FALSE, FALSE, FALSE) == res).gt)

      # only compares the first element of the vectors.  Equivalent to R's &&
      res = vec1.l_and(vec2)
      assert_equal(true, res.gt)

      p "end logical"

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign to a numeric vector" do

      vec = R.c(1, 2, 3)
      vec[1] = 0
      assert_equal(true, (R.c(0, 2, 3) == vec).gt)

      # assign to a vector slice
      vec[R.c(1, 2)] = R.c(5, 6)
      assert_equal(true, (R.c(5, 6, 3) == vec).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign to a character vector" do

      vec = R.c("a", "b", "c")
      vec[1] = "d"
      assert_equal(true, (R.c("d", "b", "c").eq vec).gt)

      # assign to a vector slice
      vec[R.c(1, 2)] = R.c("e", "f")
      assert_equal(true, (R.c("e", "f", "c").eq vec).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "acess data by using indexing with names attribute" do

      # Must be careful... any assignment to a vector (object?) creates a new object
      # value in Ruby will reference the old object and they will be different.
      dbl_var = R.eval("var = c(1, 2, 3, 4)")
      dbl_var.attr.names = R.c("one", "two", "three", "four")
      dbl_var.attr.name = "my.name"
      dbl_var.pp

      # access element on a vector by name 
      dbl_var["one"].pp
      assert_equal(2, dbl_var["two"].gz)
      assert_equal(4, dbl_var["four"].gz)

      R.eval <<EOF
         l = c(1, 2, 3, 4)
         attr(l, "name") = "my.name"
         print(attributes(l))

         # l2 = l
         # print(attributes(l2))
EOF

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "acess data by using accessor methods from names attribute" do

      dbl_var = R.eval("var = c(1, 2, 3, 4)")
      dbl_var.attr.names = R.c("one", "two", "three", "four")

      assert_equal(1, dbl_var.one.gz)
      assert_equal(2, dbl_var.two.gz)
      assert_equal(3, dbl_var.three.gz)
      assert_equal(4, dbl_var.four.gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "match two vectors with %in%" do

      vec1 = R.c(1, 2, 3, 4)
      vec2 = R.c(1, 2, 3, 4)
      vec3 = R.c(3, 4, 5)
      vec4 = R.c(4, 5, 6, 7)

      (vec1._ :in, vec2).pp
      (vec1._ :in, vec3).pp
      (vec2._ :in, vec4).pp
      
    end

  end

end
