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

    #======================================================================================
    #
    #======================================================================================

    setup do 

      # creating a new instance of Renjin
      @r1 = R.new

    end

    #======================================================================================
    #
    #======================================================================================

    should "integrate Ruby sequence with R sequence" do
      
      seq = R.seq(2, 10)

      res = R.eval <<EOF
      print(#{seq.r});
      print(#{seq.r});
print(ls());
EOF

      # remove the variable from R
      seq.destroy

      R.eval("print(ls())")

    end

    #======================================================================================
    #
    #======================================================================================

    should "integrate MDArray with R vector" do
      
      # typed_arange does the same as arange but for arrays of other type
      arr = MDArray.typed_arange(:double, 60)
      # MDArray is stored in row-major order
      arr.reshape!([5, 3, 4])
      # arr.print

      R.eval <<EOF
      print(#{arr.r});
      vec = #{arr.r};
print(vec);
print(vec[1, 1, 1]);

EOF

    end
    
  end
  
end
