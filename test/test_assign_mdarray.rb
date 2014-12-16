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

    should "convert MDArrays to R arrays" do

      #--------------------------------------------------------------------------------------
      #
      #--------------------------------------------------------------------------------------

      def to_r(dim, type)

        dims = Array.new
        (0...dim).each do |s|
          dims[s] = rand(1..8)
        end

        p "converting MDArray of shape #{dims} and type #{type} to R array"

        case type
        when :byte
          arr1 = MDArray.byte(dims)
        when :string
          arr1 = MDArray.init_with("string", dims, "this is a string")
        else
          arr1 = MDArray.typed_arange(type.to_s, dims.inject(:*))
        end
        
        arr1.reshape!(dims)
        
        # convert to an R matrix
        r_matrix = R.md(arr1)
        
        # A byte MDArray is converted to a Logical vector in R.  Boolean MDArrays cannot be 
        # converted to logical vectors efficiently in Renjin.
        compare = MDArray.byte(dims)

        # In order to simplify access to the R vector with different dimension specification
        # SciCom implements method 'ri' (r-indexing), so that arr1[dim1, dim2, dim3] is
        # equal to r_matrix.ri(dim1, dim2, dim3)
        arr1.get_index.each do |ct|
          compare[*ct] = (arr1[*ct] == (r_matrix.ri(*ct).gz))? 1 : 0
        end

        # Convert the byte MDArray to an R vector.
        comp = R.md(compare)
        # use the .all method from R to verify that all elements in the vector all TRUE
        assert_equal(true, comp.all.gt)
        
      end

      #--------------------------------------------------------------------------------------
      # Check conversion of 5 different arrays for dimensions from 1 to 7 (which are 
      # optimized) and also for 8 to 10 dimensions (that are not optimized)
      #--------------------------------------------------------------------------------------

      
      [:char, :long, :float].each do |type|
        # convert to an R matrix
        arr1 = MDArray.build(type, [2])
        assert_raise ( RuntimeError ) { r_matrix = R.md(arr1) }
      end
      
      #--------------------------------------------------------------------------------------
      # Check conversion of 5 different arrays for dimensions from 1 to 7 (which are 
      # optimized) and also for 8 to 10 dimensions (that are not optimized)
      #--------------------------------------------------------------------------------------

=begin
      [:byte, :int, :double, :string].each do |type|
        (1..5).each do |dim|
          (0...2).each do
            to_r(dim, type)
          end
        end
      end
=end

      [:double].each do |type|
        (8..8).each do |dim|
          (0...2).each do
            to_r(dim, type)
          end
        end
      end

    end

  end
  
end
