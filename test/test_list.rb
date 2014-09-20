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

    should "create and access lists elements" do

      # create a list with named elements
      x = R.list(first: (1..10), second: R.c("yes","no"), third: R.c(TRUE,FALSE), 
        fourth: R.gl(2,3))
      
      # get the first element of the list, usign indexing.  Indexing with [] returns a 
      # list
      x[1].pp

      p "trying method %in%"
      (x._ :in, x).pp

      # get the third element of the list, usign indexing
      x[3].pp

      # should also access element of the list by name
      x["first"].pp
      x["second"].pp

=begin

      p "printing all elements of the list"
      x.each do |elmt|
        elmt.pp
      end

=end
    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
=begin
    should "access individual lists elements with [[]] notation" do

      # create a list with named elements
      x = R.list(first: (1..10), second: R.c("yes","no"), third: R.c(TRUE,FALSE), 
        fourth: R.gl(2,3))

      x[[1]].pp
      x[[2]].pp
      x[[3]].pp
      x[[4]].pp

      p "accessing with [[<name>]] notation"
      x[["first"]].pp

      p "indexing idexed list"
      x[1][[1]][[1]].pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "allow Ruby chaining" do

      # create a list with named elements
      x = R.list(first: (1..10), second: R.c("yes","no"), third: R.c(TRUE,FALSE), 
        fourth: R.gl(2,3))
      
      p x.first[1]
      x.second.pp
      x.third.pp
      x.fourth.pp

    end
=end
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
=begin

    should "be able to assign a Ruby array to R" do

      # converts the Ruby array to an R list
      names = ["Lisa", "Teasha", "Aaron", "Thomas"]
      R.people = names
      R.people.pp

      R.list = [1, 2, 3, 4, 5, 6]
      R.list.pp

      mix_vec = ["Lisa", 1, "John", 2, :marry, 3, {one: 1, two: 2} ]
      R.mix = mix_vec
      R.mix.pp

      # this gives an error in Renjin about Unmatched positional argument.  I think this is a
      # Renjin bug.
      R.str(R.list)

    end

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
