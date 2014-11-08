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
    # 
    #--------------------------------------------------------------------------------------
=begin
    should "create data-frame single vector" do

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
=end
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
      R.colnames(df).pp
      # df.colnames(prefix: "col")
      R.colnames(df).pp

=begin

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
