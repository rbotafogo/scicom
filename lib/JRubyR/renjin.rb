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
require 'securerandom'

require_relative 'rbsexp'
require_relative 'package'
# require_relative 'index'


#==========================================================================================
#
#==========================================================================================

class Java::RbScicom::MDDoubleVector
  field_reader :_array
end


#==========================================================================================
#
#==========================================================================================

class Renjin
  include_package "javax.script"
  include_package "org.renjin"

  @stack = Array.new

  class << self
    attr_accessor :stack
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  attr_reader :engine

  # Parse error
  ParseError=Class.new(Exception)

  #----------------------------------------------------------------------------------------
  # R is invoked within a Ruby script (or the interactive "irb" prompt denoted >>) using:
  #
  #      >> require "scicom"
  #
  # The previous statement reads the definition of the RinRuby class into the current Ruby 
  # interpreter and creates an instance of the RinRuby class named R. There is a second 
  # method for starting an instance of R which allows the user to use any name for the 
  # instance, in this case myr:
  #
  #      >> require "scicom"
  #      >> myr = RinRuby.new
  #      >> myr.eval "rnorm(1)"
  #
  # Any number of independent instances of R can be created in this way.
  #----------------------------------------------------------------------------------------

  def initialize

    @platform = 
      case RUBY_PLATFORM
      when /mswin/ then 'windows'
      when /mingw/ then 'windows'
      when /bccwin/ then 'windows'
      when /cygwin/ then 'windows-cygwin'
      when /java/
        require 'java' #:nodoc:
        if java.lang.System.getProperty("os.name") =~ /[Ww]indows/
          'windows-java'
        else
          'default-java'
        end
      else 'default'
      end

    factory = Java::JavaxScript.ScriptEngineManager.new()
    @engine = factory.getEngineByName("Renjin")
    super

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def nan?(x)
    is__nan(x)
  end

  #----------------------------------------------------------------------------------------
  # The integer constant used to designate elements or values that are
  # missing in the statistical sense, or literally "Not Available". 
  # For integers (Fixnum) this is represented as the minimum integer from Java 
  # Integer.MIN_VALUE
  #----------------------------------------------------------------------------------------

  def na?(x)
    R.is__na(x)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def finite?(x)
    R.is__finite(x)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def method_missing(symbol, *args)

    name = symbol.id2name
    name.gsub!(/__/,".")
    # Method 'rclass' is a substitute for R method 'class'.  Needed, as 'class' is also
    # a Ruby method on an object
    name.gsub!("rclass", "class")

    if name =~ /(.*)=$/
      super if args.length != 1
      ret = assign($1,args[0])
    else
      # super if args.length != 0
      if (args.length == 0)
        # is_var = false
        # Try to see if name is a variable or a method.
        ret = (eval("\"#{name}\" %in% ls()").gt)? eval("#{name}") : eval("#{name}()")
      else
        params = parse(*args)
        # p "#{name}(#{params})"
        ret = eval("#{name}(#{params})")
      end
    end

    ret

  end

  #----------------------------------------------------------------------------------------
  # R built-in constants
  #----------------------------------------------------------------------------------------

  def pi
    eval("pi")
  end

  def LETTERS
    eval("LETTERS")
  end

  def letters
    eval("letters")
  end

  def month__abb
    eval("month.abb")
  end

  def month__name
    eval("month.name")
  end

  def i(value)
    eval("#{value}L")
  end

  def d(value)
    eval("#{value}")
  end

  def md(value)
    Renjin::Vector.new(build_vector(value))
  end


  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def eval(expression)
    begin
      ret = Renjin::RubySexp.build(@engine.eval(expression))
    rescue Java::OrgRenjinEval::EvalException => e 
      p e.message
    rescue Java::OrgRenjinParser::ParseException => e
      p e.message
    ensure
      Renjin.stack.each do |sexp|
        sexp.destroy
      end
    end

    ret

  end

  #----------------------------------------------------------------------------------------
  # Evaluates an expression but does not wrap the return in a RubySexp.  Needed for 
  # intermediate evaluation done by internal methods.  In principle, should not be
  # called by users.
  #----------------------------------------------------------------------------------------

  def direct_eval(expression)
    begin
      ret = @engine.eval(expression)
    rescue Java::OrgRenjinEval::EvalException => e 
      p e.message
    ensure
