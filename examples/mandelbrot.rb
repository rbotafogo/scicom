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

require 'env'
require 'scicom'



in.mandelbrot.set <- function(c, iterations = 100, bound = 1000000)
{
  z <- 0
 
  for (i in 1:iterations)
  {
    z <- z ** 2 + c
    if (Mod(z) > bound)
    {
      return(FALSE)
    }
  }
 
  return(TRUE)
}



resolution <- 0.001
 
sequence <- seq(-1, 1, by = resolution)
 
m <- matrix(nrow = length(sequence), ncol = length(sequence))
 
for (x in sequence)
{
  for (y in sequence)
  {
    mandelbrot <- in.mandelbrot.set(complex(real = x, imaginary = y))
    m[round((x + resolution + 1) / resolution), round((y + resolution + 1) / resolution)] <- mandelbrot
  }
}
 
png('mandelbrot.png')
image(m)
dev.off()
