# Write a function that reads a directory full of files and reports the number of completely observed cases in each data
# file. The function should return a data frame where the first column is the name of the file and the second column is
# the number of complete cases. 

# Example output
# > complete("specdata", 1)
# id nobs
# 1 1 117
# > complete("specdata", c(2, 4, 8, 10, 12))
# id nobs
# 1 2 1041
# 2 4 474
# 3 8 192
# 4 10 148
# 5 12 96
# > complete("specdata", 30:25)
# id nobs
# 1 30 932
# 2 29 711
# 3 28 475
# 4 27 338
# 5 26 586
# 6 25 463
# > complete("specdata", 3)
# id nobs
# 1 3 243

complete <- function(a_directory, a_id = 1:332) 
{
	# ARGS
	## 'directory' is a character vector of length 1 indicating ## the location of the CSV files
	directory = as.character(a_directory);

	if(length(directory) != 1) {
		stop(paste0("directory has a length > 1: length = ", length(a_directory) ))
	}

	if(is.na(directory)) {
		stop(paste0("directory cannot be coerced to a character vector: ", a_directory))
	}

	if(!file.exists(directory)) {
		stop(paste0("directory <", directory, "> does not exist"));
	}

	## 'id' is an integer vector indicating the monitor ID numbers ## to be used
	id = as.integer(a_id);

	if( any(is.na(id)) ) {
		stop(paste0("id cannot be coerced to integer: ", a_id))
	}
	
	# EXECUTE
	## Return a data frame of the form:
	## id nobs
	## 1  117
	## 2  1041
	## ...
	## where 'id' is the monitor ID number and 'nobs' is the
	## number of complete cases

	# Initialize the data frame with results
	n_results = length(a_id);
	result = data.frame(id = rep(NA, n_results), nobs = rep(NA, n_results) );

	# Go through files gathering statistic along the way
	for(i in seq_along(a_id)) {
		cur_id = a_id[i];	

		d <- getmonitor(cur_id, directory);

		#browser();

		result[i,] = list(id = cur_id, nobs = sum(complete.cases(d)) );
	}

	# Return the result
	return(result);
} 
