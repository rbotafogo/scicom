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
    # Creating a variable in R and assign a value to it.  In this case assign the NULL 
    # value.  There are two ways of assign variables in R, through method assign or with
    # the '=' method.  To retrieve an R variable just acess it in the R namespace.
    #--------------------------------------------------------------------------------------

    should "assign NULL to R object" do
      
      # Using method assign, to assign NULL to variable 'null' in R namespace.
      R.assign("null", nil)
      assert_equal(nil, R.null)

      # variable null is NULL.  Variable 'null' exists in the R namespace and can be 
      # access normally in a call to 'eval'
      R.eval("print(null)")

      # Variable 'res' is available only in the Ruby namespace and not in the R namespace.
      # a NULL object in R is converted to nil in Ruby.
      res = R.pull("null")
      assert_equal(nil, res)

      # Assign a value to an R variable, 'n2'.  
      R.n2 = nil
      assert_equal(nil, R.n2)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create integer variable" do

      # In R, every number is a vector.  R Vector's are converted to Ruby Renjin::Vector  
      # (a new class defined by SciCom).  
      # An int can be created by calling 'eval'...
      i1 = R.eval("10L")

      # Basic integration with R can always be done by calling eval and passing it a valid
      # R expression. Although this programming technique is a bit cumbersome.
      R.eval("r.i = 10L")
      R.eval("print(r.i)")

      # One can also use here documents:
      R.eval <<EOF
        r.i2 = 10L
        print(r.i2)  
EOF

      # Variables created in Ruby can be accessed in an eval clause:
      val = "10L"
      R.eval <<EOF
        r.i3 = #{val}
        print(r.i3)
EOF

      # ... or it can be created by calling the 'i' method.
      i2 = R.i(10)

      # Method .r can be used in a Ruby vector to make it available in the R namespace
      R.eval("print(#{i2.r})")

      # both i1 and i2 are vectors.  To print a vector we use method .pp
      i1.pp
      i2.pp

      # One can access variables created in R namespace by using R.<var>.  Variable in
      # R that have a '.' such as 'r.i3' need to have the '.' substituted by '__'
      R.r__i3.pp

      # Indexing a vector still returns a vector.  First index for vector is 1 and not 0
      # as it is usual with Ruby, this is so in order to be in order with R.
      i3 = i1[1]
      assert_equal(true, (i3.eq i1).gt)

      # Method 'get' converts a Vector to an MDArray
      vec = i3.get
      assert_equal(true, vec.is_a?(MDArray))
      assert_equal("int", vec.type)

      # For consistancy with R notation one can also call as__mdarray to convert a 
      # vector to an MDArray
      vec2 = i3.as__mdarray
      assert_equal(true, vec2.is_a?(MDArray))
      assert_equal("int", vec2.type)

      # Now 'vec' is an MDArray and its elements can be accessed through indexing, but
      # this time the first index is 0, and the element is an actual number
      assert_equal(10, vec[0])

      # Accessing the first element of a vector is such a common necessity, that method
      # .gz returns such element.
      assert_equal(10, i1.gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create double variable" do

      # Creating a double vector is done with R.d.  From now on we will use preferably
      # Ruby integration and not use 'eval'.  'eval' will be used sometimes just to show
      # that it works and that a user that prefers to use SciCom with a standard R 
      # loook and feel can still do it.
      dbl = R.d(10.25)
      # Prints the vector (R notation)
      dbl.pp
      
      # Prints a number - getting the first element of the dbl vector
      p dbl.gz

      assert_equal(10.25, dbl.gz)
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create complex variable" do

      p "working with complex"

      comp = R.complex(real: 2, imaginary: 3)
      comp.pp
      
      comp = R.as__complex(-1)
      comp.pp

      p R.is__complex(comp).gt

      p R.Re(comp).gz
      p R.Im(comp).gz

      # Cannot yet convert a complex Vector to an MDArray.
      # comp.get.pp

      # The (x, y) representation of numbers is easier to understand at first, but a 
      # polar coordinates representation is often more practical. You can get the 
      # relevant components of this representation by finding the modulus and complex 
      # argument of a complex number. In R, you would use Mod and Arg:

      z = R.complex(real: 0, imaginary: 1)
 
      R.Mod(z).pp
      # [1] 1
      
      R.Arg(z).pp
      # [1] 1.570796
      
      # Not yet defined!!! Fixed
      # R.pi / 2
      # [1] 1.570796

      # Finally, you’ll want to be able to take the complex conjugate of a complex 
      # number; to do that in R, you can use Conj:
      R.Conj(z).pp
      # [1] 0-1i
 
      # Not yet defined!!! Fixed
      # R.Mod(z) == z * Conj(z)
      # [1] TRUE

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
      assert_equal(NA, na)

      # Converting to Ruby will return NaN (Not a Number)
      assert_equal(NaN, na.gz)

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
      assert_equal(4, vec1.length)
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
      assert_equal(3, vec2.length)

      # Convert vector to an MDArray
      array = vec2.get
      
      # Use array as any other MDArray...
      array.each do |elmt|
        p elmt
      end

      # ... although there is no need to convert a vector to an MDArray to call each:
      # the each method is also defined for vectors
      vec1.each do |elmt|
        p elmt
      end

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

=begin

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "integrate MDArray with R vector" do
      
      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 60)
      # MDArray is stored in row-major order
      arr.reshape!([5, 3, 4])
      # arr.print

      R.eval <<EOF
      print(#{arr.r});
      vec = #{arr.r};
print(vec);
print(vec[1, 1, 1]);

EOF

end
=end

  end
  
end
