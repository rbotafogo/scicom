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

    should "slice a vector in multiple ways" do

      vec = R.c(1, 2, 3, 4)

      # access a given vector index
      assert_equal(3, vec[3].gz)

      # negative index returns all elements but the one indexed
      vec[-3].pp

      # not good!  But a boolean array in R is converted to an int array in Ruby
      assert_equal(1, (R.c(1, 2, 4).eq vec[-3]).gz)
  
      vec[R.c((1..3))].pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign to a vector" do

      vec = R.c(1, 2, 3)
      vec.pp

      vec[1] = 0
      vec.pp

      # assign to a vector slice
      vec[R.c(1, 2)] = R.c(5, 6)
      vec.pp

    end

=begin

    should "acess attributes" do

      # Must be careful... any assignment to a vector (object?) creates a new object
      # value in Ruby will reference the old object and they will be different.
      dbl_var = R.eval("var = c(1, 2, 3, 4)")
      p dbl_var.sexp
      dbl_var2 = R.eval("var")
      p dbl_var2.sexp

      R.eval("attr(var, \"name\") = \"my.name\"").print
      R.eval("print(attributes(var))")
      # p dbl_var.sexp.getAttributes().names().toString()
      dbl_var3 = R.eval("var")
      dbl_var4 = R.eval("#{dbl_var.r}")
      p dbl_var3.sexp
      p dbl_var4.sexp
      R.eval("print(var)")
      R.eval("print(#{dbl_var.r})")


      R.eval("print(#{dbl_var.r})")
      R.eval("print(attributes(#{dbl_var.r}))")

      R.eval("var2 = #{dbl_var.r}")
      R.eval("print(attributes(var2))")

      R.eval <<EOF
         l = c(1, 2, 3, 4)
         attr(l, "name") = "my.name"
         print(attributes(l))

         l2 = l
         print(attributes(l2))
EOF

    end

    #======================================================================================
    #
    #======================================================================================



      assert_equal(10, i1.as__integer)
      assert_equal(10.0, R.as__double(i1).gz)
      assert_equal("10", R.as__character(i1).gz)
      assert_equal(10.0, i1.as__double)
      assert_equal("10", i1.as__character)


    should "create all types of vectors and check basic properties" do

      dbl_var = R.c(1, 2.5, 4.5)
      assert_equal(2.5, dbl_var[1])
      assert_equal("double", dbl_var.typeof)
      assert_equal(3, dbl_var.length)
      assert_equal(false, dbl_var.integer?)
      assert_equal(true, dbl_var.double?)
      assert_equal(true, dbl_var.numeric?)

      # With the L suffix, you get an integer rather than a double
      int_var = R.c(R.i(1), R.i(6), R.i(10))
      assert_equal("integer", int_var.typeof)
      assert_equal(3, int_var.length)
      assert_equal(true, int_var.integer?)
      
      # Use TRUE and FALSE (or T and F) to create logical vectors
      log_var = R.c(TRUE, FALSE, TRUE, FALSE)
      assert_equal("logical", log_var.typeof)
      assert_equal(4, log_var.length)
      assert_equal(true, log_var.logical?)

      chr_var = R.c("these are", "some strings")
      assert_equal("character", chr_var.typeof)
      assert_equal(2, chr_var.length)
      assert_equal(true, chr_var.character?)
      assert_equal(true, chr_var.atomic?)
      assert_equal(false, chr_var.numeric?)

      v1 = R.c(1, R.c(2, R.c(3, 4)))
      v1.print

      vec2 = R.rep(R.c("A", "B", "C"), 3)
      vec2.print
      table = R.table(vec2)
      table.print

      # Ruby does not allow the ":" notation such as "1:3", this can be obtained
      # by Ruby's range notation (1..3) or (1...3)
      v2 = R.c((1...3))
      v2.print

      v3 = R.c((1..3))
      v3.print

    end
=end
  end

end
