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
    # R code in this file are extracted from:
    #
    # Matrix Algebra in R
    # William Revelle
    # Northwestern University
    # January 24, 2007
    # http://personality-project.org/r/sem.appendix.1.pdf
    #--------------------------------------------------------------------------------------

    setup do 
      
    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "create matrix with the matrix function" do

      # R provides numeric row and column names (e.g., [1,] is the first row, [,4] is the 
      # fourth column, but it is useful to label the rows and columns to make the rows 
      # (subjects) and columns (variables) distinction more obvious.
      xij = R.matrix(R.seq(1..40), ncol: 4)
      
      # method fassign is used whenever in R there would be a function assignment such as,
      # for example: rownames(x) <- c("v1", "v2", "v3")
      # R.fassign(xij, :rownames, R.paste("S", R.seq(1, xij.attr.dim[1]), sep: ""))
      # R.fassign(xij, :colnames, R.paste("V", R.seq(1, xij.attr.dim[2]), sep: ""))

      # this can also be done by calling fassing on the object directly
      xij.fassign(:rownames, R.paste("S", R.seq(1, xij.attr.dim[1]), sep: ""))
      xij.fassign(:colnames, R.paste("V", R.seq(1, xij.attr.dim[2]), sep: ""))
      xij.pp

      # if an index can be passed to the R function, then fassign needs to be a bit more
      # complex. For instance, callling dimnames(x)[[1]] <- "name" is done by the following
      # call: x.fassign({f: :dimnames, index:[[1]]}, "name"
      # Changing rownames by using function :dimnames and index [[1]]
      xij.fassign({f: :dimnames, index: [[1]]}, 
        R.paste("DS", R.seq(1, xij.attr.dim[1]), sep: ""))

      # Changing colnames by using function :dimnames and index [[2]]
      xij.fassign({f: :dimnames, index: [[2]]}, 
        R.paste("DV", R.seq(1, xij.attr.dim[2]), sep: ""))

      xij.pp

      # Just as the transpose of a vector makes a column vector into a row vector, so 
      # does the transpose of a matrix swap the rows for the columns. Note that now the 
      # subjects are columns and the variables are the rows.
      xij.t.pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "add matrices" do

      # The previous matrix is rather uninteresting, in that all the columns are simple 
      # products of the first column. A more typical matrix might be formed by sampling 
      # from the digits 0-9. For the purpose of this demonstration, we will set the random 
      # number seed to a memorable number so that it will yield the same answer each time.
      R.set__seed(42)
      xij = R.matrix(R.sample(R.seq(0, 9), 40, replace: TRUE), ncol: 4)

      xij.fassign(:rownames, R.paste("S", R.seq(1, xij.attr.dim[1]), sep: ""))
      xij.fassign(:colnames, R.paste("V", R.seq(1, xij.attr.dim[2]), sep: ""))
      xij.pp

      # Just as we could with vectors, we can add, subtract, muliply or divide the matrix 
      # by a scaler (a number with out a dimension)
      (xij + 4).pp

      ((xij + 4) / 3).round(2).pp


      # We can also multiply each row (or column, depending upon order) by a vector.
      v = R.seq(10)
      v.pp
      
      (xij * v).pp

    end

    #--------------------------------------------------------------------------------------
    #
    #--------------------------------------------------------------------------------------

    should "multiply matrices" do

      R.set__seed(42)
      xij = R.matrix(R.sample(R.seq(0, 9), 40, replace: TRUE), ncol: 4)
      xij.fassign(:rownames, R.paste("S", R.seq(1, xij.attr.dim[1]), sep: ""))
      xij.fassign(:colnames, R.paste("V", R.seq(1, xij.attr.dim[2]), sep: ""))

      # Consider our matrix Xij with 10 rows of 4 columns. Call an individual element in 
      # this matrix xij . We can find the sums for each column of the matrix by multiplying 
      # the matrix by our “one” vector with Xij. That is, we can find PN i=1 Xij for the j 
      # columns, and then divide by the number (n) of rows. (Note that we can get the same 
      # result by finding colMeans(Xij). We can use the dim function to find out how many 
      # cases (the number of rows) or the number of variables (number of columns). dim has 
      # two elements: dim(Xij)[1] = number of rows, dim(Xij)[2] is the number of columns.
      xij.dim.pp

      n = xij.dim[1]
      n.pp
      one = R.rep(1, n)
      one.pp
      x_means = one.t._ :*, xij/n
      x_means.pp

      # A built in function to find the means of the columns is colMeans. (See rowMeans 
      # for the equivalent for rows.)
      xij.colMeans.pp

      # x_means and xij.colMeans have the same results
      assert_equal(true, (x_means == xij.colMeans).all.gt)

      # Variances and covariances are measures of dispersion around the mean. We find 
      # these by first subtracting the means from all the observations. This means centered 
      # matrix is the original matrix minus a matrix of means. To make them have the same 
      # dimensions we premultiply the means vector by a vector of ones and subtract this from 
      # the data matrix.
      x_diff = xij - (one._ :*, x_means)
      x_diff.pp

      # To find the variance/covariance matrix, we can first find the the inner product of 
      # the means centered matrix X.diff = Xij - X.means t(Xij-X.means) with itself and divide 
      # by n-1. We can compare this result to the result of the cov function (the normal way to 
      # find covariance
      x_cov = (x_diff.t._ :*, x_diff/(n - 1)).round(2)
      x_cov.pp

      # calling function cov
      xij.cov.round(2).pp

      # both solutions are equal
      assert_equal(true, (x_cov == xij.cov.round(2)).all.gt)

      # Some operations need to find just the diagonal. For instance, the diagonal of the 
      # matrix x_cov (found above) contains the variances of the items. To extract just the 
      # diagonal, or create a matrix with a particular diagonal we use the diag command. We 
      # can convert the covariance matrix x_cov to a correlation matrix x_cor by pre and post 
      # multiplying the covariance matrix with a diagonal matrix containing the reciprocal of 
      # the standard deviations (square roots of the variances). Remember that the correlation, 
      # r_xy, is merely the covariance_xy/sqrt(VxVy). Compare this to the standard command for 
      # finding correlations cor.
      x_cov.diag.round(2).pp

      sdi = (1 / x_cov.diag.sqrt).diag
      sdi.fassign(:rownames, x_cov.rownames)
      sdi.fassign(:colnames, x_cov.colnames)
      sdi.round(2).pp

      x_cor = (sdi._ :*, x_cov)._ :*, sdi
      x_cor.fassign(:rownames, x_cov.rownames)
      x_cor.fassign(:colnames, x_cov.colnames)
      x_cor.round(2).pp

      # use the cor function to find the correlation
      xij.cor.round(2).pp

      assert_equal(true, (x_cor.round(2) == xij.cor.round(2)).all.gt)

    end


  end

end
