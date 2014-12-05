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
import ucar.ma2.*;
import org.renjin.sexp.*;


public class MDStringVectorD4 extends MDStringVector {

    private int _stride0, _stride1;
    private int _shape1, _shape2, _shape3;

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    private MDStringVectorD4(AttributeMap attributes) {
	super(attributes);
    }

    /*-------------------------------------------------------------------------------------
     *
     *-----------------------------------------------------------------------------------*/

    public MDStringVectorD4(ArrayString array, AttributeMap attributes) {

	super(attributes);
	_array = array;
	_index = _array.getIndex();

	try {
	    Field[] fields = _index.getClass().getDeclaredFields();
	    // stride0
	    Field f = _index.getClass().getDeclaredField("stride0"); //NoSuchFieldException
	    f.setAccessible(true);
	    _stride0 = (int) f.get(_index); //IllegalAccessException
	    // stride1
	    f = _index.getClass().getDeclaredField("stride1"); //NoSuchFieldException
	    f.setAccessible(true);
	    _stride1 = (int) f.get(_index); //IllegalAccessException
	    // shape3
	    f = _index.getClass().getDeclaredField("shape3"); //NoSuchFieldException
	    f.setAccessible(true);
	    _shape3 = (int) f.get(_index);
	    // shape2
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

	int current0, current1, current2, current3;

	// Initial dimensions, i.e., all but the last two
	current0 = currElement / _stride0;
	currElement -= current0 * _stride0;

	current1 = currElement / _stride1;
	currElement -= current1 * _stride1;

	// Last two dimensions
	current2 = currElement % _shape2;
	currElement = (currElement - current2) / _shape2;

	current3 = currElement % _shape3;
	currElement = (currElement - current3) / _shape3;

	_index.set(current0, current1, current2, current3); // transfer to subclass fields
    }
    
}
