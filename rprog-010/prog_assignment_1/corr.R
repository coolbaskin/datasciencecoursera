# Write a function that takes a directory of data files and a threshold for complete cases and calculates the
# correlation between sulfate and nitrate for monitor locations where the number of completely observed cases (on all
# variables) is greater than the threshold. The function should return a vector of correlations for the monitors that
# meet the threshold requirement. If no monitors meet the threshold requirement, then the function should return a
# numeric vector of length 0. A prototype of this function follows 
# 
# Example output
# > cr <-corr("specdata", 150)
# > head(cr)
# [1] -0.01895754 -0.14051254 -0.04389737 -0.06815956 -0.12350667 -0.07588814
# > summary(cr)
# Min. 1st Qu. Median Mean 3rd Qu. Max. 
# -0.21060 -0.04999 0.09463 0.12530 0.26840 0.76310 
# > cr <-corr("specdata", 400)
# > head(cr)
# [1] -0.01895754 -0.04389737 -0.06815956 -0.07588814 0.76312884 -0.15782860
# > summary(cr)
# Min. 1st Qu. Median Mean 3rd Qu. Max. 
# -0.17620 -0.03109 0.10020 0.13970 0.26850 0.76310 
# > cr <-corr("specdata", 5000)
# > summary(cr)
# Min. 1st Qu. Median Mean 3rd Qu. Max. 
# > length(cr)
# [1] 0
# > cr <-corr("specdata")
# > summary(cr)
# Min. 1st Qu. Median Mean 3rd Qu. Max. 
# -1.00000 -0.05282 0.10720 0.13680 0.27830 1.00000 
# > length(cr)
# [1]323

corr <- function(a_directory, a_threshold = 0) 
{
	# 'directory' is a character vector of length 1 indicating the location of the CSV files
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

	# 'threshold' is a numeric vector of length 1 indicating the number of completely observed observations (on all
	# variables) required to compute the correlation between nitrate and sulfate; the default is 0
	threshold = as.integer(a_threshold);

	if(length(threshold) != 1) {
		stop(paste0("threshold is not a vector of the length 1: length = ", length(a_threshold) ))
	}
	
	if(is.na(threshold)) {
		stop(paste0("threshold cannot be coerced to integer: ", a_threshold))
	}

	# Return a numeric vector of correlations

	# Collect results in a list, add elements dynamically as they match the threshold
	# 	list[[name]] = value 
	# acts as a hash map, so we'll use it as such. 'name' will be the ID of the detector that matches the threshold,
	# value will be a correlation
	result = list();

	# Here we'll hardcode the list of the IDs of the detectors, but in practice it should've been either passed to the
	# function, or deduced from the directory's contents
	ids = 1:332;
	for(i in ids) {
		d <- getmonitor(i, directory);	
		n_complete = sum(complete.cases(d));

		if( n_complete > threshold ) {
			result[[as.character(i)]] <- cor(d$sulfate, d$nitrate, use="complete.obs");	
		}
	}

	# Process the list to convert it to a vector
	result <- as.numeric(result);

	return(result);
}

