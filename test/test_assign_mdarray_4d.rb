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

    should "convert 4D MDArrays to R arrays" do
      
      (0..5).each do 
        dim = [1 + rand(8), 1 + rand(8), 1 + rand(8), 1 + rand(8)]
        p "converting MDArray of shape #{dim} to R array"

        arr1 = MDArray.typed_arange(:double, dim.inject(:*))
        arr1.reshape!(dim)
        
        # arr1.print
        
        # convert to an R matrix
        r_matrix = R.md(arr1)
        
        # In order to simplify access to the R vector with different dimension specification
        # SciCom implements method 'ri' (r-indexing), so that arr1[dim1, dim2, dim3] is
        # equal to r_matrix.ri(dim1, dim2, dim3)
        compare = MDArray.byte(dim)
        (0..dim[0] - 1).each do |dim1|
          (0..dim[1] - 1).each do |dim2|
            (0..dim[2] - 1).each do |dim3|
              (0..dim[3] - 1).each do |dim4|
                compare[dim1, dim2, dim3, dim4] = 
                  (arr1[dim1, dim2, dim3, dim4] == (r_matrix.ri(dim1, dim2, dim3, dim4).gz))? 1 : 0
              end
            end
          end
        end
        comp = R.md(compare)
        assert_equal(true, comp.all.gt)
      end
      
    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
=begin
    should "work with MDArray slices" do

      dim = [6, 4, 3, 2]

      # create a 1D MDArray
      arr1 = MDArray.typed_arange(:double, dim.inject(:*))
      arr1.reshape!(dim)
      
      slice = arr1.slice(0, 0)
      slice.print
      mat = R.md(slice)
      mat.pp

      slice = arr1.slice(0, 1)
      slice.print
      mat = R.md(slice)
      mat.pp

    end
=end    
  end
  
end

