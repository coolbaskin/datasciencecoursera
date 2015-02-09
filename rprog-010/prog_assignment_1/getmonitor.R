# Write a function named 'getmonitor' that takes three arguments: 'id', 'directory', and 'summarize'. Given a monitor ID
# number, 'getmonitor' reads that monitor's particulate matter data from the directory specified in the 'directory'
# argument and returns a data frame containing that monitor's data. If 'summarize = TRUE', then 'getmonitor' produces a
# summary of the data frame with the 'summary' function and prints it to the console. 

# > data <-getmonitor(1, "specdata")
# > head(data)
# Date sulfate nitrate ID
# 1 2003-01-01 NA NA 1
# 2 2003-01-02 NA NA 1
# 3 2003-01-03 NA NA 1
# 4 2003-01-04 NA NA 1
# 5 2003-01-05 NA NA 1
# 6 2003-01-06  NA NA 1

# > data <-getmonitor(101, "specdata", TRUE)
# Date sulfate nitrate ID 
# 2005-01-01: 1 Min. : 1.700 Min. : 0.2490 Min. :101 
# 2005-01-02: 1 1st Qu.: 3.062 1st Qu.: 0.6182 1st Qu.:101 
# 2005-01-03: 1 Median : 4.345 Median : 1.0500 Median :101 
# 2005-01-04: 1 Mean : 6.267 Mean : 2.2679 Mean :101 
# 2005-01-05: 1 3rd Qu.: 7.435 3rd Qu.: 2.7825 3rd Qu.:101 
# 2005-01-06: 1 Max. :22.100 Max. :10.8000 Max. :101 
# (Other) :724 NA's :666 NA's :666 
# > head(data)
# Date sulfate nitrate ID
# 1 2005-01-01 NA NA 101
# 2 2005-01-02 NA NA 101
# 3 2005-01-03 NA NA 101
# 4 2005-01-04 NA NA 101
# 5 2005-01-05 NA NA 101
# 6 2005-01-06 NA NA101

# > data <-getmonitor("200", "specdata", TRUE)
# Date sulfate nitrate ID 
# 2001-01-01: 1 Min. : 0.741 Min. : 0.144 Min. :200 
# 2001-01-02: 1 1st Qu.: 2.180 1st Qu.: 0.704 1st Qu.:200 
# 2001-01-03: 1 Median : 3.275 Median : 1.300 Median :200 
# 2001-01-04: 1 Mean : 4.391 Mean : 2.003 Mean :200 
# 2001-01-05: 1 3rd Qu.: 5.228 3rd Qu.: 2.605 3rd Qu.:200 
# 2001-01-06: 1 Max. :22.900 Max. :14.800 Max. :200 
# (Other) :3646 NA's :3192 NA's :3188    

getmonitor <- function(a_id, a_directory, a_summarize = FALSE) 
{
	## 'id' is a vector of length 1 indicating the monitor ID
	## number. The user can specify 'id' as either an integer, a
	## character, or a numeric.

	# SANITIZE
	# Coerce function argument to an integer
	id = as.integer(a_id);

	if(length(id) != 1) {
		stop(paste0("id is not a vector of the length 1: length = ", length(a_id) ))
	}
	
	if(is.na(id)) {
		stop(paste0("id cannot be coerced to integer: ", a_id))
	}

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

	# 'summarize' is a logical indicating whether a summary of ## the data should be printed to the console; 
	# the default is FALSE
	do_summarize = as.logical(a_summarize);

	if(is.na(do_summarize)) {
		stop(paste0("summarize cannot be coerced to a logical: ", a_summarize))
	}

	# EXECUTE

	# Construct the file name from id
	filename = file.path(directory, sprintf("%03i.csv", id));

	# Check for the file existence
	if(!file.exists(filename)) {
		stop(paste0("Cannot find file <", filename, "> corresponding to id <", id, "> in directory <", directory, ">"));
	}

	# Read the data from the file
	data = read.csv(filename);

	# Print the summary if asked
	if(do_summarize) {
		print(summary(data));
	}

	return(data);
}
