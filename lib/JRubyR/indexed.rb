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

require_relative "attributes"

#==========================================================================================
# Module Index, should be required by classes that can be accessed by an index, such as
# list and vector
#==========================================================================================

class Renjin

  module Index
    
    #----------------------------------------------------------------------------------------
    # Access an element of the class by indexing
    #----------------------------------------------------------------------------------------
    
    def [](*index)
      index = parse(index)
      R.eval("#{r}[#{index}]")
    end
        
    #----------------------------------------------------------------------------------------
    # Assign a value to a given index
    #----------------------------------------------------------------------------------------
    
    def []=(*index, value)
      index = parse(index)
      value = R.parse(value)
      R.eval("#{r}[#{index}] = #{value}")
    end

    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------

    def parse(index)

      params = Array.new

      index.each do |i|
        if (i.is_a? Array)
          params << i
        else
          params << R.parse(i)
        end
      end
      
      ps = String.new
      params.each_with_index do |p, i|
        ps << "," if i > 0
        ps << ((p == "NULL")? "" : p.to_s)
      end

      ps

    end

    #----------------------------------------------------------------------------------------
    # Module Index is included in list and vector. We allow access to list/vector elements
    # by name.  Two underscores are replaced with a '.' in order to be able to call methods
    # in R that have a '.' such as is.na, becomes R.is__na. 
    #----------------------------------------------------------------------------------------

    def method_missing(symbol, *args)

      name = symbol.id2name
      name.gsub!(/__/,".")
      
      if name =~ /(.*)=$/
        # p "#{r}$#{$1} = #{args[0].r}"
        # ret = R.eval("#{r}[\"#{name}\"] = #{args[0].r}")
        ret = R.eval("#{r}$#{$1} = #{args[0].r}")
      elsif (args.length == 0)
        # treat name as a named item of the list
        if (R.eval("\"#{name}\" %in% names(#{r})").gt)
          ret = R.eval("#{r}[[\"#{name}\"]]")
        else
          ret = R.eval("#{name}(#{r})") if ret == nil 
        end
      elsif (args.length > 0)
        # p "#{name}(#{r}, #{R.parse(*args)})"
        ret = R.eval("#{name}(#{r}, #{R.parse(*args)})")
      else
        raise "Illegal argument for named list item #{name}"
      end
      
      ret
      
    end

    #----------------------------------------------------------------------------------------
    # We use the following notation to access binary R functions such as %in%:
    # R.vec_ "in", list.
    #----------------------------------------------------------------------------------------

    def _(*args)
      method = "%#{args.shift.to_s}%"
      arg2 = R.parse(*args)
      ret = R.eval("#{r} #{method} #{arg2}")
    end
    
    #----------------------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------------------
    
    def each(&block)
      while (@iterator.hasNext())
        block.call(@iterator.next())
      end
    end

  end

end

require_relative 'vector'
require_relative 'list'
