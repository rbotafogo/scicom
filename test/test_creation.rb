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

    should "create integer variable" do

      # In R, every number is a vector.  R Vector's are converted to Ruby Renjin::Vector  
      # (a new class defined by SciCom).  
      # An int can be created by calling 'eval'...
      i1 = R.eval("10L")

      # ... or it can be created by calling the 'i' method.
      i2 = R.i(10)

      # Method .r can be used in a Ruby vector to make it available in the R namespace
      R.eval("print(#{i2.r})")

      # both i1 and i2 are vectors.  To print a vector we use method .pp
      i1.pp
      i2.pp

      # Integer nuberic Vectors are created with method .i
      # the returned value is a Renjin::Vector
      my_int = R.i(10)
      assert_equal(10, my_int.gz)
      # method typeof returns the type of this vector
      assert_equal("integer", my_int.typeof.gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create double variable" do

      R.eval("i1 = 10.2387")
      # the returned value is a Renjin::Vector
      i1 = R.i1
      assert_equal(10.2387, i1.gz)

      # assign to an R variable the Vector returned previously.  The original variable
      # is still valid
      R.assign("i2", i1)
      assert_equal(10.2387, R.i2.gz)
      assert_equal(10.2387, R.i1.gz)

      # type of i2 is a double
      assert_equal("double", R.eval("typeof(i2)").gz)
      # same call can be done easier.  Remember, i2 is defined only in the R namespace.
      assert_equal("double", R.typeof(R.i2).gz)

      # create a double without calling eval.  Method .d creates a double vector with
      # one element. Variable i2 is now defined in the Ruby namespace
      i2 = R.d(345.7789)
      assert_equal("double", i2.typeof.gz)
      assert_equal(345.7789, i2.gz)

      # Creating a double vector is done with R.d.  From now on we will use preferably
      # Ruby integration and not use 'eval'.  'eval' will be used sometimes just to show
      # that it works and that a user that prefers to use SciCom with a standard R 
      # loook and feel can still do it.
      dbl = R.d(10.25)
      # Prints the vector (R notation)
            
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "acess variable content with .gz and .gt" do

      # In order to access the value of a variable for it to be used in Ruby, method .gz is 
      # used.  Later will see method get and why the name for the method as .gz.
      dbl = R.d(10.25)
      assert_equal(10.25, dbl.gz)

      # When looking at a logical vector, method .gt gets the truth value of the vector
      var = R.c(TRUE)
      assert_equal(true, var.gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create complex variable" do

      # complex vector: created by calling R.complex. Real and imaginary parts are obtained
      # by calling R.Re and R.Im functions on the variable.

      comp_var = R.complex(real: 2, imaginary: 1)
      assert_equal(2, R.Re(comp_var).gz)
      assert_equal(1, R.Im(comp_var).gz)

      p "complex"

      comp = R.as__complex(-1)
      assert_equal(-1, R.Re(comp).gz)
      assert_equal(0, R.Im(comp).gz)
      assert_equal(true, R.is__complex(comp).gt)

      # The (x, y) representation of numbers is easier to understand at first, but a 
      # polar coordinates representation is often more practical. You can get the 
      # relevant components of this representation by finding the modulus and complex 
      # argument of a complex number. In R, you would use Mod and Arg:

      z = R.complex(real: 0, imaginary: 1)
 
      R.Mod(z).pp
      # [1] 1
      
      R.Arg(z).pp
      # [1] 1.570796
      
      # Finally, you’ll want to be able to take the complex conjugate of a complex 
      # number; to do that in R, you can use Conj:
      R.Conj(z).pp
      # [1] 0-1i
 
      # Obtain components of a complex number in polar coordinates
      comp = R.complex(imaginary: 1, real: 0)
      mod = R.Mod(comp)
      arg = R.Arg(comp)
      assert_equal(true, ((R.pi/R.d(2)).gz == arg.gz))
      assert_equal(false, ((R.pi/R.d(2)).gz == mod.gz))

      # To get the complex square root, you need to cast your negative number as a 
      # complex number using as__complex before applying sqrt:
      R.as__complex(-1).pp
      # Renjin not implemented yet
      # R.sqrt(R.as__complex(-1)).pp
      R.sqrt(-1).pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create string variable" do

      R.str1 = "hello there;"

      # method get, gets the current element
      assert_equal("hello there;", R.str1.gz)

      R.str2 = "This is another string"
      assert_equal("This is another string", R.str2.gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create vectors with more than one element (R.c)" do

      # To create vectors in R, one uses the 'c' function.  Use R.c to created vectors
      # in SciCom

      vec = R.c(1, 2, 3, 4, 5)
      assert_equal(true, (R.d(1).eq vec[1]).gt)
      assert_equal(true, (R.d(2).eq vec[2]).gt)

      # In R, indexing a vector with zero returns Vector numeric(0)
      oops = vec[0]
      oops.pp

      # Calling get on numeric(0) raises an exception
      assert_raise ( RuntimeError ) { oops.get }

      # Accessing a value outside of the defined vector bound returns a vector with 
      # one element, the NA (Not Available)
      na = vec[10]
      assert_equal(true, R.is__na(na).gt)

      # Converting to Ruby will return NaN (Not a Number)
      assert_equal(true, (na.gz).nan?)

      # Method get can be used with an index, to get a given element of a vector
      assert_equal(1, vec.get(0))
      assert_equal(4, vec.get(3))

      # method R.c also works with strings
      str = R.c("this is the first string", "this is the second string")
      str.pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "accept (from..to) operators" do

      # Vectors can be created using (from..to) or (from...to) operators in place where
      # R uses ':' notation.  (1..4) is a range that goes from 1 to 4 and (1...4) is a 
      # range that goes from 1 to 3.
      vec1 = R.c((1..4))
      vec1.pp

      # Method length return the number of elements in a vector
      assert_equal(4, vec1.length.gz)
      # The same can be obtained by calling length in R, but remember that R always returns
      # a vector.
      R.length(vec1).pp
      
      # to use assert_equal, we need to get the vector's content
      assert_equal(4, R.length(vec1).gz)

      # We can also acess a Ruby vector in R by calling the .r method in this vector
      R.eval("print(#{vec1.r})")

      vec2 = R.c((1...4))
      vec2.pp

      # vec2 has only three elements
      assert_equal(3, vec2.length.gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create vectors with method seq" do
      
      # create a sequence (from, to)
      seq1 = R.seq(2, 10)
      seq1.pp

      # R options can also be used, although the notation is a little different.  In
      # R we would call seq(2, 10, by = 3).  In SciCom the same call is R.seq(2, 10, by: 3)
      seq2 = R.seq(2, 10, by: 3)
      seq2.print

      # giving the number of required elements in the sequence
      seq3 = R.seq(2, 100, length: 12)
      seq3.pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create vectors with method rep" do

      vec = R.rep(R.c(1, 2, 3), 3)
      vec.pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create lists" do

      p "creating list"
      R.eval("lst = c('a', 'b', 'c')")
      R.eval("print(lst)")
      # the returned value is a list
      rb_lst = R.lst
      p "this is the list"
      rb_lst.pp

      # assign to an R variable the rb_lst returned previously.  The original variable
      # is still valid
      R.assign("lst2", rb_lst)
      R.eval("print(lst2)")
      R.lst2 = R.c("new list")
      R.lst.pp
      R.lst2.pp

    end
    
  end
  
end
