# Announcement

SciCom version 0.2.3.1 has been released.  SciCom (Scientific Computing)
for Ruby brings the power of R to the Ruby community. SciCom is based
on Renjin, a JVM-based interpreter for the R language for statistical
computing.

R on the JVM
============

Over the past two decades, the R language for statistical computing
has emerged as the de facto standard for analysts, statisticians, and
scientists. Today, a wide range of enterprises – from pharmaceuticals
to insurance – depend on R for key business uses. Renjin is a new
implementation of the R language and environment for the Java Virtual
Machine (JVM), whose goal is to enable transparent analysis of big
data sets and seamless integration with other enterprise systems such
as databases and application servers.

Renjin is still under development, but it is already being used in
production for a number of client projects, and supports most CRAN
packages, including some with C/Fortran dependencies.

SciCom and Renjin
=================

SciCom integrates with Renjin and allows the use of R inside a Ruby
script. In a sense, SciCom is similar to other solutions such as
RinRuby, Rpy2, PipeR, etc. However, since SciCom and Renjin both
target the JVM there is no need to integrate both solutions and there
is no need to send data between Ruby and R, as it all resides in the
same JVM. Further, installation of SciCom does not require the
installation of GNU R; Renjin is the interpreter and comes with
SciCom. Finally, although SciCom provides a basic interface to Renjin
similar to RinRuby, a much tighter integration is also possible (see
examples below).

***
## SciCom with Standard R Interface

SciCom allows R programmers to use R commands inside a Ruby script in
a way similar to RinRuby by calling method eval and passing to it an R
script:

    # Basic integration with R can always be done by calling eval and passing it a valid
    # R expression.
    > R.eval("r.i = 10L")
    > R.eval("print(r.i)")

    [1] 10

    > R.eval("vec = c(10, 20, 30, 40, 50)")
    > R.eval("print(vec)")

    [1] 10 20 30 40 50

    > R.eval("print(vec[1])")

    [1] 10

Programmers can also use here docs to integrate an R script inside a
Ruby script.  The next example show a model for predicting baseball
wins based on runs allowed and runs scored.  The data comes from
Baseball-Reference.com.

      R.eval <<EOF

        # This dataset comes from Baseball-Reference.com.
        baseball = read.csv("baseball.csv")
        # str has a bug in Renjin
        # str(data)

        # Lets look at the data available for Momeyball.
        moneyball = subset(baseball, Year < 2002)

        # Let's see if we can predict the number of wins, by lookin at
        # runs allowed (RA) and runs scored (RS).  RD is the runs difference.
        # We are making a linear model from predicting wins (W) based on RD
        moneyball$RD = moneyball$RS - moneyball$RA
        WinsReg = lm(W ~ RD, data=moneyball)
        print(summary(WinsReg))

    EOF

The output of the program above is:

    Call:
    lm(data = moneyball, formula = W ~ RD)

    Residuals:
        Min      1Q  Median      3Q     Max
    -14,266  -2,651   0,123   2,936  11,657

    Coefficients:
                Estimate   Std. Error t value    Pr(>|t|)             
    (Intercept) 80,881     0,131      616,675    <0         ***       
             RD 0,106      0,001       81,554    <0         ***       
    ---
    Signif. codes:  0 '***' 0,001 '**' 0,01 '*' 0,05 '.' 0,1 ' ' 1 

    Residual standard error: 3,939 on 900 degrees of freedom
    Multiple R-squared: 0,8808,	Adjusted R-squared: 0,8807 
    F-statistic: 6.650,9926 on 1 and 900 DF,  p-value: < 0

## The SciCom “language”

SciCom also allows for implementing R scripts in a “language” that is
just like Ruby, so that the developer does not need to know that she
is actually writing an R script.  All R methods are accessible through
an R namespace.

The next script is the same baseball model done in R above using
SciCom ‘language’:

    require ‘scicom’
    # This dataset comes from Baseball-Reference.com.
    baseball = R.read__csv("baseball.csv")
    # Lets look at the data available for Momeyball.
    moneyball = baseball.subset(baseball.Year < 2002)

    # Let's see if we can predict the number of wins, by looking at
    # runs allowed (RA) and runs scored (RS).  RD is the runs difference.
    # We are making a linear model for predicting wins (W) based on RD
    moneyball.RD = moneyball.RS - moneyball.RA
    wins_reg = R.lm("W ~ RD", data: moneyball)
    wins_reg.summary.pp

