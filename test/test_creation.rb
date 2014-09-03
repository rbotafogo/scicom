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

    should "create integer vectors" do

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
      i3.pp

      # Method 'get' converts a Vector to an MDArray
      vec = i3.get
      vec.print

      # For consistancy with R notation one can also call as__mdarray to convert a 
      # vector to an MDArray
      vec2 = i3.as__mdarray
      vec2.print

      # Now 'vec' is an MDArray and its elements can be accessed through indexing, but
      # this time the first index is 0, and the element is an actual number
      p vec[0]

      # Accessing the first element of a vector is such a common necessity, that method
      # .gz returns such element.
      assert_equal(10, i1.gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create double vectors" do

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

    should "create vectors with more than one element (R.c)" do

      # To create vectors in R, one uses the 'c' function.  Use R.c to created vectors
      # in SciCom

      vec = R.c(1, 2, 3, 4, 5)
      vec.pp

      # In R, indexing a vector with zero return numeric(0)
      oops = vec[0]
      oops.pp

      # Calling get on numeric(0) is nil
      assert_equal(nil, oops.get)

      # Accessing a value outside of the defined vector bound returns a vector with 
      # one element, the NA (Not Available)
      na = vec[10]
      na.pp
      
      # Converting to Ruby will return NaN (Not a Number)
      assert_equal(NaN, na.gz)

      # Method get can be used with an index, to get a given element of a vector
      assert_equal(1, vec.get(0))
      assert_equal(4, vec.get(3))

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

    end


=begin
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "integrate Ruby sequence with R sequence" do
      
      seq = R.seq(2, 10)

      res = R.eval <<EOF
      print(#{seq.r});
      print(#{seq.r});
print(ls());
EOF

      # remove the variable from R
      seq.destroy

      R.eval("print(ls())")

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


=begin

      int_vec = R.c(R.i(10), R.i(20), R.i(30), R.i(40))
      int_vec.print
      R.eval("print(#{int_vec.r})")

      R.eval <<EOF
      print(#{int_vec.r})
EOF
=end
