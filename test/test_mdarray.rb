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
    
    should "assign MDArray to R transparently" do

      # MDArray instances created in Ruby namespace can also be access in the R
      # namespace with the r method:
      array = MDArray.typed_arange(:double, 18)
      R.eval("print(#{array.r})")

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------
    
    should "create MDArrays from R methods" do

      # R.c creates a MDArray.  In general it will be a double MDArray
      res = R.c(2, 3, 4, 5)
      assert_equal("double", res.type)
      assert_equal(4, res.size)

      # to create an int MDArray with R.c, all elements need to be integer.  To create an
      # int we need R.i method
      res = R.c(R.i(2), R.i(3), R.i(4))
      assert_equal("int", res.type)
      assert_equal(3, res.size)

      # using == method from MDArray.  It returns an boolean MDArray
      res = (R.c(2, 3, 4) == R.c(2, 3, 4))
      assert_equal("boolean", res.type)

      # array multiplication
      (R.c(2, 3, 4) * R.c(5, 6, 7)).pp

      # A sequence also becomes an MDArray
      res = R.seq(10, 40)
      res.print

      res = R.rep(R.c(1, 2, 3), 3)
      res.print

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "use MDArray in R" do
      
      # create a double MDArray
      vec  = MDArray.typed_arange(:double, 12)
      vec.print

      # assign the MDArray to an R vector "my.vec"
      R.my__vec = vec

      # print R's "my.vec"
      R.eval("print(my.vec)")

      # use the .r method in MDArray's to get the MDArray value in R
      R.eval("print(#{vec.r})")

      # Passing an MDArray without assigning it in a R vector is also possible
      R.eval("print(#{MDArray.typed_arange(:double, 5).r})")

    end

  end

end
