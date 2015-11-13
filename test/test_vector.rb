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

    should "create vectors of different types" do

      # double vector
      dbl_var = R.c(1, 2.5, 4.5)
      assert_equal(2.5, dbl_var[2].gz)
      assert_equal("double", dbl_var.typeof.gz)
      assert_equal(3, dbl_var.length)
      assert_equal(false, dbl_var.integer?)
      assert_equal(true, dbl_var.double?)
      assert_equal(true, dbl_var.numeric?)

      # int vector: with the R.i, you get an integer rather than a double
      int_var = R.c(R.i(1), R.i(6), R.i(10))
      assert_equal("integer", int_var.typeof.gz)
      assert_equal(3, int_var.length)
      assert_equal(true, int_var.integer?)
      
      # logical vector: Use TRUE and FALSE to create logical vectors
      log_var = R.c(TRUE, FALSE, TRUE, FALSE)
      assert_equal("logical", log_var.typeof.gz)
      assert_equal(4, log_var.length)
      assert_equal(true, log_var.logical?)

      str_var = R.c("hello there")
      str_var.pp

      # string vector: create string (character) vectors
      chr_var = R.c("these are", "some strings")
      assert_equal("character", chr_var.typeof.gz)
      assert_equal(2, chr_var.length)
      assert_equal(true, chr_var.character?)
      assert_equal(true, chr_var.atomic?)
      assert_equal(false, chr_var.numeric?)

      # complex vector
      comp_var = R.c(R.complex(real: 2, imaginary: 1), R.complex(real: 0, imaginary: 1))
      assert_equal("complex", comp_var.typeof.gz)
      assert_equal(2, comp_var.length)
      assert_equal(false, comp_var.integer?)
      assert_equal(false, comp_var.double?)
      assert_equal(true, comp_var.complex?)
      assert_equal(1, comp_var[2].im.gz)

      ## create a complex normal vector
      z = R.complex(real: R.rnorm(100), imaginary: R.rnorm(100))

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
      assert_equal(true, R.is__na(dbl_var[4]).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign to a numeric vector" do

      # assign to a given vector index
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

    should "match two vectors with %in%" do

      vec1 = R.c(1, 2, 3, 4)
      vec2 = R.c(1, 2, 3, 4)
      vec3 = R.c(3, 4, 5)
      vec4 = R.c(4, 5, 6, 7)

      # R has functions defined with '%%' notation.  In order to access those functions
      # from SciCom we use the '._' method with two arguments, the first argument is the
      # name of the function, for instance, function %in%, the name of the method is ':in'
      # Ex: vec1 %in% vec2 => vec1._ :in, vec2 
      (vec1._ :in, vec2).pp
      (vec1._ :in, vec3).pp
      (vec2._ :in, vec4).pp
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "Apply a Function over a List or Vector" do

      x = R.list(a: (1..10), beta: R.exp(-3..3), logic: R.c(TRUE,FALSE,FALSE,TRUE))
      x.pp
      # compute the list mean for each list element
      mean = R.lapply(x, "mean")
      mean.pp

      # median and quartiles for each list element
      # quant = R.lapply(x, "quantile")
      # quant = R.sapply(x, "quantile")
      # quant.pp
      # R.eval("x <- lapply(#{x.r}, quantile, c(0.25, 0.50, 0.75))")
      # R.eval("print(x)")

      # list of vectors
      i39 = R.sapply((3..9), "seq")
      i39.pp
      sap = R.sapply(i39, "fivenum")
      sap.pp

    end

  end

end
