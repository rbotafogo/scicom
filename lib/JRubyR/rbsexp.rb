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

require_relative "attributes"

#==========================================================================================
#
#==========================================================================================

class Renjin

  #==========================================================================================
  # Module to wrapp every Renjin SEXP.
  #==========================================================================================

  module RBSexp
    include_package "org.renjin"
    include_package "java.lang"
    
    attr_reader :sexp
    attr_reader :refresh
    attr_reader :rvar
    attr_reader :attr
    attr_accessor :scope
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def destroy
      
      if (@rvar != nil)
        @sexp = R.direct_eval("#{@rvar}")
        # change value in the scope
        if (@scope)
          R.direct_eval("#{scope[0]}(#{scope[1].r}, \"#{scope[2]}\") = #{@rvar}")
          # @scope = nil
        end
        R.direct_eval("rm('#{@rvar}')")
        @rvar = nil
        
      end
      
    end
    
    #----------------------------------------------------------------------------------------
    # Push the object into the R evaluator.  Check to see if this object already has an R
    # value (rvar).  The rvar is just a string of the form sc_xxxxxxxx. This string will be
    # an R variable that holds the SEXP.  
    #----------------------------------------------------------------------------------------
    
    def r
      
      if (@rvar == nil)
        # create a new variable name to hold this object inside R
        @rvar = "sc_#{SecureRandom.hex(8)}"
        
        # if this object already has a sexp value then assign to @rvar the existing sexp,
        # otherwise, assign itself to @rvar.  If a sexp already exists then set the
        # refresh flag to true, so that we know that the sexp was changed.
        # (@sexp == nil)? R.assign(@rvar, self) : R.assign(@rvar, @sexp)
        if (@sexp.nil?)
          R.assign(@rvar, self)
        else
          @refresh = true
          R.assign(@rvar, @sexp)
        end
        
        # Whenever a variable is injected in Renjin, it is also added to the Renjin stack.
        # After eval, every injected variable is removed from Renjin making sure that we
        # do not have memory leak.
        Renjin.stack << self
        
      end
      
      @rvar
      
    end

    #----------------------------------------------------------------------------------------
    # * @return true if this RubySexp already points to a sexp in R environment
    #----------------------------------------------------------------------------------------
    
    def sexp?
      sexp != nil
    end
    
    #----------------------------------------------------------------------------------------
    # Scope is used for accessing attribute values for an R object.
    #----------------------------------------------------------------------------------------
    
    def unbind
      @scope = nil
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def typeof
      R.typeof(R.eval("#{r}"))
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def rclass
      R.rclass(R.eval("#{r}"))
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def print
      # Kernel.print(Java::OrgRenjinPrimitives::Print.doPrint(sexp))
      R.eval("print(#{r})")
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def pp
      print
    end
    
  end
  
end

#==========================================================================================
#
#==========================================================================================

class Renjin

  class RubySexp
    include Renjin::RBSexp
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def initialize(sexp)

      @sexp = sexp
      @rvar = nil
      @attr = Attributes.new(self)

    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def to_string
      R.eval("toString(#{r})")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def fassign(function, value)
      R.fassign(self, function, value)
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def self.build(sexp)
      
      if (sexp.java_kind_of? Java::OrgRenjinSexp::Null)
        res = nil
      elsif (sexp.java_kind_of? Java::OrgRenjinSexp::ListVector)
        res = Renjin::List.new(sexp)
      elsif (sexp.java_kind_of? Java::OrgRenjinSexp::LogicalArrayVector)
        res = Renjin::Logical.new(sexp)
      elsif (sexp.java_kind_of? Java::OrgRenjinSexp::Environment)
        res = Renjin::Environment.new(sexp)
      elsif (sexp.is_a? Java::OrgRenjinSexp::ComplexVector)
        res = Renjin::ComplexVector.new(sexp)
      elsif (sexp.is_a? Java::OrgRenjinSexp::Vector)
        res = Renjin::Vector.new(sexp)
      elsif (sexp.is_a? Java::OrgRenjinSexp::Closure)
        res = Renjin::Closure.new(sexp)
      elsif (sexp.is_a? Java::OrgRenjinSexp::ExternalPtr)
        res = Renjin::RubySexp.new(sexp)
      # elsif (sexp.is_a? Java::OrgRenjinPrimitives::R$primitive$sum)
        # res = Renjin::Primitive.new(sexp)
      else
        puts "rbsexp build: sexp type needs to be specialized: #{sexp}"
        res = Renjin::RubySexp.new(sexp)
      end
      
      return res
      
    end
    
  end

end

require_relative 'ruby_classes'
require_relative 'indexed'
require_relative 'function'
require_relative 'logical_value'
require_relative 'environment'
require_relative 'callback'
