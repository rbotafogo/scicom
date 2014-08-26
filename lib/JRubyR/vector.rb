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

class Vector < RubySexp
  include Enumerable

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(sexp)
    super(sexp)
    @iterator = @sexp.iterator()
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def get(index)
    @sexp.getElementAsObject(index)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def [](index)
    # This is inefficient.  Should be changed!
    raise "0 length vector" if (@sexp.length == 0)
    get(index)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def z
    self[0]
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def each(&block)
    while (@iterator.hasNext())
      block.call(RubySexp.build(@iterator.next()))
    end
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def length
    R.length(r)
  end

end


###########################################################################################
#
###########################################################################################

class MDArray
  include RBSexp

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


=begin

###########################################################################################
#
###########################################################################################

class DoubleVector < Vector

  #=======================================================================================
  # * @param index zero-based index
  # * @return the element at {@code index} as a double value, converting if necessary. 
  #=======================================================================================

  def get(index = 0)
    @vector.getElementAsDouble(index)
  end

end

###########################################################################################
#
###########################################################################################

class IntVector < Vector

  #=======================================================================================
  # * @param index zero-based index
  # * @return the element at {@code index} as an int value, converting if necessary. 
  #=======================================================================================

  def get(index = 0)
    @vector.getElementAsInt(index)
  end

end

###########################################################################################
#
###########################################################################################

class StringVector < Vector

  #=======================================================================================
  # * @param index zero-based index
  # * @return the element at {@code index} as a string value, converting if necessary. 
  #=======================================================================================

  def get(index = 0)
    @vector.getElementAsString(index)
  end

end
=end
