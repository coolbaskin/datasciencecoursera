best <- function(a_state, a_outcome)
{
	# READ OUTCOME DATA

	# Check for the file existence
	filename = '.\\data\\outcome-of-care-measures.csv';
	if(!file.exists(filename)) {
		stop(paste0("Cannot find file <", filename, "> in current directory <", getwd(), ">"));
	}

	# Read the data from the file
	data = read.csv(filename, colClasses = "character");
	states = unique(data$State);

	# VERIFY ARGUMENTS

	# 1. 'state' is a character with the state name
	state = as.character(a_state);

	if(length(state) != 1) {
		#stop(paste0("state has a length > 1: length = ", length(a_state) ))
		stop("invalid state");
	}

	if(is.na(state)) {
		#stop(paste0("state cannot be coerced to a character vector: ", a_state))
		stop("invalid state");
	}

	if(!(state %in% states)) {
		# stop(paste0("state <", state, "> does not exist in the data"));
		stop("invalid state");
	}

	# 2. 'outcome' is a character vector of length 1 with the outcome of interest (from the list of
    # valid outcomes)	
	outcome = as.character(a_outcome);

	if(length(outcome) != 1) {
		#stop(paste0("outcome has a length > 1: length = ", length(a_outcome) ))
		stop("invalid outcome");
	}

	if(is.na(outcome)) {
		#stop(paste0("outcome cannot be coerced to a character vector: ", a_outcome))
		stop("invalid outcome");
	}

	if(!(outcome %in% c('heart attack', 'heart failure', 'pneumonia'))) {
		# stop(paste0("outcome <", outcome, "> does not exist in the data"));
		stop("invalid outcome");
	}
	
	# TRANSFORM THE DATA FOR THE SUBSEQUENT ANALYSIS

	# Select the right columns
	#	1. Hosptal name: 	Hospital.Name
	#	2. THe 30-day mortality rate for the specified outcome
	# 	The right columns in the data will be of the following format
	# 		Hospital.30.Day.Death..Mortality..Rates.from.<%Outcome%>
	# 	where <%Outcome%> is the actual outcome with each word capitalized and spaces replaced with "."
	#   We will search for the string ignoring the case, so we will not capitalize the first letters of the 
	#	words in the outcome, but we will replace space with "\." for subsequent use in grep
	search_str_outcome = paste0(
		"^",
		"Hospital\\.30\\.Day\\.Death\\.\\.Mortality\\.\\.Rates\\.from.", 
		gsub('\\s', '\\.', outcome),
		"$"
	);

	# Search for the column name we need ignoring the case and returning the name itself (not the index)
	name_col_outcome = grep(search_str_outcome, names(data), value = TRUE, ignore.case = TRUE);
	#ind_col_outcome = grep(search_str_outcome, names(data), ignore.case = TRUE);

	# Subset the data to the only data we need
	#	columns: 	Hospital Name and Outcome
	#	rows:		only data for the specified state for which there is data
	data.sub <- data[data$State == state & data[name_col_outcome] != 'Not Available', c('Hospital.Name', name_col_outcome)];
	#data.sub <- data[data$State == state, c(2, ind_col_outcome)];
	names(data.sub) <- c('Name', 'Outcome');

	# Transform data in 'Outcome' column to be numeric
	data.sub$Outcome <- as.numeric(data.sub$Outcome);

	# Find the maximum result
	min.outcome <- min(data.sub$Outcome);

	# Get the names of the hospital(s) corresponding to the max result
	result.candidates <- data.sub$Name[data.sub$Outcome == min.outcome];

	# Order the candidates by name
	result.candidates <- result.candidates[order(result.candidates)];

	# Return the result
	result <- result.candidates[1];

	return(result);
}
