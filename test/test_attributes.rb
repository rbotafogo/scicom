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
      assert_equal(nil, lst[[1]])
      assert_equal("a", lst[[2]][1].gz)
      assert_equal("pi", lst[[2]][2].gz)

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
      # z.attr.names.
      names = z.attr.names
      assert_equal(true, (R.c("d", "e", "f").eq names).gt)
      # change the names vector
      names[1] = "g"
      assert_equal(false, (R.c("d", "e", "f").eq names).gt)
      assert_equal(true, (R.c("g", "e", "f").eq names).gt)

      # differently from R, the names' attribute is also changed
      assert_equal(false, (R.c("d", "e", "f").eq z.attr.names).gt)
      assert_equal(true, (R.c("g", "e", "f").eq z.attr.names).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "unbind a vector from the attributes in chains" do

      # define a list with given names as attr
      z = R.list(a: 1, b: "c", c: (1..3))

      # change the names using normal call to R.c and channing
      z.attr.names = R.c("d", "e", "f")

      # create a vector with the names attribute. Vector names is now an alias to 
      # z.attr.names.
      names = z.attr.names
      assert_equal(true, (R.c("d", "e", "f").eq names).gt)

      # unbind names from z.attr.names.
      names.unbind

      # change the names vector
      names[1] = "g"
      assert_equal(false, (R.c("d", "e", "f").eq names).gt)
      assert_equal(true, (R.c("g", "e", "f").eq names).gt)

      # the names' attribute is NOT changed, as unbind on names was called
      assert_equal(true, (R.c("d", "e", "f").eq z.attr.names).gt)
      assert_equal(false, (R.c("g", "e", "f").eq z.attr.names).gt)

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "change attributes through normal R calls" do

     # define a list with given names as attr
      z = R.list(a: 1, b: "c", c: (1..3))

      # Vector names is a copy of names attribute.
      names = R.attr(z, "names")
      assert_equal(true, (R.c("a", "b", "c").eq z.attr.names).gt)

      # changing names...
      names[1] = "hello there"
      assert_equal(true, (R.c("hello there", "b", "c").eq names).gt)

      # ... does not change the names attribute and there is no need to call unbind,
      # as names was never bound to the chain
      assert_equal(true, (R.c("a", "b", "c").eq z.attr.names).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign attributes between objects" do

      # define a list with given names as attr
      z = R.list(a: 1, b: "c", c: (1..3))

      # define a vector with the same number of elements as the list
      vec = R.c((1..3))
      vec.attr.names = z.attr.names
      vec.attr.names[1] = "ggg"
      # changing vec names does not have any impact on z.names
      assert_equal(true, (R.c("ggg", "b", "c").eq vec.attr.names).gt)
      assert_equal(true, (R.c("a", "b", "c").eq z.attr.names).gt)

    end

  end

end
