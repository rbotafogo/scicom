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


import org.renjin.sexp.*;
import org.renjin.primitives.*;
import ucar.ma2.*;


public class MDDoubleVector extends DoubleVector {
    
    private ArrayDouble array;
    private Index index;
    

    private MDDoubleVector(AttributeMap attributes) {
	super(attributes);
    }


    public ArrayDouble getArray() {
	return array;
    }

    public MDDoubleVector(ArrayDouble array) {
	super(AttributeMap.EMPTY);
	this.array = array;
	this.index = array.getIndex();
    }

    public MDDoubleVector(ArrayDouble array, AttributeMap attributes) {
	super(attributes);
	this.array = array;
	this.index = array.getIndex();
    }
    
    @Override
	public double getElementAsDouble(int val) {
	int dim[] = getAttributes().getDimArray();
	int index[] = Indexes.vectorIndexToArrayIndex(val, dim);

	// int offset = dim.getElementAsInt(0);
	// int row = val % offset;
	// int col = val / offset;
	return this.array.getDouble(this.index.set(index));
    }
  
    @Override
	public int length() {
	return (int) array.getSize();
    }
    
    @Override
	protected SEXP cloneWithNewAttributes(AttributeMap attributes) {
	MDDoubleVector clone = new MDDoubleVector(attributes);
	clone.array = array;
	return clone;
    }
    
    @Override
	public boolean isConstantAccessTime() {
	return true;
    }

}

