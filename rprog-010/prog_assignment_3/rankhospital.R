rankhospital <- function(a_state, a_outcome, a_ranking = "best")
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

	# 3. 'ranking' is either of
	#	a character vector with "best" or "worst" to return the first or last hosiptal, correpondingly
	#	a numeric vector of length 1 with the rank of interest
	ranking = a_ranking;
	# flag is true if ranking argument is a character prescribing to return either "best" or "worst" argument
	is_ranking_special = FALSE; 

	if(is.character(ranking)) {
		# Check if it is one of the "best" or "worst" special keywords. If so, set the is_ranking_special 
		# flag
		ranking = tolower(ranking);
		if(ranking %in% c('best', 'worst')) {
			is_ranking_special = TRUE;	
		}
	}

	# Try treating ranking as numeric if is_ranking_special flag is not set
	if( !is_ranking_special ) {
		ranking = as.numeric(ranking);

		if(is.na(ranking)) {
			stop(paste0("ranking cannot be coerced to a number: ", a_ranking))
		}

		if(ranking <= 0 ) {
			stop(paste0("ranking cannot be <= 0: ", a_ranking))
		}
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
	data.sub <- data[
		data$State == state & data[name_col_outcome] != 'Not Available'	# rows
		,c('Hospital.Name', name_col_outcome)							# columns
	];

	#data.sub <- data[data$State == state, c(2, ind_col_outcome)];

	# Assign friendly names
	names(data.sub) <- c('Name', 'Outcome');

	# Transform data in 'Outcome' column to be numeric (should be no NAs since we removed 'Not Available' 
	# values before
	data.sub$Outcome <- as.numeric(data.sub$Outcome);

	# Order the candidates by outcome and then by name
	data.sub <- data.sub[order(data.sub$Outcome, data.sub$Name), ];

	# Add rank column
	data.sub$Rank = 1:length(data.sub$Outcome);

	# Find the result
	if( is_ranking_special ) {
		if		( ranking == 'best' ) { result = data.sub$Name[1]; }
		else if( ranking == 'worst' ) { result = data.sub$Name[ length(data.sub$Name) ]; }  
		else {
			stop(paste0('Unknown special ranking requested: ', ranking));
		}
	}
	else {
		# This will be NA if ranking is out of boundaries, as requested
		result = data.sub$Name[ranking]; 
	}

	return(result);
}

