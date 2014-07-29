# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
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

require 'java'

require_relative 'renjin'

class R
  
  @renjin = Renjin.new

  class << self
    attr_reader :renjin
  end
    
  #----------------------------------------------------------------------------------------
  # Converts an MDArray shape or index onto an equivalent R shape or index
  #----------------------------------------------------------------------------------------

  def self.ri(shape)

    rshape = shape.clone

    if (rshape.size > 2)
      rshape.reverse!
      rshape[0], rshape[1] = rshape[1], rshape[0]
    end
    rshape.map{ |val| (val + 1) }

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.epsilon
    Renjin.epsilon
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.Int_NA
    Renjin.Int_NA
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.Double_NA
    Renjin.Double_NA
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.Double_NaN
    Renjin.Double_NaN
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.nan?(x)
    Renjin.nan?(x)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.na?(x)
    Renjin.na?(x)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.finite?(x)
    Renjin.finite?(x)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------
  
  def self.assign(name, value)
    @renjin.assign(name, value)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.pull(name)
    @renjin.pull(name)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.eval(string)
    @renjin.eval(string)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.seq(*args)
    params = args.join(",")
    @renjin.eval("seq(#{params})")
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.c(*args)
    params = args.join(",")
    @renjin.eval("c(#{params})")
  end

  #----------------------------------------------------------------------------------------
  # If a method is called which is not defined, then it is assumed that the user is 
  # attempting to either pull or assign a variable to R.  This allows for the short-hand 
  # equivalents to the pull and assign methods.  For example:
  #
  #      >> R.x = 2
  #
  # is the same as:
  #
  #      >> R.assign("x",2)
  #
  # Also:
  #
  #      >> n = R.x
  #
  # is the same as:
  #
  #      >> n = R.pull("x")
  #
  # The parameters passed to method_missing are those used for the pull or assign 
  # depending on the context.
  #----------------------------------------------------------------------------------------
  
  def self.method_missing(symbol, *args)

    name = symbol.id2name
    if name =~ /(.*)=$/
      # should never reach this point.  Parse error... but check
      # raise ArgumentError, "You shouldn't assign nil" if args==[nil]
      super if args.length != 1
      @renjin.assign($1,args[0])
    else
      super if args.length != 0
      @renjin.pull(name)
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize
    @instance = Renjin.new
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def method_missing(symbol, *args)

    name = symbol.id2name
    if name =~ /(.*)=$/
      # should never reach this point.  Parse error... but check
      # raise ArgumentError, "You shouldn't assign nil" if args==[nil]
      super if args.length != 1
      @instance.assign($1,args[0])
    else
      super if args.length != 0
      @instance.pull(name)
    end

  end

end

