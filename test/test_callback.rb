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

    should "callback rpacked classe" do

      # create an array of data in Ruby
      array = [1, 2, 3]

      # pack the array only, not the internal elements
      ret = R.rpack(array, scope: :external)
      R.eval("val <- #{ret.r}$run('length')")
      R.eval("print(val)")

      R.eval(<<-EOT)
        #{ret.r}$run('<<', 4)
        #{ret.r}$run('<<', 5)
        #{ret.r}$run('delete', 5)
      EOT

      puts array

      hh = {:a => 1, :b =>2}
      r_hash = R.rpack(hh, scope: :external)
      R.eval("print(#{r_hash.r}$run('to_s'))")
      R.eval("print(val)")
      R.eval("#{r_hash.r}$run('[]=', 'hello', 'this is a string')")
      R.eval("print(#{r_hash.r}$run('to_s'))")

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
