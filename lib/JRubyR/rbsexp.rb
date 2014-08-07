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

#==========================================================================================
#
#==========================================================================================

class RubySexp

  attr_reader :sexp
  attr_reader :rvar

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(sexp)

    @sexp = sexp
    @rvar = nil

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def type_name
    @sexp.getTypeName()
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def destroy
    
    if (@rvar != nil)
      R.eval("rm('#{@rvar}')")
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def numeric?
    @sexp.isNumeric()
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def r

    if (@rvar == nil)
      @rvar = "sc_#{SecureRandom.hex(8)}"
      R.assign(@rvar, @sexp)
    end
    @rvar

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def self.build(sexp)
    
    if (sexp.instance_of? Java::OrgRenjinPrimitivesSequence::IntSequence)
      res = IntSeq.new(sexp)
    elsif (sexp.instance_of? Java::OrgRenjinSexp::ListVector)
      res = ListVector.new(sexp)
    elsif (sexp.instance_of? Java::RbScicom::MDDoubleVector)
      res = MDArray.build_from_nc_array(:double, sexp.array)
      res.set_sexp(sexp)
      # set return vector as immutable, as Renjin assumes it.
      res.immutable
    elsif (sexp.instance_of? Java::OrgRenjinSexp::DoubleArrayVector)
      res = MDArray.from_jstorage("double", [sexp.length()], sexp.toDoubleArrayUnsafe())
      if (res != nil)
        res.set_sexp(sexp)
        # set return vector as immutable, as Renjin assumes it.
        res.immutable
      end
    elsif (sexp.instance_of? Java::OrgRenjinSexp::IntArrayVector)
      res = MDArray.from_jstorage("int", [sexp.length()], sexp.toIntArrayUnsafe())
      if (res != nil)
        res.set_sexp(sexp)
        # set return vector as immutable, as Renjin assumes it.
        res.immutable
      end
    elsif (sexp.instance_of? Java::OrgRenjinSexp::StringArrayVector)
      res = MDArray.from_jstorage("string", [sexp.length()], sexp.values)
      if (res != nil)
        res.set_sexp(sexp)
        # set return vector as immutable, as Renjin assumes it.
        res.immutable
      end
    else
      p "sexp type needs to be specialized"
      p sexp
      res = RubySexp.new(sexp)
    end

    return res

  end

end

require_relative 'sequence'
require_relative 'list_vector'

