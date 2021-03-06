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

require_relative 'test_R_interface'
require_relative 'test_creation'
require_relative 'test_basic'
require_relative 'test_vector'
require_relative 'test_operators'
require_relative 'test_list'
require_relative 'test_attributes'
require_relative 'test_factor'
require_relative 'test_array'
require_relative 'test_matrix'
require_relative 'test_mdarray'
require_relative 'test_dataframe'
require_relative 'test_linear_model'
require_relative 'test_callback'

require_relative 'test_assign_mdarray'
require_relative 'test_assign_mdarray_2d'
require_relative 'test_assign_mdarray_3d'

=begin
require_relative 'test_subsetting'
require_relative 'test_double_receive'
require_relative 'test_functions'
require_relative 'test_user_function'
require_relative 'test_column-major'
=end
