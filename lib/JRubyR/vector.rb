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

class Renjin

  class Vector < Renjin::RubySexp
    include Enumerable
    include Renjin::Index

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

    def integer?
      R.eval("#{r}").is__integer.gt
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

    def complex?
      R.is__complex(R.eval("#{r}")).gt
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
=begin
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

    def as__complex
      R.as__complex(self)
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def as__character
      R.as__character(self)
    end
=end
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def as__mdarray

      if (@mdarray)
      elsif (@sexp.java_kind_of? Java::RbScicom::MDDoubleVector)
        @mdarray = MDArray.build_from_nc_array(:double, @sexp.array)
      elsif (@sexp.java_kind_of? Java::OrgRenjinSexp::DoubleArrayVector)
        @mdarray = MDArray.from_jstorage("double", [@sexp.length()], @sexp.toDoubleArrayUnsafe())
      elsif (@sexp.java_kind_of? Java::OrgRenjinSexp::IntArrayVector)
        @mdarray = MDArray.from_jstorage("int", [@sexp.length()], @sexp.toIntArrayUnsafe())
      elsif (@sexp.java_kind_of? Java::OrgRenjinSexp::StringArrayVector)
        @mdarray = MDArray.from_jstorage("string", [@sexp.length()], @sexp.values)
      elsif (@sexp.java_kind_of? Java::OrgRenjinSexp::LogicalArrayVector)
        @mdarray = MDArray.from_jstorage("int", [@sexp.length()], @sexp.values)
      else
        p "sexp type needs to be specialized: #{@sexp}"
        # p @sexp
        @mdarray = Renjin::RubySexp.new(@sexp)
      end
      
      raise "Cannot convert Vector to MDArray" if (!@mdarray)
      return @mdarray
      
    end
    
    #----------------------------------------------------------------------------------------
    # Converts an MDArray shape or index onto an equivalent R shape or index
    #----------------------------------------------------------------------------------------
    
    def ri(*shape)
      
      rshape = shape.clone
      
      if (rshape.size > 2)
        rshape.reverse!
        rshape[0], rshape[1] = rshape[1], rshape[0]
      end
      rshape.map!{ |val| (val + 1) }
      self[*rshape]
      
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

    def +@
      R.eval("+#{r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def -@
      R.eval("-#{r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def +(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} + #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def -(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} - #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def *(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} * #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def /(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} / #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    # modulus
    #----------------------------------------------------------------------------------------

    def %(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} %% #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def int_div(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} %/% #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    # exponentiation
    #----------------------------------------------------------------------------------------

    def **(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} ** #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def >(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} > #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def >=(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} >= #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def <(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} < #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def <=(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} <= #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def !=(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} != #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
=begin
    def !
      R.eval("!#{r}")
    end
=end
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def &(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} & #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    # l_and looks at only the first element of the vector
    #----------------------------------------------------------------------------------------

    def l_and(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} && #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    # or
    #----------------------------------------------------------------------------------------

    def |(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} | #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def l_or(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} || #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def xor(other_vec)
      if (other_vec.is_a? Numeric)
        other_vec = R.d(other_vec)
      end
      R.eval("#{r} xor #{other_vec.r}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def coerce(scalar)
      [R.d(scalar), self]
    end

  end

end

#==========================================================================================
#
#==========================================================================================

class Renjin

  class ComplexVector < Renjin::Vector

    #----------------------------------------------------------------------------------------
    # Returns a vector with the real part of this vector
    #----------------------------------------------------------------------------------------

    def re
      R.Re(self)
    end

    #----------------------------------------------------------------------------------------
    # Returns a vector with the imaginary part of this vector
    #----------------------------------------------------------------------------------------

    def im
      R.Im(self)
    end

    #----------------------------------------------------------------------------------------
    # Returns a vector with the modulus of this vector
    #----------------------------------------------------------------------------------------

    def mod
      R.Mod(self)
    end

    #----------------------------------------------------------------------------------------
    # Returns a vector with the argument of this complex vector
    #----------------------------------------------------------------------------------------

    def arg
      R.Arg(self)
    end

    #----------------------------------------------------------------------------------------
    # Returns a vector with the conjugate of this complex vector
    #----------------------------------------------------------------------------------------

    def conj
      R.Conj(self)
    end

  end

end
