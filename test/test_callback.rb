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

      # pack the array only, not the internal elements, scope: is :external
      ret = R.rpack(array, scope: :external)

      # Use 'ret.r' to convert the Ruby 'ret' variable to an r variable
      # note that this calls Ruby method 'length' on the array and not R length function.
      R.eval("val <- #{ret.r}$run('length')")
      assert_equal(3, R.val.gz)

      # Let's use a more interesting array method '<<'.  This method adds elements to the
      # end of the array.  But before that, to simplify the code, let's create a variable
      # in R so we do not need to user #{ret.r}. 
      R.ruby__array = ret

      # Remember that ruby__array, becomes ruby.array inside the R script
      R.eval(<<-EOT)
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


      R.Ruby__Object = R.rpack(Object)
      
      R.eval(<<-EOT)
        String <- Ruby.Object$run("const_get", "String")
        string <- String$run("new", "this is a new string")
        Marshal <- Ruby.Object$run("const_get", "Marshal")
        str <- Marshal$run("dump", string)
        print(str)
        restored <- Marshal$run("load", str)
        print(restored)
      EOT
      
    end
=begin
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "callback all internal elements" do
      
      props1 = [1, 2, 3]
      props2 = [1, 2]
      props = [props1, props2]

      R.rpack(props, scope: :internal)
      R.eval("val <- sapply(#{array.r}, function(x) x$run('length'))")
      p props

    end
    
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "callback all internal elements" do

      ret = R.rpack(props, scope: :all)
      p ret

    end
=end
  end
  
end



=begin
    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "work with varargs" do

      class Bogus
        include Java::RbScicom.BogusInterface
        
        attr_reader :ruby_obj
        
        #----------------------------------------------------------------------------------------
        #
        #----------------------------------------------------------------------------------------
        
        def initialize(ruby_obj)
          @ruby_obj = ruby_obj
        end
        
        #----------------------------------------------------------------------------------------
        #
        #----------------------------------------------------------------------------------------
        
        def run(method, *args)
          @ruby_obj.send(method, *args)
        end
        
      end
      
      props1 = [1, 2, 3]
      
      cb = Bogus.new(props1)
      R.assign("x", cb)
      R.eval("x$run('length')")

    end
=end
