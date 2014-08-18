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

    should "save variables and access variables and functions in R" do

      # method p prints the content of the Sexp.  "__" in variables and functions are
      # converted to "." in R.  So "my__var" is variable "my.var" in R.
      R.my__var = R.c(2, 3, 4)
      # get the var variable defined above
      R.my__var.p
      R.eval("print(my.var)")
      
      # calls methods getwd
      R.getwd.p
      R.setwd("..")
      R.getwd.p

      R.ls.p

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "get info from the workspace" do

      # get default R options
      opts = R.options

      p "Some R options:"
      print("\n")
      # access the options through their names
      p "timeout is: #{opts.timeout.to_string}"
      p "na.action: #{opts.na__action.to_string}"
      p "prompt: #{opts.prompt.to_string}"
      p "help.search: #{opts.help__search__types.to_string}"
      # Check!!!!
      p "show error message: #{opts.show__error__messages.to_string}"
      print("\n")

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with missing numbers" do

      assert_equal(false, R.is__na(10)[0])
      assert_equal(true, R.is__na(NA)[0])
      assert_equal(false, R.is__na(NaN)[0])

      # R.is__na and R.na? are both valid and do the same thing
      assert_equal(false, R.na?(10)[0])
      assert_equal(false, R.na?(10.35)[0])
      assert_equal(false, R.na?(R.eval("10L"))[0])
      assert_equal(false, R.na?(R.eval("10.456"))[0])

      # Use nil in Ruby when needing a NULL in R
      R.na?(nil)
      R.eval("is.na(NULL)")

      # Check NA property on a vector
      vec = R.is__na(R.c(10.35, 10.0, 56, NA))
      assert_equal(false, vec[0])
      assert_equal(true, vec[3])



      # Check NaN properties
      assert_equal(true, R.is__nan(NaN)[0])
      assert_equal(true, R.nan?(NaN)[0])
      # Those are NaN
      assert_equal(false, R.nan?(NA)[0])
      
      # The result of is.nan(NULL) is logical(0). If we try to access a 0 length vector
      # in SciCon a RuntimeError is raised
      assert_raise ( RuntimeError ) { R.nan?(nil)[0] }
      assert_raise ( RuntimeError ) { R.nan?(R.eval("NULL"))[0] }

    end


    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with infinites" do

=begin
      # Infinite number
      p R.Inf[0]

      # Negative infinite number, equivalent to "-Inf" in R
      p R.MInf[0]
=end

      # Check if the number if finite
      assert_equal(true, R.finite?(10)[0])
      assert_equal(true, R.finite?(10.35)[0])

      # chekc numbers to see if they are finite
      # assert_equal(false, R.finite?(R.NaN_double))

      assert_equal(false, R.finite?(NA)[0])
      # assert_equal(false, R.finite?(R.NaN_double))

      # Check a vector for the finite? property
      R.finite?(R.c(2, 3, 4))
      R.finite?(R.eval("10.456"))
      
      # Int_NA is finite; however R.NA_double is not finite.  Is this correct? Should 
      # check with the Renjin team.
      assert_equal(false, R.finite?(NA)[0])

    end

=begin
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "be able to assign NULL to R object" do
      
      # assign NULL value
      @r.assign("nl", "NULL")
      res = @r.pull("nl")
      assert_equal(res, nil)

      @r.n2 = "NULL"
      res = @r.n2
      assert_equal(res, nil)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "be able to assign an integer to an R object" do

      @r1.eval("i1 = 10L")
      i1 = @r1.i1
      assert_equal("integer", i1.type_name)

      assert_equal(10, i1.get)
      assert_equal(10, i1[0])
      assert_equal(10, i1.get_as(:int))
      assert_equal(10.0, i1.get_as(:double))
      assert_equal("10", i1.get_as(:string))
      # assert_equal(true, i1.get_as(:logical))
      # assert_equal(1, i1.get_as(:raw_logical))
      # assert_equal(Complex(10, 0), i1.get_as(:complex))

      assert_equal(true, i1.element_true?)
      assert_raise (IndexError) { i1.element_true?(1) }

    end

=end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
=begin
    should "be able to assign a string to R" do

      @r1.assign("str", "hello there;")
      str = @r1.pull("str")

      p str.get_as(:int)
      p str.get_as(:double)
      p str.get_as(:complex)

      assert_equal("hello there;", str.get_as(:string))
      assert_equal("hello there;", str.get)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "be able to assign a Ruby array to R" do

      names = ["Lisa", "Teasha", "Aaron", "Thomas"]
      @r1.people = names
      # @r1.people.get_element_as_string

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "be able to send an MDArray to R" do


    end
=end

  end
  
end
