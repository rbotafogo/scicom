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

import ucar.ma2.*;
import org.renjin.sexp.*;


public class MDDoubleVectorD5 extends MDDoubleVector {

    private int _jump0, _jump1, _jump2;
    private int _shape1, _shape2, _shape3, _shape4;

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    private MDDoubleVectorD5(AttributeMap attributes) {
	super(attributes);
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    public MDDoubleVectorD5(ArrayDouble array, AttributeMap attributes) {

	super(attributes);
	_array = array;
	_index = _array.getIndex();
	_shape1 = array.getShape()[1];
	_shape2 = array.getShape()[2];
	_shape3 = array.getShape()[3];
	_shape4 = array.getShape()[4];
	_jump2 = _shape3 * _shape4;
	_jump1 = _jump2 * _shape2;
	_jump0 = _jump1 * _shape1;

    }

    /*-------------------------------------------------------------------------------------
     * Given an element in the array in colum-major order finds the coresponding counter in 
     * row-major order.  Assumes that currElement is a valid element of the Vector.
     *-----------------------------------------------------------------------------------*/

    public void setCurrentCounter(int currElement) {

	int current0, current1, current2, current3, current4;

	// Initial dimensions, i.e., all but the last two
	current0 = currElement / _jump0;
	currElement -= current0 * _jump0;

	current1 = currElement / _jump1;
	currElement -= current1 * _jump1;

	current2 = currElement / _jump2;
	currElement -= current2 * _jump2;

	// Last two dimensions
	current3 = currElement % _shape3;
	currElement = (currElement - current3) / _shape3;

	current4 = currElement % _shape4;
	currElement = (currElement - current4) / _shape4;

	_index.set(current0, current1, current2, current3, current4);
    }
    
}
