# -*- coding: utf-8 -*-

##########################################################################################
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

require 'rubygems'
require "test/unit"
require 'shoulda'

require 'env'
require 'scicom'

class SciComTest < Test::Unit::TestCase

  context "R environment" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end

    #--------------------------------------------------------------------------------------
    # Conceptually, factors are variables in R which take on a limited number of different 
    # values; such variables are often refered to as categorical variables. One of the 
    # most important uses of factors is in statistical modeling; since categorical 
    # variables enter into statistical models differently than continuous variables, 
    # storing data as factors insures that the modeling functions will treat such data 
    # correctly.
    #
    # Factors in R are stored as a vector of integer values with a corresponding set of 
    # character values to use when the factor is displayed. The factor function is used to 
    # create a factor. The only required argument to factor is a vector of values which 
    # will be returned as a vector of factor values. Both numeric and character variables 
    # can be made into factors, but a factor's levels will always be character values. 
    # You can see the possible levels for a factor through the levels command.
    #
    # To change the order in which the levels will be displayed from their default sorted 
    # order, the levels= argument can be given a vector of all the possible values of the 
    # variable in the order you desire. If the ordering should also be used when 
    # performing comparisons, use the optional ordered=TRUE argument. In this case, the 
    # factor is known as an ordered factor.
    #
    # The levels of a factor are used when displaying the factor's values. You can change 
    # these levels at the time you create a factor by passing a vector with the new values 
    # through the labels= argument. Note that this actually changes the internal levels of 
    # the factor, and to change the labels of a factor after it has been created, the 
    # assignment form of the levels function is used. To illustrate this point, consider a 
    # factor taking on integer values which we want to display as roman numerals.
    # (http://www.stat.berkeley.edu/~s133/factors.html)
    #--------------------------------------------------------------------------------------

    should "create factors" do

=begin
      # Open bug report with Renjin
      # R.substring("statistics", (1..10), (1..10)).pp
      split = R.strsplit("statistics", "")
      split.pp
      R.eval("print(strsplit(\"statistics\", split = \"\"))")

      ff = R.factor(split, labels: R.letters)
      # R.eval("print(factor(strsplit(\"statistics\", split = \"\"), levels = letters))")
      # ff.pp
