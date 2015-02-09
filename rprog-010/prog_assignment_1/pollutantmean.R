# Write a function named 'pollutantmean' that calculates the mean of a pollutant (sulfate or nitrate) across a specified
# list of monitors. The function 'pollutantmean' takes three arguments: 'directory', 'pollutant', and 'id'.  Given a
# vector monitor ID numbers, 'pollutantmean' reads that monitors' particulate matter data from the directory specified in
# the 'directory' argument and returns the mean of the pollutant across all of the monitors, ignoring any missing values
# coded as NA. 
# 
#     source("pollutantmean.R")
#     pollutantmean("specdata", "sulfate", 1:10)
#     ## [1] 4.064
#     pollutantmean("specdata", "nitrate", 70:72)
#     ## [1] 1.706
#     pollutantmean("specdata", "nitrate", 23)
#     ## [1] 1.281

pollutantmean <- function(a_directory, a_pollutant, a_id = 1:332) 
{
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

    # 'pollutant' is a character vector of length 1 indicating the name of the pollutant for which we will calculate the
    # mean; either "sulfate" or "nitrate".
	pollutant = as.character(a_pollutant);

	if(length(pollutant) != 1) {
		stop(paste0("pollutant has a length > 1: length = ", length(a_pollutant) ))
	}

	if(is.na(pollutant)) {
		stop(paste0("pollutant cannot be coerced to a character vector: ", a_pollutant))
	}

    # Convert to lower case for comparison and convenience
    pollutant = tolower(pollutant);

	if( !(pollutant %in% c('sulfate', 'nitrate') ) ) {
		stop(paste0("pollutant is not one of the two allowed values: 'sulfate' or 'nitrate'", a_pollutant))
	}

    # 'id' is an integer vector indicating the monitor ID numbers to be used
	id = as.integer(a_id);

	if( any(is.na(id))) {
		stop(paste0("not all ids can be coerced to integer or are NAs: ", a_id))
	}

    # Return the mean of the pollutant across all monitors list in the 'id' vector (ignoring NA values)
    total_sum <- 0;
    total_cnt <- 0;
    for(monitor_id in id)
    {
        # Get data for the current monitor
        cur_data <- getmonitor(monitor_id, directory);

        # Only get non-na entries for the specified pollutant
        cur_pollutant_data <- na.omit(cur_data[, pollutant]);

        # Store total sum and total length to get the average in the end
        total_sum <- total_sum + sum(cur_pollutant_data);
        total_cnt <- total_cnt + length(cur_pollutant_data);
    }

    pollutantmean <- total_sum/total_cnt;

    return(pollutantmean);

    # invisible(pollutantmean);
}
