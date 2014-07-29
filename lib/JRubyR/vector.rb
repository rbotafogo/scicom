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

class MDArray
  include_package "org.renjin"
  include_package "java.lang"

  attr_reader :sexp   # R structure with the same backing store as this MDArray
  attr_reader :rvar

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def set_sexp(sexp)
    @sexp = sexp
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def r

    if (@rvar == nil)
      @rvar = "sc_#{SecureRandom.hex(8)}"
      R.assign(@rvar, self)
    end
    @rvar

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def type_name
    @sexp.getTypeName()
  end


  #----------------------------------------------------------------------------------------
  # * @param index  zero-based index
  # * @return the element at {@code index} as a {@link Logical} value
  # Needs to be fixed!
  #----------------------------------------------------------------------------------------

  def get_element_as_logical(index = 0)

    log = @sexp.getElementAsLogical(index)
    case log.toString()
    when "FALSE"
      false
    when "TRUE"
      true
    else
      R.Double_NA
    end

  end

  #----------------------------------------------------------------------------------------
  # * @param index zero-based index
  # * @return true if the element at {@code index} is true.
  #----------------------------------------------------------------------------------------

  def element_true?(index = 0)
    begin
      @sexp.isElementTrue(index);
    rescue Java::JavaLang::ArrayIndexOutOfBoundsException
      raise IndexError
    end
  end

  #=======================================================================================
  #
  #=======================================================================================

  # private

  #----------------------------------------------------------------------------------------
  # * @return true if this MDArray already points to a sexp in R environment
  #----------------------------------------------------------------------------------------

  def sexp?
    sexp != nil
  end

end

=begin

/**
 * Provides a common interface to {@code ListExp}, all {@code AtomicExp}s, and
 * {@code PairList}s
 */
public interface Vector extends SEXP {
  
    
  /**
  *
  * @param vector an {@code AtomicVector}
  * @param vectorIndex an index of {@code vector}
  * @param startIndex
  * @return the index of the first element in this vector that equals
  * the element at {@code vectorIndex} in {@code vector}, or -1 if no such element
  * can be found
  */
 int indexOf(Vector vector, int vectorIndex, int startIndex);
  

 /**
  * @param vector an {@code AtomicVector }
  * @param vectorIndex an index of {@code vector}
  * @return true if this vector contains an element equal to the
  * the element at {@code vectorIndex} in {@code vector}
  */
  boolean contains(Vector vector, int vectorIndex);
 
  /**
   *
   * @param index zero-based index
   * @return  the element at {@code index} as a {@link Complex} value
   */
  Complex getElementAsComplex(int index);

  Type getVectorType();

  /**
   *
   * @param index zero-based index
   * @return  true if the element at {@code index} is NA (statistically missing)
   */
  boolean isElementNA(int index);


  /**
   * @return true if elements of this vector can be accessed in time constant
   * with regard to the length of the vector
   */
  boolean isConstantAccessTime();

  /**
   * Returns the element at index {@code index} of the vector as a native
   * JVM object, depending on the underlying R type:
   *
   * <ul>
   * <li>logical: java.lang.Boolean</li>
   * <li>integer: java.lang.Integer</li>
   * <li>double: java.lang.Double</li>
   * <li>complex: org.apache.commons.math.complex.Complex</li>
   * <li>character: java.lang.String</li>
   * </ul>
   *
   * @param index
   * @return
   * @throws IllegalArgumentException if the index is out of bounds or
   * the element at {@code index} is NA.
   */
  Object getElementAsObject(int index);

  int getComputationDepth();


    /**
     * Creates a new {@code Vector} of this {@code Type} from the element at
     * {@code index} in vector.
     * @param vector
     * @param index
     * @return
     */
    public abstract Vector getElementAsVector(Vector vector, int index);

    /**
     * Compares the two elements, coercing types to this {@code Type}.
     * @param vector1
     * @param index1
     * @param vector2
     * @param index2
     * @throws IllegalArgumentException if either of the two elements is NA or NaN
     * @return
     */
    public abstract int compareElements(Vector vector1, int index1, Vector vector2, int index2);

    
    /**
     * Checks equality between the two elements, coercing types to this {@code Type}. If either
     * of the two elements is NA, it will return false.
     * @param vector1
     * @param index1
     * @param vector2
     * @param index2
     * @return
     */    
    public abstract boolean elementsEqual(Vector vector1, int index1, Vector vector2, int index2);

    public static Type widest(Type a, Type b) {
      if(b.isWiderThan(a)) {
        return b;
      } else {
        return a;
      }
    }

    public static Type widest(Type a, Vector b) {
      return widest(a, b.getVectorType());
    }

    public static Type widest(Vector vector, SEXP element) {
      return widest(vector.getVectorType(), forElement(element));
    }
  }

}


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
