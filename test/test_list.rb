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

    should "work with list" do

      x = R.list(first: (1..10), second: R.c("yes","no"), third: R.c(TRUE,FALSE), 
        fourth: R.gl(2,3))
      x.first.print
      x.second.print
      x.fourth.print
      x[0].print

      assert_raise ( RuntimeError ) { x.third(3) }

      x.each do |elmt|
        elmt.print
      end

      # list with R options
      opts = R.options

      opts.each do |opt|
        opt.print
      end

      lst = R.list(5, R.c(1, 2, 3), opts)
      lst[0].print
      lst[2].na__action.print

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

      mix_vec = ["Lisa", 1, "John", 2, :marry, 3, {one: 1, two: 2} ]
      R.mix = mix_vec
      R.mix.pp

      # this gives an error in Renjin about Unmatched positional argument.  I think this is a
      # Renjin bug.
      R.str(R.list)

    end

  end

end
