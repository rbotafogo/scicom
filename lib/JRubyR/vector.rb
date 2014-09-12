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


#==========================================================================================
#
#==========================================================================================

class Java::OrgRenjinSexp::StringArrayVector
  field_reader :values
end

class Java::OrgRenjinSexp::LogicalArrayVector
  field_reader :values
end

#==========================================================================================
#
#==========================================================================================

module RVector


end

#==========================================================================================
#
#==========================================================================================

class Renjin

  class Vector < Renjin::RubySexp
    include Enumerable

    attr_reader :mdarray

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def initialize(sexp)
      super(sexp)
      @mdarray = nil
      @iterator = @sexp.iterator()
    end
        
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def [](index)
      # index = index.r if index.is_a? Renjin::RubySexp
      index = R.parse(index)
      R.eval("#{r}[#{index}]")
    end
        
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def []=(index, value)
      # index = index.r if index.is_a? Renjin::RubySexp
      # value = value.r if value.is_a? Renjin::RubySexp
      index = R.parse(index)
      value = R.parse(value)
      R.eval("#{r}[#{index}] = #{value}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def length
      R.length(R.eval("#{r}")).gz
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def typeof
      R.typeof(R.eval("#{r}")).gz
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def integer?
      R.is__integer(R.eval("#{r}")).gt
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def double?
      R.is__double(R.eval("#{r}")).gt
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def logical?
      R.is__logical(R.eval("#{r}")).gt
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def character?
      R.is__character(R.eval("#{r}")).gt
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def atomic?
      R.is__atomic(R.eval("#{r}")).gt
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def numeric?
      R.is__numeric(R.eval("#{r}")).gt
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def ==(other_val)
      other_val = (other_val.is_a? Renjin::RubySexp)? other_val.r : other_val
      (other_val == nil)? false : R.eval("#{r} == #{other_val}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def eq(other_val)
      (other_val == nil)? false : R.eval("identical(#{r},#{other_val.r})")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def as__integer
      R.as__integer(self)
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def as__double
      R.as__double(self)
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def as__character
      R.as__character(self)
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def as__mdarray

      if (@mdarray)
      elsif (@sexp.instance_of? Java::RbScicom::MDDoubleVector)
        @mdarray = MDArray.build_from_nc_array(:double, @sexp.array)
      elsif (@sexp.instance_of? Java::OrgRenjinSexp::DoubleArrayVector)
        @mdarray = MDArray.from_jstorage("double", [@sexp.length()], @sexp.toDoubleArrayUnsafe())
      elsif (@sexp.instance_of? Java::OrgRenjinSexp::IntArrayVector)
        @mdarray = MDArray.from_jstorage("int", [@sexp.length()], @sexp.toIntArrayUnsafe())
      elsif (@sexp.instance_of? Java::OrgRenjinSexp::StringArrayVector)
        @mdarray = MDArray.from_jstorage("string", [@sexp.length()], @sexp.values)
      elsif (@sexp.instance_of? Java::OrgRenjinSexp::LogicalArrayVector)
        @mdarray = MDArray.from_jstorage("int", [@sexp.length()], @sexp.values)
      else
        p "sexp type needs to be specialized"
        p @sexp
        @mdarray = Renjin::Ruby@Sexp.new(@sexp)
      end
      
      raise "Cannot convert Vector to MDArray" if (!@mdarray)
      return @mdarray
      
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def get(index = nil)
      (index)? as__mdarray[index] : as__mdarray
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def gz
      get(0)
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def gt(index = 0)
      (get(index) == 0)? false : true
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

end

