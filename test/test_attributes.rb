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
=begin
    should "assign attributes to objects" do

      vec = R.c(1, 2, 3, 4)
      vec.attr.name = "my.attribute"
      vec.attr.truth = true
      vec.attr.column_names = R.c("one", "two", "three", "four")
      vec.attr.values = R.c((1..3))
      vec.pp

      # retrieve attr
      assert_equal("my.attribute", vec.attr.name.gz)
      assert_equal(true, vec.attr.truth.gt)
      assert_equal("one", vec.attr.column_names.get(0))
      assert_equal("three", vec.attr.column_names.get(2))
      assert_equal(1, vec.attr.values.gz)

      vec.attr.column_names[(1..2)] = R.c("1", "2")
      assert_equal(true, (R.c("1", "2", "three", "four").eq vec.attr.column_names).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign special attributes to objects" do

      # simple matrix with dimnames
      mat = R.cbind(a: (1..3), pi: Math::PI) 

      # retrieve dimnames. dimnames is a list.
      lst = mat.attr.dimnames
      # dimnames is a list.  In R, dimnames is a list with two elements.  The first is NULL
      # (always?) and the second is an array with the actual names
      assert_equal("a", lst.get(1).get(0))
      assert_equal("pi", lst.get(1).get(1))

      # mat does also have attribute dim
      assert_equal(3, mat.attr.dim.get(0))
      assert_equal(2, mat.attr.dim.get(1))

      # We cannot set 'class' attribute in an R vector by calling .class as this is a 
      # Ruby method.  We substiture the .class method by .rclass.  However, in the R
      # namespace the attribute set is actually 'class'.
      mat.attr.rclass = "myClass"
      assert_equal("myClass", mat.attr.rclass.get(0))
      # retrieving the 'class' attribute by calling eval.
      assert_equal("myClass", R.eval("attr(#{mat.r}, \"class\")").gz)

      # Attribute 'comment' should not be seen when printed, but is there normally.  In
      # Renjin this attr does show up when printed
      mat.attr.comment = "this is my comment on this matrix"

      mat.pp
      
    end
=end
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "modify attributes in chains" do

      # define a list with given names as attr
      z = R.list(a: 1, b: "c", c: (1..3))
      assert_equal("a", z.attr.names.gz)
      assert_equal("b", z.attr.names.get(1))
      assert_equal("c", z.attr.names.get(2))

      # modify one of the names' attributes
      z.attr.names[3] = "c2"
      assert_equal(true, (R.c("a", "b", "c2").eq z.attr.names).gt)

      # modify all names attribute directly
      z.attr.names = R.c("d", "e", "f")
      assert_equal(true, (R.c("d", "e", "f").eq z.attr.names).gt)

      # create a vector with the names attribute. Vector names is now an alias to 
      # z.attr.names and it is not a copy of the names attribute.  Doing this is not
      # recomended as it can be hard to debug and identify vectors that "break the rule".
      names = z.attr.names
      names.pp
      # change the names vector
      names[1] = "g"
      # assert_equal(true, (R.c("g", "e", "f").eq names).gt)
      names.pp

      # differently from R, the names' attribute is also changed
      assert_equal(false, (R.c("d", "e", "f").eq z.attr.names).gt)
      assert_equal(true, (R.c("g", "e", "f").eq z.attr.names).gt)
      z.attr.names.pp



      # Vector names2 follows R rules and is a copy of names attribute.
      names2 = R.attr(z, "names")
      names2.pp
      # changing names2...
      names2[1] = "hello there"
      names2.pp

      # ... does not change the names attribute
      z.attr.names.pp

=begin
      # deep lists should work also
      z = R.list(a1: 1, b1: R.list(b11: "hello", b12: "there"), c1: "test")

      # Not working yet!!!
      z.attr.names.pp
      z[1].attr.names.pp
      z[1].attr.names[1] = "changed"
      z[1].attr.names.pp
=end


    end

    
  end

end
