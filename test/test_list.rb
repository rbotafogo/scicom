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

      # create a list with named elements
      @x = R.list(first: (1..10), second: R.c("yes","no"), third: R.c(TRUE,FALSE), 
        fourth: R.gl(2,3))
      
      @seq = R.c((1..10))
      @seq2 = R.c((1...10))
      @str_vec = R.c("yes", "no")
      @str_vec2 = R.c("yes", "yes")
      @trth_vec = R.c(TRUE, FALSE)
      @trth_vec2 = R.c(FALSE, FALSE)
      @gl = R.gl(2, 3)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "access list elements with indexing [] and [[]]" do
      
      # get the first element of the list, usign indexing.  
      # Both [] and [[]] indexing can be used with the same R rules. 
      # Indexing with [] returns a list
      assert_equal("list", @x[1].typeof.gz)

      # Indexing with [[]] return the sequence type wich is "integer" is this case
      assert_equal("integer", @x[[1]].typeof.gz)

      # Multiple indexing is OK.
      assert_equal("integer", @x[1][[1]].typeof.gz)
      assert_equal("integer", @x[1][[1]][1].typeof.gz)

      # Getting the Ruby value of a vector is done with method get. Method gz is equivalent
      # to get(0)
      assert_equal(1, @x[1][[1]][1].gz)
      assert_equal(1, @x[[1]][1].gz)
      assert_equal(3, @x[[1]][3].gz)
      assert_equal(10, @x[[1]][10].gz)

      # to get the class of an RBSexp we need to call method rclass.  We cannot call method
      # class on it as it will return the Ruby class ('class' is a Ruby method).
      assert_equal("list", @x.rclass.gz)

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "acess list elements by named item" do

      # should also access element of the list by name.  Every element of the lists is a 
      # list
      assert_equal("list", @x["second"].typeof.gz)
      assert_equal("character", @x[["second"]].typeof.gz)
      assert_equal("yes", @x[["second"]][1].gz)
      assert_equal(2, @x[["fourth"]][4].gz)
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "assign to lists elements" do

      # assign to the list
      @x[1] = "new list element"
      assert_equal("new list element", @x[[1]].gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "access individual lists elements with [[]] notation" do

      assert_equal(true, R.all(@seq == @x[[1]]).gt)
      assert_equal(false, R.all(@seq2 == @x[[1]]).gt)

      assert_equal(true, R.all(@str_vec == @x[[2]]).gt)
      assert_equal(false, R.all(@str_vec2 == @x[[2]]).gt)

      assert_equal(true, R.all(@trth_vec == @x[[3]]).gt)
      assert_equal(false, R.all(@trth_vec2 == @x[[3]]).gt)

      assert_equal(true, R.all(@gl == @x[[4]]).gt)

      # accessing with the [[<name>]] notation
      assert_equal(true, R.all(@seq == @x[["first"]]).gt)
      assert_equal(false, R.all(@seq2 == @x[["first"]]).gt)

      assert_equal(true, R.all(@str_vec == @x[["second"]]).gt)
      assert_equal(false, R.all(@str_vec2 == @x[["second"]]).gt)

      assert_equal(true, R.all(@trth_vec == @x[["third"]]).gt)
      assert_equal(false, R.all(@trth_vec2 == @x[["third"]]).gt)

      assert_equal(true, R.all(@gl == @x[["fourth"]]).gt)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "allow Ruby chaining" do

      assert_equal(true, R.all(@seq == @x.first).gt)
      assert_equal(false, R.all(@seq2 == @x.first).gt)

      assert_equal(true, R.all(@str_vec == @x.second).gt)
      assert_equal(false, R.all(@str_vec2 == @x.second).gt)

      assert_equal(true, R.all(@trth_vec == @x.third).gt)
      assert_equal(false, R.all(@trth_vec2 == @x.third).gt)

      assert_equal(true, R.all(@gl == @x.fourth).gt)
            
      # multiple indexing
      assert_equal(1, @x.first[1].gz)
      assert_equal(1, @x.first[[1]].gz)

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "be able to call functions on lists" do

      p "trying method %in%"
      (@x._ :in, @x).pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "be able to assign a Ruby array to R (not really recommended)" do

      # names is a Ruby array
      names = ["Lisa", "Teasha", "Aaron", "Thomas"]

      # Ruby Arrays can be used as arguments to R functions.  An Ruby Array will be
      # converted to an R list.
      people = R.identity(names)
      people.pp

      # If a Ruby Array is assigned to an R variable, this R variable is a list.  Note
      # that variable 'people' above and variable 'R.people' are two different variables.
      # While the first is defined in the Ruby environment, the second is defined in 
      # R environment.
      R.people = names
      R.people.pp

      R.lst = [1, 2, 3, 4, 5, 6]
      R.lst.pp

      lst = R.identity([1, 2, 3])
      lst.pp

      # Using hash inside an Array does not work properly! This list will have 5
      # elements and the fifth is empty.  
      mv = ["Lisa", 1, "John", 2, mary: 3, john: 4]
      print mv

      mix_vec = R.identity(["Lisa", 1, "John", 2, mary: 3, john: 4])
      mix_vec.pp

      # this gives an error in Renjin about Unmatched positional argument. Renjin bug already
      # reported
      # R.str(R.lst)

    end


  end

end
