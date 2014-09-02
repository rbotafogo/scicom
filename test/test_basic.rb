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

    should "work with vector" do

      # Create a vector with R.c
      var = R.c(2, 3, 4)

      # Create vectors with double value
      two = R.d(2)
      three = R.d(3)
      four = R.d(4)

      R.all__equal(var, var).pp

=begin
      # Vector can be accessed in R by calling the 'r' method
      R.eval("#{var.r}[1]")

      # Vector can be accessed in Ruby by normal indexing, but remember, all values are
      # vectors
      var[2].pp
      R.eval("#{var.r}[1]")
      R.eval("#{two.r}")
      R.eval("all.equal(#{var.r}[1], #{two.r})").pp

      # assert_equal(TRUE, var[1].eq(two))
=end
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
=begin
    should "save variables and access variables and functions in R" do

      
      var = R.c(2, 3, 4, 5)
      var.pp

      # method pp prints the content of the Sexp.  "__" in variables and functions are
      # converted to "." in R.  So "my__var" is variable "my.var" in R namespace

      # Defininig variable "my.var" in the R namespace.  Need to use the "__" notation:
      R.my__var = R.c(2, 3, 4)

      # get the variable "my.var" defined above using a method call on R:
      R.my__var.pp

      # Accessimg variable "my.var" through the eval method of R:
      R.eval("print(my.var)")

      # Using here docs to develop R scripts
      R.eval <<EOF
        print(my.var)
EOF

      # Variable my__var is undefined on the Ruby namespace
      assert_raise ( NameError ) { my__var }


      # We can also create variables in the Ruby namespace.  In the example bellow
      # vector is created in the Ruby namespace.  R.c method creates a vector that
      # is converted to an MDArray.
      vector = R.c(2, 3, 4)
      
      # Acessing variable vector in the Ruby namespace as any normal Ruby variable
      vector.pp

      # Ruby variables created through method call to function in the R namespace
      # can be accessed in R with the r method:
      R.eval("print(#{vector.r})")
      
      # calls methods getwd
      R.getwd.pp
      R.setwd("..")
      R.getwd.pp

      # Check variables created in Renjin (R) environment
      R.ls.pp
      
      # look at the structure of R object
      p "Structure of vector"
      R.str(vector)

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
      p "timeout is: #{opts.timeout.z}"
      p "na.action: #{opts.na__action.z}"
      p "prompt: #{opts.prompt.z}"
      p "help.search: #{opts.help__search__types.z}"
      p "show error message: #{opts.show__error__messages.z}"
      print("\n")

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with missing numbers" do

      assert_equal(false, R.is__na(10)[0])
      # Since every value is a vector in R, .z returns the 0th index of the vector
      assert_equal(false, R.is__na(10).z)
      assert_equal(true, R.is__na(NA)[0])

      # this will result in error.  In R is.na(NaN) is true and in Renjin it's false
      # R.eval("print(is.na(NaN))")
      # assert_equal(true, R.is__na(NaN)[0])


      # R.is__na and R.na? are both valid and do the same thing
      assert_equal(false, R.na?(10)[0])
      assert_equal(false, R.na?(10.35)[0])
      assert_equal(false, R.na?(10.35).z)
      assert_equal(false, R.na?(R.eval("10L"))[0])
      assert_equal(false, R.na?(R.eval("10.456"))[0])
      assert_equal(false, R.na?(R.eval("10.456")).z)

      # Use nil in Ruby when needing a NULL in R
      p "R prints Warning message when is.na is applied to a value and not a vector: "
      assert_equal(0, R.length(R.na?(nil))[0])
      R.eval("is.na(NULL)").pp

      # Check NA property on a vector
      vec = R.is__na(R.c(10.35, 10.0, 56, NA))
      assert_equal(false, vec[0])
      assert_equal(true, vec[3])

      # Check NaN properties
      assert_equal(true, R.is__nan(NaN)[0])
      assert_equal(true, R.is__nan(NaN).z)
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

      # Infinite number
      p Inf[0]

      # Negative infinite number, equivalent to "-Inf" in R
      p MInf[0]

      assert_equal(Inf, Inf)
      assert_equal(false, R.finite?(Inf)[0])
      assert_equal(false, R.finite?(Inf).z)
      assert_equal(false, R.finite?(MInf)[0])
      assert_equal(false, R.finite?(MInf).z)

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

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign NULL to R object" do
      
      # assign NULL value
      R.assign("null", nil)
      assert_equal(nil, R.null)

      # variable null is NULL
      R.eval("print(null)")

      # R.null = nil
      res = R.pull("null")
      assert_equal(nil, res)
      # assert_equal(res, nil)

      R.n2 = nil
      assert_equal(nil, R.n2)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign an integer to an R object" do

      # To create an int we need to call eval....
      i1 = R.eval("10L")

      assert_equal(10, i1.z)
      assert_equal(10, i1[0])
      assert_equal(10, i1.z)
      assert_equal(10, i1.as__integer)
      assert_equal(10.0, R.as__double(i1).z)
      assert_equal("10", R.as__character(i1).z)
      assert_equal(10.0, i1.as__double)
      assert_equal("10", i1.as__character)

      # ... or call method R.i to create an integer object
      i2 = R.i(13)
      # assert_equal(13, i2.get)

      int_vec = R.c(R.i(10), R.i(20), R.i(30), R.i(40))
      int_vec.print
      R.eval("print(#{int_vec.r})")

      R.eval <<EOF
      print(#{int_vec.r})
EOF

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "be able to assign a string to R" do

      # assign and pull are not really necessary, but left since other R integration
      # solutions use those methods
      R.assign("str", "hello there;")
      str = R.pull("str")

      # method get, gets the current element
      assert_equal("hello there;", str.z)

      R.str2 = "This is another string"
      assert_equal("This is another string", R.str2.z)
      p "R variables"
      R.ls.pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "be able to assign a Ruby array to R" do

      # converts the Ruby array to an R list
      names = ["Lisa", "Teasha", "Aaron", "Thomas"]
      R.people = names
      R.people.pp

      R.list = [1, 2, 3, 4, 5, 6]
      R.list.pp

      # this gives an error in Renjin about Unmatched positional argument.  I think this is a
      # Renjin bug.
      R.str(R.list)

    end
=end  
  end

end
