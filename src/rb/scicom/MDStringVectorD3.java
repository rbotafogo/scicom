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

public class MDStringVectorD3 extends MDStringVector {

    private int _stride0;
    private int _shape1;
    private int _shape2;

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    private MDStringVectorD3(AttributeMap attributes) {
	super(attributes);
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/
    
    public MDStringVectorD3(ArrayString array, AttributeMap attributes) {

	super(attributes);
	_array = array;
	_index = _array.getIndex();

	try {
	    Field[] fields = _index.getClass().getDeclaredFields();
	    Field f = _index.getClass().getDeclaredField("stride0"); //NoSuchFieldException
	    f.setAccessible(true);
	    _stride0 = (int) f.get(_index); //IllegalAccessException
	    f = _index.getClass().getDeclaredField("shape1"); //NoSuchFieldException
	    f.setAccessible(true);
	    _shape1 = (int) f.get(_index);
	    f = _index.getClass().getDeclaredField("shape2"); //NoSuchFieldException
	    f.setAccessible(true);
	    _shape2 = (int) f.get(_index);
	} catch (NoSuchFieldException e) {
	    java.lang.System.out.println("Unknown field stride in MDStringVector");
	} catch (IllegalAccessException e) {
	    java.lang.System.out.println("Illegal access to stride in MDStringVector");
	}

    }

    /*-------------------------------------------------------------------------------------
     * Given an element in the array in colum-major order finds the coresponding counter in 
     * row-major order.  Assumes that currElement is a valid element of the Vector.
     *-----------------------------------------------------------------------------------*/

    public void setCurrentCounter(int currElement) {
	
	int[] shape = _array.getShape();
	int current0;
	int current1;
	int current2;

	current0 = currElement / _stride0;
	currElement -= current0 * _stride0;

	current1 = currElement % _shape1;
	currElement = (currElement - current1) / _shape1;

	current2 = currElement % _shape2;
	currElement = (currElement - current2) / _shape2;

	_index.set(current0, current1, current2); // transfer to subclass fields
    }
    
}

