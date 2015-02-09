rankall <- function(a_outcome, a_ranking = "best")
{
	# READ OUTCOME DATA

	# Check for the file existence
	filename = '.\\data\\outcome-of-care-measures.csv';
	if(!file.exists(filename)) {
		stop(paste0("Cannot find file <", filename, "> in current directory <", getwd(), ">"));
	}

	# Read the data from the file
	data = read.csv(filename, colClasses = "character");
	states = sort(unique(data$State));

	# VERIFY ARGUMENTS

	# 1. 'outcome' is a character vector of length 1 with the outcome of interest (from the list of
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

	# 2. 'ranking' is either of
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
	#	columns: 	State, Hospital Name and Outcome
	#	rows:		only data for the hospitals for which there is data for these columns
	data.sub <- data[data[name_col_outcome] != 'Not Available', c('State', 'Hospital.Name', name_col_outcome)];
	#data.sub <- data[data$State == state, c(2, ind_col_outcome)];
	names(data.sub) <- c('State', 'Name', 'Outcome');

	# Transform data in 'Outcome' column to be numeric
	data.sub$Outcome <- as.numeric(data.sub$Outcome);

	# Order the candidates by state, outcome and then by name
	data.sub <- data.sub[order(data.sub$State, data.sub$Outcome, data.sub$Name), ];

	# Add rank column per state and store result
	cnt_states = length(states);
	result <- data.frame(hospital = rep(NA, cnt_states), state = rep(NA, cnt_states) );

	for(i in seq_along(states)) {
		state = states[i];
		data.sub.state = data.sub[data.sub$State == state, ];

		data.sub.state$Rank = 1:length(data.sub.state$Name);

		# Find the result
		if( is_ranking_special ) {
			if		( ranking == 'best' ) { cur_result = data.sub.state$Name[1]; }
			else if( ranking == 'worst' ) { cur_result = data.sub.state$Name[ length(data.sub.state$Name) ]; }  
			else {
				stop(paste0('Unknown special ranking requested: ', ranking));
			}
		}
		else {
			# This will be NA if ranking is out of boundaries, as requested
			cur_result = data.sub.state$Name[ranking]; 
		}

		result$state[i] = state; 
		result$hospital[i] = cur_result; 
	}

	return(result);
}


