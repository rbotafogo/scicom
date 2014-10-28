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

    should "get info from the workspace" do

      # get default R options
      opts = R.options
      
      p "Some R options:"
      print("\n")
      # access the options through their names
      p "timeout is: #{opts.timeout.gz}"
      p "na.action: #{opts.na__action.gz}"
      p "prompt: #{opts.prompt.gz}"
      p "help.search: #{opts.help__search__types.gz}"
      p "show error message: #{opts.show__error__messages.gz}"
      print("\n")

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with missing numbers" do

      # Since every value is a vector in R, .gt returns the 0th index of the vector as
      # a truth value
      assert_equal(false, R.is__na(10).gt)
      assert_equal(true, R.is__na(NA).gt)

      # this will result in error.  In R is.na(NaN) is true and in Renjin it's false
      # R.eval("print(is.na(NaN))")
      # assert_equal(true, R.is__na(NaN).gt)

      # R.is__na and R.na? are both valid and do the same thing
      assert_equal(false, R.na?(10).gt)
      assert_equal(false, R.na?(10.35).gt)
      assert_equal(false, R.na?(R.eval("10L")).gt)
      assert_equal(false, R.na?(R.eval("10.456")).gt)

      # Use nil in Ruby when needing a NULL in R
      p "R prints Warning message when is.na is applied to a value and not a vector: "
      #assert_equal(0, R.length(R.na?(nil).gt))
      
      p "checking if NULL is na"
      R.eval("is.na(NULL)").pp

      # Check NA property on a vector
      vec = R.is__na(R.c(10.35, 10.0, 56, NA))

      # remember that in the Renjin::Vector class the first element is index 1
      assert_equal(false, vec[1].gt)
      assert_equal(true, vec[4].gt)

      # gt also works with an index.  Remember .gt converts Renjin::Vector to MDArray and
      # MDArray's first element is idexed by 0.
      assert_equal(false, vec.gt(0))
      assert_equal(false, vec.gt(1))
      assert_equal(false, vec.gt(2))
      assert_equal(true, vec.gt(3))

      # Check NaN properties
      assert_equal(true, R.is__nan(NaN).gt)
      assert_equal(true, R.nan?(NaN).gt)
      # Those are NaN
      assert_equal(false, R.nan?(NA).gt)
      
      # The result of is.nan(NULL) is logical(0). If we try to access a 0 length vector
      # in SciCon a RuntimeError is raised
      assert_raise ( RuntimeError ) { R.nan?(nil).gt }
      assert_raise ( RuntimeError ) { R.nan?(R.eval("NULL")).gt }

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with infinites" do

      # Infinite number
      p Inf.gz

      # Negative infinite number, equivalent to "-Inf" in R
      p MInf.gz

      assert_equal(Inf, Inf)
      assert_equal(false, R.finite?(Inf).gt)
      assert_equal(false, R.finite?(MInf).gt)

      # Check if the number if finite
      assert_equal(true, R.finite?(10).gt)
      assert_equal(true, R.finite?(10.35).gt)

      # chekc numbers to see if they are finite
      # assert_equal(false, R.finite?(R.NaN_double))

      assert_equal(false, R.finite?(NA).gt)
      # assert_equal(false, R.finite?(R.NaN_double))

      # Check a vector for the finite? property
      R.finite?(R.c(2, 3, 4))
      R.finite?(R.eval("10.456"))
      
      # Int_NA is finite; however R.NA_double is not finite.  Is this correct? Should 
      # check with the Renjin team.
      assert_equal(false, R.finite?(NA).gt)

    end

  end

end
