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


###########################################################################################
#
###########################################################################################

class MDArray
  include RBSexp
  include RVector

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def z
    self[0]
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def pp
    print
  end

end

###########################################################################################
#
###########################################################################################

class Renjin

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------
  
  def self.build(sexp)
    
    if (sexp.instance_of? Java::OrgRenjinPrimitivesSequence::IntSequence)
      res = Renjin::IntSequence.new(sexp)
    elsif (sexp.instance_of? Java::OrgRenjinSexp::Null)
      res = nil
    elsif (sexp.instance_of? Java::OrgRenjinSexp::ListVector)
      res = Renjin::List.new(sexp)
    elsif (sexp.instance_of? Java::OrgRenjinSexp::LogicalArrayVector)
      res = Renjin::Logical.new(sexp)
    elsif (sexp.instance_of? Java::OrgRenjinSexp::Environment)
      res = Renjin::Environment.new(sexp)
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
      res = Renjin::RubySexp.new(sexp)
    end
    
    return res
    
  end
  
end
