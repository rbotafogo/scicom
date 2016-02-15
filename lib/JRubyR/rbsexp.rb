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

  module Index
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def [](*index)
      index = parse(index)
      R.eval("#{r}[#{index}]")
    end
        
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def []=(*index, value)
      index = parse(index)
      value = R.parse(value)
      R.eval("#{r}[#{index}] = #{value}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def parse(index)

      params = Array.new

      index.each do |i|
        if (i.is_a? Array)
          params << i
        else
          params << R.parse(i)
        end
      end
      
      ps = String.new
      params.each_with_index do |p, i|
        ps << "," if i > 0
        ps << ((p == "NULL")? "" : p.to_s)
      end

      ps

    end

    #----------------------------------------------------------------------------------------
    # Module Index is included in list and vector. We allow access to list/vector elements
    # by name.  Two underscores are replaced with a '.' in order to be able to call methods
    # in R that have a '.' such as is.na, becomes R.is__na. 
    #----------------------------------------------------------------------------------------

    def method_missing(symbol, *args)
      
      name = symbol.id2name
      name.gsub!(/__/,".")
      
      if name =~ /(.*)=$/
        # p "#{r}$#{$1} = #{args[0].r}"
        # ret = R.eval("#{r}[\"#{name}\"] = #{args[0].r}")
        ret = R.eval("#{r}$#{$1} = #{args[0].r}")
      elsif (args.length == 0)
        # treat name as a named item of the list
        if (R.eval("\"#{name}\" %in% names(#{r})").gt)
          ret = R.eval("#{r}[[\"#{name}\"]]")
        else
          ret = R.eval("#{name}(#{r})") if ret == nil 
        end
      elsif (args.length > 0)
        # p "#{name}(#{r}, #{R.parse(*args)})"
        ret = R.eval("#{name}(#{r}, #{R.parse(*args)})")
      else
        raise "Illegal argument for named list item #{name}"
      end
      
      ret
      
    end

    #----------------------------------------------------------------------------------------
    # We use the following notation to access binary R functions such as %in%:
    # R.vec_ "in", list.
    #----------------------------------------------------------------------------------------

    def _(*args)
      method = "%#{args.shift.to_s}%"
      arg2 = R.parse(*args)
      ret = R.eval("#{r} #{method} #{arg2}")
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def each(&block)
      while (@iterator.hasNext())
        block.call(@iterator.next())
      end
    end

  end

  #==========================================================================================
  # Module to wrapp every Renjin SEXP.
  #==========================================================================================

  module RBSexp
    include_package "org.renjin"
    include_package "java.lang"
    
    attr_reader :sexp
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
        # otherwise, assign itself to @rvar.
        (@sexp == nil)? R.assign(@rvar, self) : R.assign(@rvar, @sexp)
        
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
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def nrow
      R.nrow(self)
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def ncol
      R.ncol(self)
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
      # elsif (sexp.is_a? Java::OrgRenjinPrimitives::R$primitive$sum)
        # res = Renjin::Primitive.new(sexp)
      else
        puts "sexp type needs to be specialized: #{sexp}"
        res = Renjin::RubySexp.new(sexp)
      end
      
      return res
      
    end
    
  end

end

require_relative 'ruby_classes'
require_relative 'vector'
require_relative 'list'
require_relative 'function'
require_relative 'logical_value'
require_relative 'environment'
require_relative 'callback'
