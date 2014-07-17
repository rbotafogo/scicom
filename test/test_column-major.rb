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

      # creating two distinct instances of SciCom
      @r1 = R.new
      @r2 = R.new

    end


    #--------------------------------------------------------------------------------------
    # We should be able to create MDArray with different layouts such as row-major, 
    # column-major, or R layout.
    #--------------------------------------------------------------------------------------

    should "work with colum-major indexes" do

      col2 = MDArray.double([2, 3, 4], 
                            [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
                            17, 18, 19, 20, 21, 22, 23], 
                            :column)
      col2.print

      assert_equal(0, col2[0, 0, 0])
      assert_equal(3, col2[0, 0, 1])
      assert_equal(6, col2[0, 0, 2])
      assert_equal(9, col2[0, 0, 3])

      # slice the col array. take a slice of c on the first dimension (0) and taking only 
      # the first (0) index,we should get the following array:
      # [[0.00 3.00 6.00 9.00]
      #  [1.00 4.00 7.00 10.00]
      #  [2.00 5.00 8.00 11.00]]
      slice = col2.slice(0, 0)
      assert_equal(0, slice[0, 0])
      assert_equal(3, slice[0, 1])
      assert_equal(6, slice[0, 2])
      assert_equal(9, slice[0, 3])
      
    end

=begin
    
    #--------------------------------------------------------------------------------------
    # We should be able to create MDArray with different layouts such as row-major, 
    # column-major.
    #--------------------------------------------------------------------------------------

    should "work with R layout" do

      ret = @r1.eval("vec=c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23)")
      @r1.eval("dim(vec) = c(2, 3, 4)")

      p "returned array is"
      ret.print

      @r1.eval("print(vec[1, 1, 1])")
      @r1.eval("print(vec[1, 1, 2])")
      @r1.eval("print(vec[1, 1, 3])")
      @r1.eval("print(vec[1, 1, 4])")

    end


    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "raise when layout is unknown" do

      assert_raise ( RuntimeError ) { 
        MDArray.double([2, 2, 3], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], :unk)
      }
      
    end
=end
  end

end