=end


      data = R.c(1,2,2,3,1,2,3,3,1,2,3,3,1)

      # The same as above, but more like R, i.e. calling function 'factor' with data as
      # argument
      fdata = R.factor(data)
      fdata.pp

      # Calling "method" 'factor' on the data vector.  Same result as above, but shorter
      # without having to use 'R.factor'
      data.factor.pp

      # calling 'factor' method with arguments
      data.factor(labels: R.c("I","II","III")).pp

      # To convert the default factor fdata to roman numerals, we need to set its levels
      # attribute
      fdata.attr.levels = R.c('I','II','III')
      fdata.pp

      # Factors represent a very efficient way to store character values, because each 
      # unique character value is stored only once, and the data itself is stored as a 
      # vector of integers. Because of this, read.table will automatically convert 
      # character variables to factors unless the as.is= argument is specified. See 
      # Section  for details.
      #
      # As an example of an ordered factor, consider data consisting of the names of 
      # months:
      
      mons = R.c("March","April","January","November","January",\
        "September","October","September","November","August",\
        "January","November","November","February","May","August",\
        "July","December","August","August","September","November",\
        "February","April")
      # mons.pp
      mons = R.factor(mons)
      R.table(mons).pp

      # This does the same as above
      mons.factor.table.pp

      # Although the months clearly have an ordering, this is not reflected in the 
      # output of the table function. Additionally, comparison operators are not 
      # supported for unordered factors. Creating an ordered factor solves these 
      # problems:
      
      mons = R.factor(mons, levels: R.c("January","February","March",\
        "April","May","June","July","August","September",\
        "October","November","December"), ordered: TRUE)
      (mons[1] < mons[2]).pp
      mons.table.pp

      # While it may be necessary to convert a numeric variable to a factor for a 
      # particular application, it is often very useful to convert the factor back to 
      # its original numeric values, since even simple arithmetic operations will fail 
      # when using factors. Since the as.numeric function will simply return the 
      # internal integer values of the factor, the conversion must be done using the 
      # levels attribute of the factor.
      # 
      # Suppose we are studying the effects of several levels of a fertilizer on the 
      # growth of a plant. For some analyses, it might be useful to convert the 
      # fertilizer levels to an ordered factor:
      fert = R.c(10,20,20,50,10,20,10,50,20)
      fert = R.factor(fert, levels: R.c(10, 20, 50), ordered: TRUE)
      fert.pp

      # now calling factor with arguments
      fert.factor(levels: R.c(10, 20, 50), ordered: TRUE).pp

      # If we wished to calculate the mean of the original numeric values of the fert 
      # variable, we would have to convert the values using the levels function:

      # This prints NA
      R.mean(fert).pp

      # actually calculates the mean
      R.mean(R.as__numeric(R.levels(fert)[fert])).pp

      # the same, but more Ruby like
      fert.levels[fert].as__numeric.mean.pp

      # Indexing the return value from the levels function is the most reliable way 
      # to convert numeric factors to their original numeric values.
      #
      # When a factor is first created, all of its levels are stored along with the 
      # factor, and if subsets of the factor are extracted, they will retain all of the 
      # original levels. This can create problems when constructing model matrices and 
      # may or may not be useful when displaying the data using, say, the table function. 
      # As an example, consider a random sample from the letters vector, which is part 
      # of the base R distribution.

      lets = R.sample(R.letters, size: 100,replace: TRUE)
      lets = R.factor(lets)
      R.table(lets[(1..5)]).pp

      # Even though only five of the levels were actually represented, the table function 
      # shows the frequencies for all of the levels of the original factors. To change 
      # this, we can simply use another call to factor

      R.table(R.factor(lets[(1..5)])).pp

      # To exclude certain levels from appearing in a factor, the exclude= argument 
      # can be passed to factor. By default, the missing value (NA) is excluded from 
      # factor levels; to create a factor that inludes missing values from a numeric 
      # variable, use exclude=NULL.
      #
      # Care must be taken when combining variables which are factors, because the c 
      # function will interpret the factors as integers. To combine factors, they should 
      # first be converted back to their original values (through the levels function), 
      # then catenated and converted to a new factor:
      
      l1 = R.factor(R.sample(R.letters, size: 10, replace: TRUE))
      l2 = R.factor(R.sample(R.letters, size: 10, replace: TRUE))
      l1.pp
      l2.pp
      l12 = R.factor(R.c(R.levels(l1)[l1], R.levels(l2)[l2]))
      l12.pp

      # l12 in with chainning
      R.factor(R.c(l1.levels[l1], l2.levels[l2])).pp

      # The cut function is used to convert a numeric variable into a factor. The 
      # breaks argument to cut is used to describe how ranges of numbers will be 
      # converted to factor values. If a number is provided through the breaks argument, 
      # the resulting factor will be created by dividing the range of the variable into 
      # that number of equal length intervals; if a vector of values is provided, the 
      # values in the vector are used to determine the breakpoint. Note that if a vector 
      # of values is provided, the number of levels of the resultant factor will be one 
      # less than the number of values in the vector.
      # 
      # For example, consider the women data set, which contains height and weights for 
      # a sample of women. If we wanted to create a factor corresponding to weight, with 
      # three equally-spaced levels, we could use the following:

      # With R.d to access a build in dataset: "women"
      women = R.d("women")
      wfact = R.cut(women.weight, 3)
      wfact.table.pp

      # To produce factors based on percentiles of your data (for example quartiles or deciles), 
      # the quantile function can be used to generate the breaks argument, insuring nearly equal 
      # numbers of observations in each of the levels of the factor:

      wfact = R.cut(women.weight, R.quantile(women.weight, R.c((0..4))/4))
      wfact.table.pp

      # As mentioned in Section , there are a number of ways to create factors from date/time 
      # objects. If you wish to create a factor based on one of the components of that date, you 
      # can extract it with strftime and convert it to a factor directly. For example, we can use 
      # the seq function to create a vector of dates representing each day of the year:
      
      everyday = R.seq(from: R.as__Date('2005-1-1'), to: R.as__Date('2005-12-31'), by: 'day')
      everyday.pp

      # To create a factor based on the month of the year in which each date falls, we can extract 
      # the month name (full or abbreviated) using format:
      
      cmonth = R.format(everyday, '%b')
      months = R.factor(cmonth, levels: R.unique(cmonth), ordered: TRUE)
      months.table.pp

      # simplifying the above -- Javascript like:
      cmonth = everyday.format('%b')
      cmonth
        .factor(levels: cmonth.unique, ordered: TRUE)
        .table
        .pp

      # Since R.unique returns unique values in the order they are encountered, the levels 
      # argument will provide the month abbreviations in the correct order to produce a properly 
      # ordered factor.
      #
      # Sometimes more flexibility can be acheived by using the cut function, which understands 
      # time units of months, days, weeks and years through the breaks argument. (For date/time 
      # values, units of hours, minutes, and seconds can also be used.) For example, to format the 
      # days of the year based on the week in which they fall, we could use cut as follows:

      # NOT WORKING... check! Renjin is trying to cast a DoubleArrayVector into a IntVector
      # wks = R.cut(everyday, breaks: 'week')
      # R.head(wks).pp
      # p "Renjin bug"
      # R.eval("everyday = seq(from= as.Date('2005-1-1'), to= as.Date('2005-12-31'), by= 'day')")
      # R.eval("cut(everyday, breaks= 'week')")

      # Note that the first observation had a date earlier than any of the dates in the everyday 
      # vector, since the first date was in middle of the week. By default, cut starts weeks on 
      # Mondays; to use Sundays instead, pass the start.on.monday=FALSE argument to cut.
      # Multiples of units can also be specified through the breaks argument. For example, create 
      # a factor based on the quarter of the year an observation is in, we could use cut as follows:

      # NOT WORKING... check! Renjin is trying to cast a DoubleArrayVector into a IntVector
      # qtrs = R.cut(everyday, "3 months", labels: R.paste('Q',(1..4), sep: ''))
      # R.head(qtrs).pp

    end

  end

end

