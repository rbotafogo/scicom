/******************************************************************************************
* @author Rodrigo Botafogo
*
* Copyright © 2013 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
* and distribute this software and its documentation, without fee and without a signed 
* licensing agreement, is hereby granted, provided that the above copyright notice, this 
* paragraph and the following two paragraphs appear in all copies, modifications, and 
* distributions.
*
* IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
* INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
* THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
* POSSIBILITY OF SUCH DAMAGE.
*
* RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
* SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
* RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, 
* OR MODIFICATIONS.
******************************************************************************************/

package rb.scicom;

import java.lang.reflect.*;
import java.util.*;
import org.renjin.sexp.*;
import org.renjin.primitives.*;
import ucar.ma2.*;

public class MDLogicalVector extends LogicalVector {

    // array is a NetCDF Array in row-major format
    protected ArrayByte _array;
    // index is a column-major index on top of the same backing store
    protected Index _index;
    // Stride in reverse order for column-major mode.  Necessary as stride is protected
    // in NetCDF Array.
    protected int[] _stride;
    
    /*-------------------------------------------------------------------------------------
     * 
     *-----------------------------------------------------------------------------------*/

    public static MDLogicalVector factory(ArrayByte array, AttributeMap attributes) {

	MDLogicalVector vec = null;

	switch (array.getRank()) {
	case 1:
	    vec = new MDLogicalVectorD1(array, attributes);
	    break;
	case 2:
	    vec = new MDLogicalVectorD2(array, attributes);
	    break;
	case 3:
	    vec = new MDLogicalVectorD3(array, attributes);
	    break;
	case 4:
	    vec = new MDLogicalVectorD4(array, attributes);
	    break;
	case 5:

	    break;

	case 6:
	    break;

	case 7:

	    break;

	default:
	    break;
	}

	return vec;

    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    protected MDLogicalVector(AttributeMap attributes) {
	super(attributes);
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    public MDLogicalVector(ArrayByte array, AttributeMap attributes) {
	super(attributes);
	_array = array;
	_index = _array.getIndex();

	try {
	    Field[] fields = _index.getClass().getDeclaredFields();
	    for ( int i = 0; i < fields.length; i++ )  {  
		java.lang.System.out.println(fields[i].getName());  
	    }  
	    Field f = _index.getClass().getDeclaredField("stride"); //NoSuchFieldException
	    f.setAccessible(true);
	    _stride = (int[]) f.get(_index); //IllegalAccessException
	} catch (NoSuchFieldException e) {
	    java.lang.System.out.println("Unknown field stride in MDLogicalVector");
	} catch (IllegalAccessException e) {
	    java.lang.System.out.println("Illegal access to stride in MDLogicalVector");
	}

	java.lang.System.out.println(_index.toString());
	java.lang.System.out.println(_stride);
	// _stride = _index.stride;
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    public ArrayByte getArray() {
	return _array;
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    public Index getIndex() {
	return _index;
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    public int[] getRevStride() {
	return _stride;
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    @Override
    public int length() {
	return (int) _array.getSize();
    }
    
    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    @Override
    public boolean isConstantAccessTime() {
	return true;
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    @Override
    public int getElementAsRawLogical(int val) {
	setCurrentCounter(val);
	// return _index.currentElement();
	return _array.getInt(_index);
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    @Override
    protected SEXP cloneWithNewAttributes(AttributeMap attributes) {
	// MDLogicalVector clone = new MDLogicalVector(attributes);
	// int[] dims = attributes.getDimArray();
	// clone._array = ucar.ma2.ArrayDouble(dims, _array.);
	MDLogicalVector clone = 
	    MDLogicalVector.factory((ArrayByte)_array.copy(), attributes);
	return clone;
    }
    
    /*-------------------------------------------------------------------------------------
     * Given an element in the array in colum-major order finds the coresponding counter in 
     * row-major order.  Assumes that currElement is a valid element of the Vector.
     *-----------------------------------------------------------------------------------*/

    public void setCurrentCounter(int currElement) {
	int length = _stride.length;
	int[] shape = _array.getShape();
	int [] current = new int[length];
	int l2 = (length - 2) >= 0 ? (length - 2) : 1;
	
	if (length == 1) {
	    current[0] = currElement * _stride[0];
	    _index.set(current);
	    return;
	}
	
	if (length > 2) { 
	    for (int i = 0; i < l2; i++) { 
		current[i] = currElement / _stride[i];
		currElement -= current[i] * _stride[i];
	    }
	}
	for(int i = l2; i < length; ++i) {
	    current[i] = currElement % shape[i];
	    currElement = (currElement - current[i]) / shape[i];
	}
	
	// java.lang.System.out.println("current: " + Arrays.toString(current));
	_index.set(current); // transfer to subclass fields
    }
    
}

