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

public class MDLogicalVectorD3 extends MDLogicalVector {

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    private MDLogicalVectorD3(AttributeMap attributes) {
	super(attributes);
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    public MDLogicalVectorD3(ArrayByte array, AttributeMap attributes) {
	super(attributes);
	_array = array;
	_index = _array.getIndex();
    }

    /*-------------------------------------------------------------------------------------
     * Given an element in the array in colum-major order finds the coresponding counter in 
     * row-major order.  Assumes that currElement is a valid element of the Vector.
     *-----------------------------------------------------------------------------------*/

    public void setCurrentCounter(int currElement) {
	
	int[] shape = _array.getShape();
	int current0;
	int current1;

	current0 = currElement % shape[0];
	currElement = (currElement - current0) / shape[0];

	current1 = currElement % shape[1];
	currElement = (currElement - current1) / shape[1];

	_index.set(current0, current1); // transfer to subclass fields

    }
    
}