We show bellow an example of calculating the correlation matrix
without using the build-in functions.  First this is done in an R
script and then using SciCom:

    # Create a matrix and give it rownames and colnames
    set.seed(42)
    Xij <- matrix(sample(seq(0, 9), 40, replace = TRUE), ncol = 4)
    rownames(Xij) <- paste("S", seq(1, dim(Xij)[1]), sep = "")
    colnames(Xij) <- paste("V", seq(1, dim(Xij)[2]), sep = "")
 
    # find the means of the columns
    n <- dim(Xij)[1]
    one <- rep(1, n)
    X.means <- t(one) %*% Xij/n
 
    # find the covariance of the matrix
    X.diff <- Xij - one %*% X.means
    X.cov <- t(X.diff) %*% X.diff/(n - 1)
    round(X.cov, 2)
 
    # find the correlation 
    sdi <- diag(1/sqrt(diag(X.cov)))
    rownames(sdi) <- colnames(sdi) <- colnames(X.cov)
    round(sdi, 2)
    X.cor <- sdi %*% X.cov %*% sdi
    rownames(X.cor) <- colnames(X.cor) <- colnames(X.cov)
    round(X.cor, 2)

Now the same code using SciCom

    require ‘scicom’
    # Create a matrix and give it rownames and colnames
    R.set__seed(42)
	R.seq(0,9).sample(40, replace: TRUE).matrix(ncol: 4)
	  .fassign(:rownames, R.paste("S", R.seq(1, xij.attr.dim[1]), sep: ""))
      .fassign(:colnames, R.paste("V", R.seq(1, xij.attr.dim[2]), sep: ""))
 
    # find the means of the columns
    n = xij.dim[1]
    one = R.rep(1, n)
    x_means = one.t._ :*, xij/n
 
    # find the covariance of the matrix
    x_diff = xij - (one._ :*, x_means)
    x_cov = (x_diff.t._ :*, x_diff/(n - 1)).round(2)
 
    # find the correlation 
    sdi = (1 / x_cov.diag.sqrt).diag.round(2)
    sdi.fassign(:rownames, x_cov.rownames)
    sdi.fassign(:colnames, x_cov.colnames)
    x_cor = ((sdi._ :*, x_cov)._ :*, sdi)
      .round(2)
      .fassign(:rownames, x_cov.rownames)
      .fassign(:colnames, x_cov.colnames)

As another example, here is a SciCom script to print the number of
days for every month is 2005:

    require ‘scicom’
    everyday = R.seq(from: R.as__Date('2005-1-1'), to: R.as__Date('2005-12-31'), by: 'day')
    cmonth = everyday.format('%b')
    cmonth
      .factor(levels: cmonth.unique, ordered: TRUE)
      .table
      .pp

As can be seen from these examples, R methods can be accessed through
the R namespace in SciCom, so, R method ‘seq’ is called in SciCom as
‘R.seq’.  R methods that are applied on objects can be called in two
ways, either using the R namespace as in ‘R.factor’ or directly on the
object, as in this case we did ‘cmonth.factor’.  This last example
shows how SciCom allows method chaining, which is not possible in an R
script.

## SciCom and MDArray

MDArray is a multi dimensional array implemented for JRuby inspired by
NumPy (www.numpy.org) and Masahiro Tanaka´s Narray
(narray.rubyforge.org).  MDArray stands on the shoulders of

