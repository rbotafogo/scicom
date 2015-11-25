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

  context "R Vectors" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "do basic vector arithmetic" do

      vec1 = R.c(1, 2.5, 4.5)
      vec2 = R.c(3, 4, 5)

      # unary minus
      res = -vec1
      assert_equal(true, (R.all(R.c(-1, -2.5, -4.5) == res)).gt)
      assert_equal(false, (R.all(R.c(1, -2.5, -4.5) == res)).gt)

      # unary plus
      res = +vec1
      assert_equal(false, (R.all(R.c(-1, -2.5, -4.5) == res)).gt)
      assert_equal(true, (R.all(R.c(1, 2.5, 4.5) == res)).gt)

      # addition
      res = vec1 + vec2
      assert_equal(true, (R.all(R.c(4, 6.5, 9.5) == res)).gt)
      assert_equal(false, (R.all(R.c(4, 6.5, 9) == res)).gt)

      # subtraction
      res = vec1 - vec2
      assert_equal(true, (R.all(R.c(-2, -1.5, -0.5) == res)).gt)

      # multiplication
      res = vec1 * vec2
      assert_equal(true, (R.all(R.c(3, 10, 22.5) == res)).gt)

      # division
      res = vec1 / vec2
      assert_equal(true, (R.all(R.c(0.333333333333333333333333, 0.625, 0.9) == res)).gt)

      # modulus (x mod y)
      res = vec1 % vec2
      assert_equal(true, (R.all(R.c(1, 2.5, 4.5) == res)).gt)

      # modulus (x mod y)
      res = vec2 % vec1
      assert_equal(true, (R.all(R.c(0, 1.5, 0.5) == res)).gt)

      # integer division
      res = vec1.int_div(vec2)
      assert_equal(true, (R.all(R.c(0, 0, 0) == res)).gt)

      # integer division
      res = vec2.int_div(vec1)
      assert_equal(true, (R.all(R.c(3, 1, 1) == res)).gt)

      # exponetiation
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

      # not
      res = !vec1
      assert_equal(true, (R.all(R.c(FALSE, FALSE, TRUE, TRUE) == res)).gt)

      # and
      res = vec1 & vec2
      assert_equal(true, (R.all(R.c(TRUE, FALSE, FALSE, FALSE) == res)).gt)
      assert_equal(false, (R.all(R.c(FALSE, FALSE, FALSE, FALSE) == res)).gt)

      # or
      res = vec1 | vec2
      assert_equal(false, (R.all(R.c(TRUE, FALSE, FALSE, FALSE) == res)).gt)
      assert_equal(true, (R.all(R.c(TRUE, TRUE, TRUE, FALSE) == res)).gt)

      # only compares the first element of the vectors.  Equivalent to R's &&
      res = vec1.l_and(vec2)
      assert_equal(true, res.gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "do arithmetic with scalars" do

      vec1 = R.c(1, 2.5, 4.5)
      vec2 = R.c(3, 4, 5)

      res = vec1 + 2
      assert_equal(true, (R.all(R.c(3, 4.5, 6.5) == res)).gt)

      res = vec1 - 2
      res = vec1 * 2
      res = vec1 / 2 
      res = vec1 % 2 
      res = vec1 ** 2 
      res = vec1 | 2
      res = vec1 & 2
      res = vec1 > 2
      res = vec1 >= 2
      res = vec1 < 2.5
      res = vec1 <= 2.5
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "coerce scalar to vector when needed" do

      vec1 = R.c(1, 2.5, 4.5)
      vec2 = R.c(3, 4, 5)

      res = 2 * vec2
      res.pp

      res = 2 - vec2
      res.pp

      res = 2 > vec2
      res.pp

      res = 2 <= vec1
      res.pp

    end

  end

end
