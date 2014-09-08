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
      vec.attributes.name = "my.attribute"
      vec.attributes.truth = true
      vec.attributes.column_names = R.c("one", "two", "three", "four")
      vec.attributes.values = R.c((1..3))
      vec.pp

      # retrieve attributes
      assert_equal("my.attribute", vec.attributes.name.gz)
      assert_equal(true, vec.attributes.truth.gt)
      assert_equal("one", vec.attributes.column_names.get(0))
      assert_equal("three", vec.attributes.column_names.get(2))
      assert_equal(1, vec.attributes.values.gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign special attributes to objects" do

      # simple matrix with dimnames
      mat = R.cbind(a: (1..3), pi: Math::PI) 

      # retrieve dimnames. dimnames is a list.
      lst = mat.attributes.dimnames
      # dimnames is a list.  In R, dimnames is a list with two elements.  The first is NULL
      # (always?) and the second is an array with the actual names
      assert_equal("a", lst.get(1).get(0))
      assert_equal("pi", lst.get(1).get(1))

      # mat does also have attribute dim
      assert_equal(3, mat.attributes.dim.get(0))
      assert_equal(2, mat.attributes.dim.get(1))

      # We cannot set 'class' attribute in an R vector by calling .class as this is a 
      # Ruby method.  We substiture the .class method by .rclass.  However, in the R
      # namespace the attribute set is actually 'class'.
      mat.attributes.rclass = "myClass"
      assert_equal("myClass", mat.attributes.rclass.get(0))
      # retrieving the 'class' attribute by calling eval.
      assert_equal("myClass", R.eval("attr(#{mat.r}, \"class\")").gz)

      # Attribute 'comment' should not be seen when printed, but is there normally.  In
      # Renjin this attributes does show up when printed
      mat.attributes.comment = "this is my comment on this matrix"

      mat.pp
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "also work with lists" do

      z = R.list(a: 1, b: "c", c: (1..3))
      assert_equal("a", z.attributes.names.gz)
      assert_equal("b", z.attributes.names.get(1))
      assert_equal("c", z.attributes.names.get(2))

      z.attributes.names[2] = "c2"

      z.attributes.names.pp

    end

    
  end

end
