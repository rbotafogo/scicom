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

require '../config' if @platform == nil
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

    should "callback rpacked classes Array and Hash" do

      # create an array of data in Ruby
      array = [1, 2, 3]

      # Pack the array and assign it to an R variable.  Remember that ruby__array, becomes
      # ruby.array inside the R script
      R.ruby__array = R.rpack(array)

      # note that this calls Ruby method 'length' on the array and not R length function.
      R.eval("val <- ruby.array$run('length')")
      assert_equal(3, R.val.gz)

      # Let's use a more interesting array method '<<'.  This method adds elements to the
      # end of the array.  

      R.eval(<<-EOT)
        print(typeof(ruby.array))
        ruby.array$run('<<', 4)
        ruby.array$run('<<', 5)
      EOT
      assert_equal(4, array[3])
      assert_equal(5, array[4])

      # Although the concept of chainning is foreign to R, it does apply to packed
      # classes
      R.eval(<<-EOT)
        ruby.array$run('<<', 6)$run('<<', 7)$run('<<', 8)$run('<<', 9)
      EOT
      assert_equal(9, array[8])
      
      # Let's try another method... remove a given element from the array
      R.eval(<<-EOT)
        ruby.array$run('delete', 4)
      EOT
      assert_equal(5, array[3])

      # We can also acess any array element inside the R script, but note that we have
      # to use Ruby indexing, i.e., the first element of the array is index 0
      R.eval(<<-EOT)
        print(ruby.array$run('[]', 0))
        print(ruby.array$run('[]', 2))
        print(ruby.array$run('[]', 4))
        print(ruby.array$run('[]', 6))
      EOT

      # Try the same with a hash
      hh = {"a" => 1, "b" =>2}

      # Pack the hash and store it in R variable r.hash
      R.r__hash = R.rpack(hh, scope: :external)

      # Retrieve the value of a key
      R.eval(<<-EOT)
        h1 <- r.hash$run('[]', "a")
        h2 <- r.hash$run('[]', "b")
      EOT
      assert_equal(1, R.h1.gz)
      assert_equal(2, R.h2.gz)

      # Add values to the hash
      R.eval(<<-EOT)
        h1 <- r.hash$run('[]=', "c", 3)
        h2 <- r.hash$run('[]=', "d", 4)
      EOT
      assert_equal(3, hh["c"])
      assert_equal(4, hh["d"])
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "allow use of Ruby classes and objects inside an R script" do

      R.eval(<<-EOT)
        # This is an actuall R script, which allows the creation and use of Ruby classes
        # and methods.
        # Create a string, from class String in Ruby.  Use function build to intanciate a 
        # new object
        string <- Ruby.Object$build("String", "this is a new string")

        # Use function get_class to get a Ruby class
        Marshal <- Ruby.Object$get_class("Marshal")

        # Method 'dump' is a Marshal class method as is 'load' 
        str <- Marshal$run("dump", string)
        restored <- Marshal$run("load", str)
      EOT
      
      assert_equal("this is a new string", R.string.gz)
      assert_equal(Marshal.dump("this is a new string"), R.str.gz)
      assert_equal("this is a new string", R.restored.gz)

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "callback all internal elements" do

      # Create two arrays and store them in a third array
      props1 = [1, 2, 3]
      props2 = [10, 20]
      props = [props1, props2]

      # rpack the internal's of the container array props, i.e, pack only arrays
      # props1 and props2.  Array props is not being packed as Ruby arrays are morphed
      # into R lists.  And a list good for what we want.  In order to work on R side
      # we store the packed array into variable 'jake'
      R.jake = R.rpack(props, scope: :internal)

      R.eval(<<-EOT)
        # We want to find the vector with the least elements we have stored.  We can use
        # sapply to get the length of all vectors.  Although variable 'jake' is a regular
        # R list, it's internal elements are rpacked Ruby objects
        smallest <- which.min(sapply(jake, function(x) x$run("length")))

        # Remember, the list has only rpacked Ruby objects.  To print it, we need to convert
        # it to a string.
        print(jake[[smallest]]$run('to_s'))
      EOT
      
      # R.eval("val <- sapply(jake, function(x) x$run('length'))")

    end
    
  end
  
end
