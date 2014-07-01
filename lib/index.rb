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

require 'java'

class Java::UcarMa2::Index
  field_accessor :stride
end

class MDArray

  #------------------------------------------------------------------------------------
  # Builds a new MDArray
  # @param type the type of the new mdarray to build, could be boolean, byte, short,
  #  int, long, float, double, string, structure
  # @param shape [Array] the shape of the mdarray as a ruby array
  # @param storage [Array] a ruby array with the initialization data
  #------------------------------------------------------------------------------------

  def self.build(type, shape, storage = nil, layout = :row)

    if (shape.is_a? String)
      # building from csv
      # using shape as filename
      # using storage as flag for headers
      storage = (storage)? storage : false
      parameters = Csv.read_numeric(shape, storage)
      shape=[parameters[0], parameters[1]]
      storage = parameters[2]
    end

    if (storage)
      # nc_array = Java::UcarMa2.Array.factory(dtype, jshape, jstorage)
      nc_array = make_nc_array(type, shape, storage, layout)
    else
      nc_array = Java::UcarMa2.Array.factory(dtype, jshape)
    end

    p type
    p nc_array

    klass = Object.const_get("#{type.capitalize}MDArray")
    return klass.new(type, nc_array)

  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def self.make_nc_array(type, shape, storage, layout)

    dtype = DataType.valueOf(type.upcase)
    jshape = shape.to_java :int
    jstorage = storage.to_java type.downcase.to_sym
    
    case layout
    when :row
      nc_array = Java::UcarMa2.Array.factory(dtype, jshape, jstorage)
    else
      jclass = Java::UcarMa2::Array.java_class
      nc_array = Java::RbScicom::PrivateCall
        .factoryInvoke(jclass, type.capitalize, index_factory(shape, layout), jstorage)
    end

  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  def self.from_jstorage(type, shape, jstorage, section = false, layout = :row)

    if (shape.size == 1 && shape[0] == 0)
      return nil
    end

    dtype = DataType.valueOf(type.upcase)
    jshape = shape.to_java :int

    case layout
    when :row
      nc_array = Java::UcarMa2.Array.factory(dtype, jshape, jstorage)
      klass = Object.const_get("#{type.capitalize}MDArray")
      return klass.new(type, nc_array, section)
    else
      jclass = Java::UcarMa2::Array.java_class
      jstorage = storage.to_java(type)
      nc_array = Java::RbScicom::PrivateCall
        .factoryInvoke(jclass, "Double", index_factory(shape, layout), jstorage)
      MDArray.build_from_nc_array(type, arr.array)
    end

  end

  #------------------------------------------------------------------------------------
  #
  #------------------------------------------------------------------------------------

  private

  #------------------------------------------------------------------------------------
  # Computes the stride for the given shape and layout.  Layout can be either :column
  # or :r.
  #------------------------------------------------------------------------------------

  def self.comp_stride(shape, layout)

    product = 1;
    stride = Array.new
    (0...shape.length).each do |i|
      this_dim = shape[i]
      if (this_dim < 0)
        raise "negative array size"
      end
      stride[i] = product
      product *= this_dim
    end
    stride
  end

  #------------------------------------------------------------------------------------
  # Creates new index with the given shape and layout
  #------------------------------------------------------------------------------------

  def self.index_factory(shape, layout)
    index = Java::UcarMa2.Index.factory(shape.to_java(:int))
    index.stride = comp_stride(shape, layout).to_java(:int)
    index
  end

end


=begin

    # jclass is a java class
    jclass = Java::UcarMa2::Array.java_class
    # p jclass.private_methods
    # p jclass.methods
    # p jclass.declared_method_smart(:factory)

    new = Java::UcarMa2::ArrayDouble.java_class
    
    # p jclass.declared_class_methods
    # method = jclass.declared_class_methods[2]
    # p method.inspect

    method = jclass.declared_class_methods.each do |method|
      p method if method.name == "factory" && method.arity == 3
    end

    p method
    method.accessible = true
    arr = method.invoke(self, new, index, jstorage.to_java)
    p arr
    p arr[0, 0, 0, 0, 0, 0, 0, 0, 0]

    # p jclass.methods
    # p jclass.java_class_methods

    # jclass.declared_method (Java::UcarMa2::Array.factory, [java.lang.Class, Java::UcarMa2.Index])
    # java_class = Java::UcarMa2.Array
    # p java_class
    # p java_class.methods
    # p java_class.java_class_methods
    # const = Java::UcarMa2::ArrayDouble.java_method :factory, [Java::UcarMa2.Index]
    # const = Java::UcarMa2::Array.java_method :factory, [java.lang.Class, Java::int[]]
      # p const
    # constructor = java_class.declared_method (Java::UcarMa2.Array.factory)
  end

    # java_class = Java::JavaClass.for_name("ucar.ma2.Array")
    # java_class.getCanonicalName()

    # get a bound Method based on the add(int, Object) method from ArrayList
    # add = list.java_method :add, [Java::int, java.lang.Object]
    # add.call(0, 'foo')
=end
