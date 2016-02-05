# coding: utf-8
require '../config'
require 'scicom'
require_relative 'rbmarkdown'

# title("A (not so) Short Introduction to SciCom")

author("Rodrigo Botafogo")

body(<<-EOT)
Caveat: This article's name is actually a misnomer. This is not really a small introduction to
SciCom, it is actually a comparison between SciCom's object oriented 
features and R's S4 object oriented model.  This paper is a shameless rip off of 
#{ref("A '(not so)' Short Introduction to S4", 
"https://cran.r-project.org/doc/contrib/Genolini-S4tutorialV0-5en.pdf")} by Christophe Genolini
and follows the same structure and examples presented there.

SciCom is a Ruby Gem that allows very tight integration between Ruby and R.  It's integration is
much tigher and transparent from what one can see beetween RinRuby or similar solutions in Python
such as PyPer (??), RPython and other solutions.  SciCom targets the Java Virtual Machine and it
integrates with Renjin (http://www.renjin.org/), an R interpreter for Java.  

From the Renjin page we can get the following description of Renjin and its objectives:

The goal of Renjin 
is to eventually be compatible with GNU R such that most existing R language programs will 
run in Renjin without the need to make any changes to the code. Needless to say, Renjin is 
currently not 100% compatible with GNU R so your mileage may vary. 

The biggest advantage of Renjin is that the R interpreter itself is a Java module which can be 
seamlessly integrated into any Java application. This dispenses with the need to load dynamic 
libraries or to provide some form of communication between separate processes. These types of 
interfaces are often the source of much agony because they place very specific demands on the 
environment in which they run.

In this paper, we will start our discussion from Part II of "The (not so) Short Introduction 
to S4", which from now on we will reference as SS4 for "short S4". Interested readers are directed 
to this paper to understand the motivation and examples in that paper.  In this paper we will
present the S4 code from SS4 and then the same code in Ruby/SciCom.  We will not comment on the
S4 code, as all the comments can be found in SS4, we will only focus on the Ruby/SciCom 
description.

S4 defines classes by using the setClass function:
EOT

comment_code(<<-EOT)
# > setClass(
# + Class="Trajectories",
# + representation=representation(
# + times = "numeric",
# + traj = "matrix"
# + )
# + )
EOT

section("Instance Variables")

body(<<-EOT)
In Ruby a class is defined by the keyword 'class'.  Every class should start with a capital 
letter.  S4 'slots' are called 'instance variables' in Ruby.  Differently from R's S4, 
instance variables in Ruby do not have type information.  It should be clear though, that S4
type information is also not a "compile" time type, since R is not compiled.  The type is 
checked at runtime.  The same checking can be done in Ruby and we will do it later in this 
document.

In the example bellow, we create 
class Trajectories with two instance variables, 'times' and 'matrix'.  We will not go over 
the details of instance variables in Ruby, but here we created those variables with the 
keyword 'attr_reader' and a colomn before the variables name:
EOT

code(<<-EOT)
class Trajectories

  attr_reader :times
  attr_reader :matrix

end

EOT

body(<<-EOT)
In order to create a new instance of object Trajectories we call method new on the class and
we can store the result in a varible (not an instance variable) as bellow:
EOT

console(<<-EOT)
traj = Trajectories.new
EOT

body(<<-EOT)
We now have in variable 'traj' a Trajectories object.  In Ruby, printing variable 'traj' will 
only print the class name of the object and not it contents as in R.  
EOT

console(<<-EOT)
puts traj
EOT

body(<<-EOT)
To see the contents of an object, one needs to access its components using the '.' operator:
EOT

console(<<-EOT)
puts traj.times
EOT

section("Constructor")

body(<<-EOT)
Since there is no content stored in 'times' nor 'matrix', nil is returned.  In order to add
a value in the variables, we need to add a contructor the class Trajectories.  In R, a 
constructor is build by default, in Ruby, this has to be created by adding a method called
'initialize'.  In the example bellow, we will create the initializer that accepts two values,
a 'times' value and a 'matrix' value and they are used to initialize the value of the 
instance variables:
EOT

code(<<-EOT)

class Trajectories
  
  attr_reader :times
  attr_reader :matrix

  def initialize(times: nil, matrix: nil)
    @times = times
    @matrix = matrix
  end

end

EOT

body(<<-EOT)
Up to this point, everything described in pure Ruby code and has absolutely no relationship is R.
We now want to create a Trajectories with a 'times' vector.  Ruby has a vector class and we could
use this class to create a vector and add it to the 'times' instance variable; however, in order
to make use of R's functions, we want to create a R vector to add to 'times'.  In SciCom, 
creating R objects is done using the corresponding R functions by just preceding them with 'R.',
i.e., R functions are all defined in SciCom in the R namespace.

Since SciCom is Ruby and not R, some syntax adjustments are sometimes necessary.  For instance,
in R, a range is represented as '(1:4)', in Ruby, the same range is represented as '(1..4)'. 
When passing arguments to an R funciton in R one uses the '=' sign after the slot name; in R,
one uses the ':' operator after parameter's name as we can see bellow:
EOT

code(<<-EOT)
# Create a Trajectories with the times vector [1, 2, 3, 4] and not matrix
traj = Trajectories.new(times: R.c(1, 2, 3, 4))

# Create a Trajectories with times and matrix
traj2 = Trajectories.new(times: R.c(1, 3), matrix: R.matrix((1..4), ncol: 2))
EOT

section("Access to Instance Variables (to reach a slot)")

body(<<-EOT)
In order to access data in an instace variable the operator '.' is used.  In R, a similar
result is obtained by use of the '@' operator, but SS4 does not recomend its use.  In SciCom,
the '.' operator is the recomended way of accessing an instance variable.
 
Now that we have created two trajectories, let's try to print its instance variables to see 
that everything is fine:
EOT

console(<<-EOT)
puts traj.times
EOT

body(<<-EOT)
Well this wasn't really what we had expected... as explained before, printing a variable, will
actually only show the class name and vector 'times' in SciCom is actually a Renjin::Vector.
In order to print the content of a SciCom object we use method 'pp' as follows:
EOT

console(<<-EOT)
traj.times.pp
EOT

body(<<-EOT)
We now have the expected value.  Note that the 'times' vector is printed exactly as it would
if we were using GNU R.  Let's now take a look at variable 'traj2':
EOT

console(<<-EOT)
traj2.times.pp
EOT

console(<<-EOT)
traj2.matrix.pp
EOT

body(<<-EOT)
Let's now build the same examples as in SS4:  Three hospitals take part in a 
study. The Pitié Salpêtriere (which has not yet returned its data file, shame on them!),
Cochin and Saint-Anne.  We first show the code in R and the the corresponding SciCom:
EOT

comment_code(<<-EOT)
> trajPitie <- new(Class="Trajectories")
> trajCochin <- new(
+     Class= "Trajectories",
+     times=c(1,3,4,5),
+     traj=rbind (
+         c(15,15.1, 15.2, 15.2),
+         c(16,15.9, 16,16.4),
+         c(15.2, NA, 15.3, 15.3),
+         c(15.7, 15.6, 15.8, 16)
+     )
+ )
> trajStAnne <- new(
+     Class= "Trajectories",
+     times=c(1: 10, (6: 16) *2),
+     traj=rbind(
+         matrix (seq (16,19, length=21), ncol=21, nrow=50, byrow=TRUE),
+         matrix (seq (15.8, 18, length=21), ncol=21, nrow=30, byrow=TRUE)
+     )+rnorm (21*80,0,0.2)
+ )
EOT

body(<<-EOT)
This same code in SciCom becomes:
EOT

code(<<-EOT)
trajPitie = Trajectories.new
EOT

code(<<-EOT)
trajCochin = Trajectories.new(times: R.c(1,3,4,5),
                              matrix: R.rbind(
                                R.c(15,15.1, 15.2, 15.2),
                                R.c(16,15.9, 16,16.4),
                                R.c(15.2, NA, 15.3, 15.3),
                                R.c(15.7, 15.6, 15.8, 16)))
EOT

code(<<-EOT)
trajStAnne =
  Trajectories.new(times: R.c((1..10), R.c(6..16) * 2),
                   matrix: (R.rbind(
                             R.matrix(R.seq(16, 19, length: 21), ncol: 21,
                                      nrow: 50, byrow: true),
                             R.matrix(R.seq(15.8, 18, length: 21), ncol: 21,
                                      nrow: 30, byrow: true)) + R.rnorm(21*80, 0, 0.2)))

EOT

body(<<-EOT)
Let's check that the 'times' and 'matrix' instace variables were correctly set:
EOT

console(<<-EOT)
trajCochin.times.pp
EOT

console(<<-EOT)
trajCochin.matrix.pp
EOT

console(<<-EOT)
trajStAnne.times.pp
EOT

body(<<-EOT)
We will not at this time print trajStAnne.matrix, since this is a huge matrix and the result
would just take too much space.  Later we will print just a partial view of the matrix.
EOT

section("Default Values")

body(<<-EOT)
Default values are very useful and quite often used in Ruby programs.  Although SS4 does not
recommend its use, there are many cases in which default values are useful and make code simpler.
We have already seen default values in this document, with the default being 'nil'.  This was
necessary in order to be able to create our constructor and passing it the propoper values.

In the example bellow, a class TrajectoriesBis is created with default value 1 for times and a 
matrix with no elements in matrix.
EOT

code(<<-EOT)
class TrajectoriesBis

  attr_reader :times
  attr_reader :matrix

  def initialize(times: 1, matrix: R.matrix(0))
    @times = times
    @matrix = matrix
  end
  
end

traj_bis = TrajectoriesBis.new
EOT

body(<<-EOT)
Let's take a look at our new class:
EOT

console_error(<<-EOT)
traj_bis.times.pp
EOT

body(<<-EOT)
Well, not exactly what we had in mind.  We got an error saying that .pp is undefined for 
Fixnum.  In R, numbers are automatically converted to vectors, but this is not the case
in Ruby and SciCom.  In Ruby, numbers are numbers and vectors are vectors.  In the 
initialize method above, we stored 1 in variable @times and 1 is a number.  Method .pp is
only available for R objects.  

In order to fix this, we need to fix our initializer to convert number 1 to a vector with
one element of value 1.  SciCom provides the method R.i to do this conversion.  

When calling an R function that expects a number as argument, this conversion is
automatically done by SciCom; however, in the initialize method, there is no indication 
to SciCom that variable @times is actually a SciCom variable, since there is no type 
information.  In this case, we need to be explicit and use R.i:
EOT

code(<<-EOT)
class TrajectoriesBis

  attr_reader :times
  attr_reader :matrix

  # Use R.i to convert number 1 to a vector
  def initialize(times: R.i(1), matrix: R.matrix(0))
    @times = times
    @matrix = matrix
  end
  
end

traj_bis = TrajectoriesBis.new
EOT

console(<<-EOT)
traj_bis.times.pp
EOT

console(<<-EOT)
traj_bis.matrix.pp
EOT

section("To Remove an Object")

body(<<-EOT)
As far as I know, there isn't a good way of removing a defined class, but there might be
one and the interested user is directed to google it!  In principle, there should not be
any real need to remove a defined class.  Both in R and SciCom, large programs are usually
written in a file and the file loaded.  If one writes a wrong class, the better solution is
to correct it on and then load it again.  If the class is written directly on the console,
then leaving it there will not have any serious impact.
EOT

section ("The Empty Object")

body(<<-EOT)
When a Trajectories is created with new, and no argument is given, all its instance variables
will have the default nil value.  Since Ruby has no type information, then there is only one
type (or actually no type) of nil.  To check if a variable is empty, we check it agains the nil
value.
EOT

section ("To See an Object")

body(<<-EOT)
Ruby has very strong meta-programming features, in particular, one can use instrospection to 
see methods and instance variables from a given class.  Method 'instance_variables' shows all
the instace variables of an object:
EOT

console(<<-EOT)
puts traj.instance_variables
EOT

body(<<-EOT)
The description of all meta-programming features of Ruby is well beyond the scope of this 
document, but it is a very frequent a powerful feature of Ruby, that makes programming in
Ruby a different experience than programming in other languages.
EOT

section ("Methods")

body(<<-EOT)
Methods are a fundamental feature of object oriented programming. We will now extend our class
Trajectories to add methods to it.  In SS4, a method 'plot' is added to Trajectories.  At this
point, Renjin and SciCom do not yet have ploting capabilities, so we will have to skip this 
method and go directly to the implementation of the 'print' method.

Bellow is the R code for method print:
EOT

comment_code(<<-EOT)
> setMethod ("print","Trajectories",
+ function(x,...){
+ cat("*** Class Trajectories, method Print *** \n")
+ cat("* Times ="); print (x@times)
+ cat("* Traj = \n"); print (x@traj)
+ cat("******* End Print (trajectories) ******* \n")
+ }
+ )
EOT

body(<<-EOT)
Now the same code for class Trajectories in Scicom.  In general methods are defined in a class
together with all the class definition.  We will first use this approach. Later, we will show
how to 'reopen' a class to add new methods to it.

In this example, we are defining a method named 'print'.  We have being using method 'puts' to
output data.  There is a Ruby method that is more flexible than puts and that we need to use to
implement our function: 'print'. However, trying to use Ruby print inside the definition of 
Trajectories's print will not work, as Ruby will understand that as a recursive call to print. 
Ruby's print is defined inside the Kernel class, so, in order to call Ruby's print inside the
definition of Trajectories's print we need to write 'Kernel.print'.
EOT

code(<<-EOT)
class Trajectories
  
  attr_reader :times
  attr_reader :matrix

  #
  # 
  #
  def initialize(times: nil, matrix: nil)
    @times = times
    @matrix = matrix
  end

  def print
    puts("*** Class Trajectories, method Print *** ")
    Kernel.print("times = ")
    @times.pp
    puts("traj =")
    @matrix.pp
    puts("******* End Print (trajectories) ******* ")
  end
  
end
EOT

console(<<-EOT)
trajCochin.print
EOT

body(<<-EOT)
For Cochin, the result is correct. For Saint-Anne, print will display too much
information. So we need a second method.

Show is the default R method used to show an object when its name is written in the
console. We thus define 'show' by taking into account the size of the object: if there are too
many trajectories, 'show' posts only part of them.

Here is the R code for method 'show':
EOT

comment_code(<<-EOT)
> setMethod("show","Trajectories",
+ function(object){
+ cat("*** Class Trajectories, method Show *** \n")
+ cat("* Times ="); print(object@times)
+ nrowShow <- min(10,nrow(object@traj))
+ ncolShow <- min(10,ncol(object@traj))
+ cat("* Traj (limited to a matrix 10x10) = \n")
+ print(formatC(object@traj[1:nrowShow,1:ncolShow]),quote=FALSE)
+ cat("******* End Show (trajectories) ******* \n")
+ }
+ )
EOT

body(<<-EOT)
Now, let's write it with SciCom.  This time though, we will not rewrite the whole Trajectories
class, but just reopen it to add this specific method:
EOT

code(<<-EOT)
class Trajectories

  def show
    puts("*** Class Trajectories, method Show *** ")
    Kernel.print("times = ")
    @times.pp
    nrow_show = R.min(10, @matrix.nrow).gz
    ncol_show = R.min(10, @matrix.ncol).gz
    puts("* Traj (limited to a matrix 10x10) = ")
    @matrix[(1..nrow_show), (1..ncol_show)].format(digits: 2, nsmall: 2).pp
    puts("******* End Show (trajectories) ******* ")
  end
  
end
EOT

console(<<-EOT)
trajStAnne.show
EOT

