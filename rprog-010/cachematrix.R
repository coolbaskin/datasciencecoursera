# Creates a special CacheMatrix object (in Object-Oriented Programming sense)

# The objects is implemented as a list that stores its methods (functions that act on its member variables). Its member
# variables are local variables of the constructor function makeCacheMatrix(). Every time the makeCacheMatrix() is
# called, a new environment is created and initialized, so all instances of the objects  have their own independent
# instances of the member variables.
#
# Note: the downside of this approach to OOP is that since functions are also stored in the environment, all the methods
# are also created every time the object is created, so without cleaver optimization from R interpreter, their code is
# needlessly duplicated.
# 
# Note: since in R variable declaration and initialization are inseparable, member functions are using <<- variable to
# assign values to the variables from the generating function's environment. 
# 
# RIGHT:
#   x <- 5
#   set_to_10 <- function() { x <<- 10 }
# WRONG: 
#   x <- 5
#   set_to_10 <- function() { 
#        # This creates an x variable local to set_to_10() function and assigns to it
#        # And variable x from the enclosing environment remains unchanged
#        x <- 10 
# }
# Note: function arguments are also function's local variables

makeCacheMatrix <- function(x = matrix()) 
{
    # Assign initial values of the member variables to
    #   x = matrix()    # Initialized as the default value of the function argument
    #   inv = NA
    inv <- NULL

    # Getter functions just return values of the member variables
    get_matrix <- function() { x }
    get_inverse <- function() { inv }

    # Setter functions

    # Stores the matrix value in the member variable and invalidates the cached inverse
    set_matrix <- function(x_new) 
    {
        x <<- x_new
        inv <<- NULL
    }

    # Stores the matrix inverse in the member variable

    # Warning: with this implementation it is possible to set inverse of the matrix stored in inv to not be the actual
    # inverse of the matrix stored in x. Hence the method's name is started from dot to signify that this method not a
    # part of the public interface available to object/library users. It should only be used by other function from the
    # same object/library that are actually setting the correct matrix inverse

    .set_inverse <- function(inv_new) { inv <<- inv_new }

    # TRUE if the inverse is cached, false otherwise, also internal
    .is_inverse_cached <- function() { !is.null(inv) }

    # Construct the object as the list of its methods and return to the user

    # Note: if it was not explicitly dictated by the homework's formulation, .set_inverse and .is_inverse_cached would
    # actually not be returned in this list. The cacheSolve() function would also be a method of the CacheMatrix
    # implemented inside makeCacheMatrix() function and thereby able to use all methods without the need to make them
    # explicitly visible to the user
    return(invisible(
        list(
             set_matrix = set_matrix
             ,get_matrix = get_matrix
             ,get_inverse = get_inverse
             ,.set_inverse = .set_inverse
             ,.is_inverse_cached = .is_inverse_cached
        )
    ));
}

# Returns a matrix that is the inverse of x, where x is a special 'object' created by makeCacheMatrix() function
# Uses memoization: 
#   if the inverse is not computed and stored in the 'object' itself, compute it and cache it
#   used cached value otherwise
# 
# Note: does not fully check for x to actually be this special object, so unexpected behavior may happen if it is not
cacheSolve <- function(x, ...) 
{
    # Check if we already have a cached inverse. If so, return it
    if( x$.is_inverse_cached() ) { return(invisible(x$get_inverse())); }

    # Otherwise, compute inverse of x passing additional arguments to solve() via ... and caching the result afterwards
    inv <- solve(x$get_matrix(), ...);

    # Cache the inverse and return it as a value of cacheSolve()
    return(invisible(x$.set_inverse(inv)));
}