=begin
      Renjin.stack.each do |sexp|
        sexp.destroy
      end
=end
    end

    ret

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def parse(*args)

    params = Array.new
    
    args.each do |arg|
      if (arg.is_a? Numeric)
        params << arg
      elsif(arg.is_a? String)
        params << "\"#{arg}\""
      elsif (arg.is_a? Symbol)
        var = eval("#{arg.to_s}")
        params << var.r
      elsif (arg.is_a? TrueClass)
        params << "TRUE"
      elsif (arg.is_a? FalseClass)
        params << "FALSE"
      elsif (arg == nil)
        params << "NULL"
      elsif (arg.is_a? NegRange)
        final_value = (arg.exclude_end?)? (arg.end - 1) : arg.end
        params << "-(#{arg.begin}:#{final_value})"
      elsif (arg.is_a? Range)
        final_value = (arg.exclude_end?)? (arg.end - 1) : arg.end
        params << "(#{arg.begin}:#{final_value})"
      elsif (arg.is_a? Hash)
        arg.each_pair do |key, value|
          params << "#{key.to_s} = #{parse(value)}"
        end
      elsif ((arg.is_a? Renjin::RubySexp) || (arg.is_a? Array) || (arg.is_a? MDArray))
        params << arg.r
      # elsif 
      #  params << arg.inspect
      else
        raise "Unknown parameter type for R: #{arg}"
      end
      
    end

    params.join(",")
      
  end

  #----------------------------------------------------------------------------------------
  # Data is copied from Ruby to R using the assign method or a short-hand equivalent. For 
  # example:
  #
  #      >> names = ["Lisa","Teasha","Aaron","Thomas"]
  #      >> R.assign "people", names
  #      >> R.eval "sort(people)"
  #
  #produces the following :
  #
  #      [1] "Aaron"     "Lisa"     "Teasha" "Thomas"
  #
  # The short-hand equivalent to the assign method is simply:
  #
  #      >> R.people = names
  #
  # Some care is needed when using the short-hand of the assign method since the label 
  # (i.e., people in this case) must be a valid method name in Ruby. For example, 
  # R.copy.of.names = names will not work, but R.copy_of_names = names is permissible.
  #
  # The assign method supports Ruby variables of type Fixnum (i.e., integer), Bignum 
  # (i.e., integer), Float (i.e., double), String, and arrays of one of those three 
  # fundamental types. Note that Fixnum or Bignum values that exceed the capacity of R's 
  # integers are silently converted to doubles.  Data in other formats must be coerced 
  # when copying to R.
  #
  # <b>Parameters that can be passed to the assign method:</b>
  #
  # * name: The name of the variable desired in R.
  # * value: The value the R variable should have.
  #
  # The assign method is an alternative to the simplified method, with some additional 
  # flexibility. When using the simplified method, the parameters of name and value are 
  # automatically used, in other words:
  #
  #      >> R.test = 144
  #
  # is the same as:
  #
  #      >> R.assign("test",144)
  #
  # Of course it would be confusing to use the shorthand notation to assign a variable 
  # named eval, echo, or any other already defined function. RinRuby would assume you were 
  # calling the function, rather than trying to assign a variable.
  #
  # When assigning an array containing differing types of variables, RinRuby will follow 
  # R’s conversion conventions. An array that contains any Strings will result in a 
  # character vector in R. If the array does not contain any Strings, but it does contain 
  # a Float or a large integer (in absolute value), then the result will be a numeric 
  # vector of Doubles in R. If there are only integers that are suffciently small (in 
  # absolute value), then the result will be a numeric vector of integers in R.
  #----------------------------------------------------------------------------------------

  def assign(name, value)

    original_value = value

    if ((value.is_a? MDArray) || (value.is_a? RubySexp))
      if (value.sexp != nil)
        # MDArray already represented in R
        value = value.sexp
      else
        value = build_vector(value)
      end
    elsif (value == nil)
      value = NULL
    end

    @engine.put(name, value)
    original_value
    
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def pull(name)
    eval(name)
  end
  
  #----------------------------------------------------------------------------------------
  # function is either a function name alone represented by a ruby symbol or a hash 
  # with the function name and its arguments or indexes
  # Ex: 
  #   fassign(sexp, :rowname, "x1")
  #   fassign(sexp, {f: :rowname, index: [[1]]}, "x1")
  #   fassign(sexp, {f: :somefunc, params: "(2, 3, 4)"}, "x1")
  #----------------------------------------------------------------------------------------

  def fassign(sexp, function, value)

    if (function.is_a? Hash)
      index = function[:index]
      params = function[:params]
      function = function[:f]
      if (index)
        eval("#{function.to_s}(#{sexp.r})#{index} = #{value.r}")
      else
      end
    else
      eval("#{function.to_s}(#{sexp.r}) = #{value.r}")
    end

    sexp

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def install__package(name)

    pm = PackageManager.new
    pm.load_package(name)

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def library(package)

    Dir.chdir(SciCom.cran_dir)
    filename = Dir.glob(package + '*')[0]
    path = SciCom.cran_dir + '/' + filename

    require filename
    eval("library(#{package})")

  end

  #----------------------------------------------------------------------------------------
  # Builds a Renjin vector from an MDArray. Should be private, but public for testing.
  #----------------------------------------------------------------------------------------

  # private

  #----------------------------------------------------------------------------------------
  # Builds a Renjin vector from an MDArray. Should be private, but public for testing.
  #----------------------------------------------------------------------------------------
  
  def build_vector(mdarray)
    
    shape = mdarray.shape
    # index = mdarray.nc_array.getIndex()
    # index = MDArray.index_factory(shape)
    # representation of shape in R is different from shape in MDArray.  Convert MDArray
    # shape to R shape.
    if (shape.size > 2)
      shape.reverse!
      shape[0], shape[1] = shape[1], shape[0]
    end

    # AttributeMap attributes = AttributeMap.builder().setDim(new IntVector(dim)).build();
    attributes = Java::OrgRenjinSexp::AttributeMap.builder()
      .setDim(Java::OrgRenjinSexp::IntArrayVector.new(*(shape))).build()

    # vector = Java::RbScicom::MDDoubleVector.new(mdarray.nc_array, attributes, index,
    #   index.stride)
    
    case mdarray.type
    when "int"
      vector = Java::RbScicom::MDIntVector.factory(mdarray.nc_array, attributes)
    when "double"
      vector = Java::RbScicom::MDDoubleVector.factory(mdarray.nc_array, attributes)
    when "byte"
      vector = Java::RbScicom::MDLogicalVector.factory(mdarray.nc_array, attributes)
    when "string"
      vector = Java::RbScicom::MDStringVector.factory(mdarray.nc_array, attributes)
    when "boolean"
      raise "Boolean vectors cannot be converted to R vectors.  If you are trying to \
convert to an R Logical object, use a :byte MDArray"
    else
      raise "Cannot convert MDArray #{mdarray.type} to R vector"
    end

  end


end

# Create a new R interpreter
R = Renjin.new
NA = R.eval("NA")
NaN = R.eval("NaN")
Inf = R.eval("Inf")
MInf = R.eval("-Inf")
NULL = R.direct_eval("NULL")
# EPSILON = R.eval("EPSILON")
# NA_integer = R.eval("NA_integer")
