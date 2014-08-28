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

class Renjin

  class List < Renjin::Vector

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def length
      @sexp.length()
    end
    
    #----------------------------------------------------------------------------------------
    # index can be a numeric index or a string index.
    #----------------------------------------------------------------------------------------
    
    def get(index)
      Renjin::RubySexp.build(@sexp.get(index))
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def [](index)
      get(index)
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def index_of_name(name)
      @sexp.indexOfName(name)
    end
    
    #----------------------------------------------------------------------------------------
    # index can be a numeric index or a string index.
    #----------------------------------------------------------------------------------------
    
    def get_element_as_double(index)
      @sexp.getElementAsDouble(index)
    end
    
    #----------------------------------------------------------------------------------------
    # index can be a numeric index or a string index.
    #----------------------------------------------------------------------------------------
    
    def get_element_as_int(index)
      @sexp.getElementAsInt(index)
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def get_element_as_list(name)
      Renjin::RubySexp.build(@sexp.getElementAsList(name))
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def get_element_as_vector(name)
      Renjin::RubySexp.build(@sexp.getElementAsVector(name))
    end
    
    #----------------------------------------------------------------------------------------
    # Treats ruby style methods in lists as named items on the list
    #----------------------------------------------------------------------------------------
    
    def method_missing(symbol, *args)
      
      name = symbol.id2name
      name.gsub!(/__/,".")
      # super if args.length != 0
      if (args.length == 0)
        # treat name as a named item of the list
        ret = R.eval("#{r}[\"#{name}\"]")[0]
      else
        raise "Illegal argument for named list item #{name}"
      end
      
      ret
      
    end
    
  end
  
end

