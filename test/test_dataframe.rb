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

require '../config' if @platform == nil
require 'scicom'

class SciComTest < Test::Unit::TestCase

  context "R environment" do

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    setup do 

    end


    #--------------------------------------------------------------------------------------
    # 
    #--------------------------------------------------------------------------------------

    should "create data-frame from a single vector" do

      vec = R.seq(20)
      vec.attr.dim = R.c(4, 5)
      df = R.as__data__frame(vec)
      df.pp
      assert_equal(4, df.nrow.gz)
      assert_equal(5, df.ncol.gz)

      df[0].pp
      df[1].pp
      df["V2"].pp
      df["V4"].pp

    end

    #--------------------------------------------------------------------------------------
    # 
    #--------------------------------------------------------------------------------------

    should "work with build-in data-frames" do

      # We use built-in data frames in R for our tutorials. For example, here is a built-in 
      # data frame in R, called mtcars.

      # to access a build-in data-frame, use method R.d with the data-frame's name
      mtcars = R.d("mtcars")

      p "mtcars build-in data-frame"
      mtcars.pp

      # Here is the cell value from the first row, second column of mtcars.
      assert_equal(6, mtcars[1, 2].gz)

      # Moreover, we can use the row and column names instead of the numeric coordinates.
      assert_equal(6, mtcars["Mazda RX4", "cyl"].gz)

      # Lastly, the number of data rows in the data frame is given by the nrow function.
      assert_equal(32, mtcars.nrow.gz)    # number of data rows 

      # And the number of columns of a data frame is given by the ncol function.
      assert_equal(11, mtcars.ncol.gz)    # number of columns 

      p "mtcars head"
      mtcars.head.pp

    end

    #--------------------------------------------------------------------------------------
    # 
    #--------------------------------------------------------------------------------------

    should "access data-frames by column vector" do

      mtcars = R.d("mtcars")

      # We reference a data frame column with the double square bracket "[[]]" operator.
      # For example, to retrieve the ninth column vector of the built-in data set mtcars, 
      # we write mtcars[[9]].
      mtcars[[9]].pp

      # We can retrieve the same column vector by its name.
      mtcars[["am"]].pp

      # We can also retrieve with the "." operator in lieu of the double square 
      # bracket operator.
      mtcars.am.pp 

      # Yet another way to retrieve the same column vector is to use the single square 
      # bracket "[]" operator. We prepend the column name with 'nil', which signals a 
      # wildcard match for the row position.
      mtcars[nil, "am"].pp

    end

    #--------------------------------------------------------------------------------------
    # 
    #--------------------------------------------------------------------------------------

    should "access data-frames by column slice" do

      mtcars = R.d("mtcars")

      # We retrieve a data frame column slice with the single square bracket "[]" operator.

      # Numeric Indexing
      # The following is a slice containing the first column of the built-in data set 
      # mtcars.
      mtcars[1].pp

      # Name Indexing
      # We can retrieve the same column slice by its name.
      mtcars["mpg"].pp

      # To retrieve a data frame slice with the two columns mpg and hp, we pack the 
      # column names in an index vector inside the single square bracket operator.
      mtcars[R.c("mpg", "hp")].pp

    end

    #--------------------------------------------------------------------------------------
    # 
    #--------------------------------------------------------------------------------------

    should "access data-frames by row slice" do

      mtcars = R.d("mtcars")

      # We retrieve rows from a data frame with the single square bracket operator, just 
      # like what we did with columns. However, in additional to an index vector of row 
      # positions, we append an nil. This is important, as the nil signals a wildcard match 
      # for the second coordinate for column positions.

      # Numeric Indexing
      # For example, the following retrieves a row record of the built-in data set mtcars. 
      # Please notice the nil in the square bracket operator. It states that the 1974 Camaro 
      # Z28 has a gas mileage of 13.3 miles per gallon, and an eight cylinder 245 horse power 
      # engine, ..., etc.
      mtcars[24, nil].pp

      # To retrieve more than one row, we use a numeric index vector.
      mtcars[R.c(3, 24), nil].pp 

      # Name Indexing
      # We can retrieve a row by its name.
      mtcars["Camaro Z28", nil].pp

      # And we can pack the row names in an index vector in order to retrieve multiple 
      # rows.
      mtcars[R.c("Datsun 710", "Camaro Z28"), nil].pp

      # Logical Indexing
      # Lastly, we can retrieve rows with a logical index vector. In the following 
      # vector L, the member value is TRUE if the car has automatic transmission, and 
      # FALSE if otherwise.
      auto = mtcars.am == 0
      auto.pp

      # Here is the list of vehicles with automatic transmission.
      mtcars[auto, nil].pp

      # And here is the gas mileage data for automatic transmission.
      mtcars[auto, nil].mpg.pp 

    end

    #--------------------------------------------------------------------------------------
    # 
    #--------------------------------------------------------------------------------------

    should "create data-frame from multiple vectors" do

      # name     age  hgt  wgt  race year   SAT 
      # Bob       21   70  180  Cauc   Jr  1080
      # Fred      18   67  156 Af.Am   Fr  1210
      # Barb      18   64  128 Af.Am   Fr   840
      # Sue       24   66  118  Cauc   Sr  1340
      # Jeff      20   72  202 Asian   So   880

      name = R.c("Bob", "Fred", "Barb", "Sue", "Jeff")
      age = R.c(21, 18, 18, 24, 20)
      hgt = R.c(70, 67, 64, 66, 72)
      wgt = R.c(180, 156, 128, 118, 202)
      race = R.c("Cauc", "Af. Am", "Af. Am", "Cauc", "Asian")
      sat = R.c(1080, 1210, 840, 1340, 880)

      df = R.data__frame(name, age, hgt, wgt, race, sat)
      df.colnames.pp
      df.colnames(prefix: "sc").pp

      # Renjin allows changes to variable properties
      R.eval("colnames(#{df.r}) = c('name', 'age', 'height', 'weigth', 'race', 'SAT')")
      R.eval("print(colnames(#{df.r}))")

      rbvec = R.eval("vec = c(1, 2, 3, 4, 5)")
      # this is a new vector with the same name.  Assigning a new value to a large
      # vector can then be very costly as every assignment does copy the old data.
      R.eval("vec[1] = 10")
      R.eval("print(vec)")
      # this proves that vec is actually a new vec.  We have kept the old vector in 
      # variable rbvec.
      rbvec.print

=begin
      # R.colnames(df) = R.c("name", "age", "height", "weigth", "race", "SAT")
      df.print
      summ = R.summary(df.r)
      p summ
      summ.print

      R.eval("print(colnames(#{df.r}))")
      col = R.colnames(:df)
      col.print
=end
    end

  end
  
end
