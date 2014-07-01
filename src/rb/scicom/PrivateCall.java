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

class PrivateCall {

    public static Object factoryInvoke(Class klass, String arrayType, Index index, 
				       Object storage) {

        Method method;
        Object requiredObj = null;
	Class typeClass = null;
	Class indexClass = null;
	Class objectClass = null;
	Class arrayClass = null;
	String base = "java.lang.";

	try {
	    typeClass = Class.forName("java.lang.Class");
	    indexClass = Class.forName("ucar.ma2.Index");
	    objectClass = Class.forName("java.lang.Object");
	    arrayClass = Class.forName(base + arrayType);
	} catch (ClassNotFoundException e) {
	    e.printStackTrace();
	}

        try {
            method = klass.getDeclaredMethod("factory", typeClass, indexClass, objectClass);
            method.setAccessible(true);
            requiredObj = method.invoke(klass, arrayClass, index, (double[]) storage);
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
	    System.out.println("InvocationTargetException: " + e.getTargetException().getMessage());  
            e.printStackTrace();
        }
        return requiredObj;
    }


}