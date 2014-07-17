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
    #
    #--------------------------------------------------------------------------------------

    should "receive an original 2D MDArray send to Renjin back" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 12)
      arr.reshape!([4, 3])
      # assign MDArray to R vector.  MDArray shape is converted to R shape: two dimensions
      # are identical in MDArray and R.
      @r1.vec = arr

      arr2 = @r1.vec

      arr.each_with_counter do |elmt, ct|
        assert_equal(elmt, arr2.get(ct))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "receive an original 3D MDArray send to Renjin back" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 60)
      # MDArray is stored in row-major order
      arr.reshape!([5, 3, 4])
      # shape of @r1.vec is [3, 4, 5].  
      @r1.vec = arr

      arr2 = @r1.vec

      arr.each_with_counter do |elmt, ct|
        assert_equal(elmt, arr2.get(ct))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "receive a 2D Renjin vector as MDArray" do

      @r1.eval("vec = seq(12)")
      @r1.eval("as.double(vec)")

      arr2 = @r1.vec

      arr.each_with_counter do |elmt, ct|
        assert_equal(elmt, arr2.get(ct))
      end

    end

  end

end
