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

class Environment < RubySexp


  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def method_missing(symbol, *args)

    stack = Array.new

    name = symbol.id2name
    if name =~ /(.*)=$/
      # should never reach this point.  Parse error... but check
      raise ArgumentError, "You shouldn't assign nil" if args==[nil]
      super if args.length != 1
      ret = R.assign($1,args[0])
    else
      name.gsub!(/__/,".")
      # super if args.length != 0
      if (args.length == 0)
        # treat the argument as a named item of the list
        ret = RubySexp.build(@sexp.getVariable(name))
      else
        params, stack = parse(*args)
        ret = eval("#{name}(#{params})")
      end
    end

    stack.each do |sexp|
      sexp.destroy
    end

    ret

  end

end

