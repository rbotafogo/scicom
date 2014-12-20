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
import org.renjin.sexp.*;
import ucar.ma2.*;

// Needed only for testing
import java.util.Arrays;

public class MDDoubleVector extends DoubleVector {

    // _array is a NetCDF Array in row-major format
    protected ArrayDouble _array;
    // index for the array
    protected Index _index;
    // shape of the array
    protected int[] _shape;
    // Used to convert a row-major index onto a colum-major index which is the standard
    // for R and Renjin
    protected int[] _jump;
    // number of dimensions for this vector
    protected int _length;
    
    /*-------------------------------------------------------------------------------------
     * 
     *-----------------------------------------------------------------------------------*/

    public static MDDoubleVector factory(ArrayDouble array, AttributeMap attributes) {

	MDDoubleVector vec = null;

	switch (array.getRank()) {
	case 1:
	    vec = new MDDoubleVectorD1(array, attributes);
	    break;
	case 2:
	    vec = new MDDoubleVectorD2(array, attributes);
	    break;
	case 3:
	    vec = new MDDoubleVectorD3(array, attributes);
	    break;
	case 4:
	    vec = new MDDoubleVectorD4(array, attributes);
	    break;
	case 5:
	    vec = new MDDoubleVectorD5(array, attributes);
	    break;
	case 6:
	    vec = new MDDoubleVectorD6(array, attributes);
	    break;
	case 7:
	    vec = new MDDoubleVectorD7(array, attributes);
	    break;
	default:
	    vec = new MDDoubleVector(array, attributes);
	    break;
	}

	return vec;

    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    protected MDDoubleVector(AttributeMap attributes) {
	super(attributes);
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    public MDDoubleVector(ArrayDouble array, AttributeMap attributes) {
	super(attributes);
	_array = array;
	_index = _array.getIndex();
	_shape = _array.getShape();
	_length = _shape.length;
	_jump = new int[_length - 2];

	_jump[_length - 3] = _shape[_length - 2] * _shape[_length - 1];
	
	for (int i = _length - 4; i >= 0; i--) {
	    int j = i + 1;
	    _jump[i] = _jump[j] * _shape[j];
	}

    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    public ArrayDouble getArray() {
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
    public double getElementAsDouble(int val) {
	setCurrentCounter(val);
	// return _index.currentElement();
	return _array.getDouble(_index);
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    @Override
    protected SEXP cloneWithNewAttributes(AttributeMap attributes) {
	// MDDoubleVector clone = new MDDoubleVector(attributes);
	// int[] dims = attributes.getDimArray();
	// clone._array = ucar.ma2.ArrayDouble(dims, _array.);
	MDDoubleVector clone = 
	    MDDoubleVector.factory((ArrayDouble) _array.copy(), attributes);
	return clone;
    }
    
    /*-------------------------------------------------------------------------------------
     * Given an element in the array in colum-major order finds the coresponding counter in 
     * row-major order.  Assumes that currElement is a valid element of the Vector.
     *-----------------------------------------------------------------------------------*/

    public void setCurrentCounter(int currElement) {

	int [] current = new int[_length];
	int l2 = _length - 2;
	
	for (int i = 0; i < l2; i++) { 
	    current[i] = currElement / _jump[i];
	    currElement -= current[i] * _jump[i];
	}

	for(int i = l2; i < _length; ++i) {
	    current[i] = currElement % _shape[i];
	    currElement = (currElement - current[i]) / _shape[i];
	}
	
	// java.lang.System.out.println("current: " + Arrays.toString(current));
	_index.set(current); // transfer to subclass fields
    }
    
}

