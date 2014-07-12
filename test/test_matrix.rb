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

    should "send 2D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 12)
      arr.reshape!([4, 3])

      # assign MDArray to R vector.  MDArray shape is converted to R shape: two dimensions
      # are identical in MDArray and R.
      @r1.vec = arr

      # When accessing a vector with the wrong indexes, return nil
      res = @r1.eval("vec[0]")
      assert_equal(nil, res)

      # First index in R is 1 and not 0.
      # method R.ct converts an MDArray counter to a R counter (in string format) ready
      # to evaluate
      arr.each_with_counter do |val, ct|
        assert_equal(val, @r1.eval("vec#{R.ct(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 3D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 60)
      # MDArray is stored in row-major order
      arr.reshape!([5, 3, 4])
      arr.print

      # shape of @r1.vec is [3, 4, 5].  Although R is normally column-major order, in order
      # to send the data without copying to R, the row-major order of the original MDArray
      # is preserved.
      @r1.vec = arr
      @r1.eval("print(dim(vec))")
      # bug in Renjin does not print the array correctly, rather prints a vector.  Issue 
      # already opened with Renjin
      @r1.eval("print(vec)")

=begin
      arr.each_with_counter do |val, ct|
        assert_equal(arr.get(ct), @r1.eval("vec#{R.ct(ct)}"))
      end
=end

    end

=begin

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "send 4D arrays to Renjin" do

      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 120)
      arr.reshape!([2, 4, 3, 5])
      @r1.vec = arr
      arr.each_with_counter do |val, ct|
        assert_equal(val, @r1.eval("vec#{R.ct(ct)}"))
      end

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "receive multidimensional arrays from Renjin" do

      # returned value is column major but MDArray is interpreting as row major
      mat = @r1.eval(" mat = matrix(rnorm(20), 4)")
      mat.print
      @r1.eval("print(mat)")
    end
=end

  end
  
end