Java-NetCDF and Parallel Colt.  At this point MDArray has libraries
for linear algebra, mathematical, trigonometric and descriptive
statistics methods.  NetCDF-Java Library is a Java interface to NetCDF
files, as well as to many other types of scientific data formats.  It
is developed and distributed by Unidata (http://www.unidata.ucar.edu).

Parallel Colt
(https://sites.google.com/site/piotrwendykier/software/parallelcolt)
is a multithreaded version of Colt
(http://acs.lbl.gov/software/colt/).  Colt provides a set of Open
Source Libraries for High Performance Scientific and Technical
Computing in Java. Scientific and technical computing is characterized
by demanding problem sizes and a need for high performance at
reasonably small memory footprint.

### Converting MDArray to R Array (same backing store)

An MDArray can be converted to an R array by calling method ‘R.md’.

First, let´s create an MDArray of shape [4, 3]:

    arr1 = MDArray.typed_arange("double", 12)
    arr1.reshape!([4, 3])
    arr1.print

This is arr1 as printed from MDArray:

    [[0.00 1.00 2.00]
     [3.00 4.00 5.00]
     [6.00 7.00 8.00]
     [9.00 10.00 11.00]]

Now, converting this array to an R array and printing it:

    r_matrix = R.md(arr1)
    r_matrix.pp

The result is:

         [,1] [,2] [,3]
    [1,]    0    1    2
    [2,]    3    4    5
    [3,]    6    7    8
    [4,]    9   10   11

One very important aspect of this conversion is that both the MDArray
and the R array use the same backing store, and thus, this conversion
does not do any copying and has very low cost.  However, WITH GREAT
POWER COMES GREAT RESPONSABILITIES: since MDArray and the R array have
the same backing store, a change in MDArray will also change the value
of the R array.  Renjin assumes that the vector will never change and
delays calculation of the vector to the latest possible time.  If
values change, the result can be unexpected, so, any changes to an
MDArray should be done with care.

### Array indexing

MDArrays are indexed starting at 0, while R arrays are indexed
starting at 1.  In order to facilitate the use of converted MDArrays
we introduced method ‘ri’ (r-indexing) that converts an MDArray index
into an R matrix index.  Comparing the content of the MDArray and R
array defined above can be done with:

    compare = MDArray.byte(arr1.shape)
    arr1.get_index.each do |ct|
        compare[*ct] = (arr1[*ct] == (r_matrix.ri(*ct).gz))? 1 : 0
    end
    comp = R.md(compare)
    p comp.all.gt


*	We first create a byte MDArray.  Byte arrays are converted to logical vectors in R;

*	arr1.get_index retrieves all indexes from arr1 in order;

* we then compare arr1\[\*ct\] (the array given its index) with
     r_matrix.ri(\*ct) (.ri converts the given index to an R index)

* In R, indexing a vector returns a new vector.  If we want to get a
     scalar and not a vector, SciCon provides method .gz.

* Finally, comp is converted to an logical vector in R and we call
     method all on this vector.  Method all returns true if all
     elements of the vector are true.  In this case, all elements are
     true and comp.all.gt print true.

### Multi-dimensional arrays

Multi-dimensional arrays can also be converted into R arrays using method ‘.md’.  However,
multi-dimension definition for MDArray and R arrays are different.  For instance, an MDArray
defined with the following dimensions [3, 2, 2] indicates that there are 3 vector of 2 x 2
dimensions.

The figure bellow shows a [3, 2, 2] array in MDArray.

    [[[0.00 1.00]
      [2.00 3.00]]

     [[4.00 5.00]
      [6.00 7.00]]

     [[8.00 9.00]
      [10.00 11.00]]]

Bellow we show a [3, 2, 2] array created in R.  In R this
specification indicates that the user wants to build an array of 2
vectors with size [3, 2].

    , , 1

         [,1] [,2]
    [1,]    0    3
    [2,]    1    4
    [3,]    2    5

    , , 2

         [,1] [,2]
    [1,]    6    9
    [2,]    7   10
    [3,]    8   11

In order to allow for easy use of converted arrays, when
multi-dimensional arrays are converted from MDArray to R array the R
array is dimensioned in order to be identical to the MDArray.  As
such, if the MDArray above is converted to an R array, the R array
dimension is [2, 2, 3].

### Dicing and Slicing MDArrays

MDArrays can be sliced and diced in many ways.  A slilced MDArray can
be converted to R array as any other MDArray.  From the point of view
of R, this is just a normal array.

When working with two dimensional arrays, each line is viewed as a new
record and there is no information encoded in the line number.
Columns encode information and each column has a different type of
value, for example, “name”, “age”, “phone number”, etc.

With multi-dimensional arrays, dimensions can encode information.  For
example, let´s suppose we are developing a system to analyze quotes
from multiple stocks.  Working with two dimensional arrays we would
have a file for each stock, in which each row would be a new record
and columns would represent, “open”, “high”, “low”, “close”, etc.  In
multi-dimensional arrays we can use a single array and the following
dimensions:

*	Dimension 0: The date of the quote. 
*	Dimension 1: The stock 
*	Dimension 2: The quote characteristic (“open”, “high”, etc.)

Let´s encode all quotes from Jul. 2014 for the following stocks:
Google, Microsoft, Yahoo and Apple.  We define an MDArray with the
following specification: [22, 4, 6].  The first dimension of size 22
represents the 22 business days of Jul. 2014. The second dimension of
size 4 is for each of the four stocks, and dimension 3 of size 6 has
the quote attributes “open”, “high”, “low”, “close”, “volume” and
“adjusted volume”.

Getting the data from Yahoo finance, we have that the opening value of
Google stock on 1/Jul/2014 was 578.32. So, we assign data[0, 0, 0] =
578,32.  The opening value of Google stock on 2/Jul/2014
was 583.35. So, again we have data[1, 0, 0] = 583.35.

Now, Microsoft “high” stock value on Jul/03/2014 was 44.09, so
data[2, 1, 1] = 44.09.

Let´s say that we want the have statistics about the opening price of
Google stocks.  We can slice the data array to create a view with only
the values of interest:

    sec = @data.section([0,  0, 0], [22, 1, 1], true)

The ‘section’ method gets a section of the original array.  It takes
two or three arguments.  The first two arguments are arrays and the
third in ‘true’ (when used).  The first array is an array of indexes
and the second is an array of sizes.  So, looking at the first
dimension, we start at index 0 and get 22 elements (all elements in
that dimension), in this example, all dates on Jul. 2014.  The second
dimension gets stock 0 and size 1, i.e., only 1 stock is selected. In
this example Google is indexed by 0.  Finally, the third dimension is
from index 0 (“open”) and of size 1, i.e., only the open attribute is
selected.  Printing sec gives:

    [578.32 583.35 583.35 583.76 577.66 571.58 565.91 571.91 582.60 585.74 588.00 579.53 593.00 591.75 590.72  593.23 596.45 590.40 588.07 588.75 586.55 580.60]

Now, let´s convert this to R and call the summary function, by:

    R.md(sec).summary.pp

The result is:

    Min.    1st Qu. Median  Mean    3rd Qu. Max.   
    565,9   579,8   584,8   584,1     590   596,5  
