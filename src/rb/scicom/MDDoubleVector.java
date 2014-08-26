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

import java.util.*;
import org.renjin.sexp.*;
import org.renjin.primitives.*;
import ucar.ma2.*;


public class MDDoubleVector extends DoubleVector {

    // array is a NetCDF Array in row-major format
    private ArrayDouble _array;
    // index is a column-major index on top of the same backing store
    private Index _index;
    // Stride in reverse order for column-major mode.  Necessary as stride is protected
    // in NetCDF Array.
    private int[] _stride;
    

    private MDDoubleVector(AttributeMap attributes) {
	super(attributes);
    }

    public ArrayDouble getArray() {
	return _array;
    }

    public Index getIndex() {
	return _index;
    }

    public int[] getRevStride() {
	return _stride;
    }

    public MDDoubleVector(ArrayDouble array, AttributeMap attributes, Index index, 
			  int[] stride) {
	super(attributes);
	_array = array;
	_index = index;
	_stride = stride;
    }
    
    @Override
	public double getElementAsDouble(int val) {
	setCurrentCounter(val);
	return _index.currentElement();
    }

    @Override
	public int length() {
	return (int) _array.getSize();
    }
    
    @Override
	protected SEXP cloneWithNewAttributes(AttributeMap attributes) {
	MDDoubleVector clone = new MDDoubleVector(attributes);
	clone._array = _array;
	return clone;
    }
    
    @Override
	public boolean isConstantAccessTime() {
	return true;
    }

    /*
     * Given an element finds the coresponding counter in column-major order.  Assumes that
     * currElement is a valid element of the Vector.
     */

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

