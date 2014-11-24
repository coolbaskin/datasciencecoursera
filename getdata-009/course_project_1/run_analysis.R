library(plyr);

########################################################################################################################
## SETTINGS
########################################################################################################################

DEBUG = TRUE;

dir_data = '.\\data';
do_add_dataset_factor = FALSE;

########################################################################################################################
## FUNCTIONS
########################################################################################################################

debug_print <- function(...)
{
    if(DEBUG) { print(paste0(...)); }
}

# Helper function to construct file names and check their existence
get_full_filename <- function(...)
{
    result = file.path(...); 

    if(!file.exists(result)) {
        stop(paste0("Cannot find file <", result, "> in directory <", getwd(), ">"));
    }

    return(result);
}

# Reads the dataset from the specified directory. Integrates the data from several files and rulebook
read.dataset <- function(a_dirname, a_activity_labels, a_feature_labels, a_ind_features_wanted = NA)
{
    # 1. Read subject ids
    filename_subjects = paste0('subject_', a_dirname, '.txt');
    filepath = get_full_filename(dir_data, a_dirname, filename_subjects);
    data.subjects <- readLines(filepath);
    debug_print('Read ', length(data.subjects), ' lines of information on subjects from <', filepath, '>');
    # Turn subjects into factor. We know there are totally 30, so we use 1:30 as levels
    data.subjects <- factor(data.subjects, levels = seq(1:30))

    # 2. Read activity ids
    filename_activity = paste0('y_', a_dirname, '.txt');
    filepath = get_full_filename(dir_data, a_dirname, filename_activity);
    data.activity <- readLines(filepath);
    debug_print('Read ', length(data.activity), ' lines of information on activity type from <', filepath, '>');

    # Join them with the activity labels for more useful data format

    # Note: join() is used instead of merge() since it preserves the order of the left dataframe 
    # as opposed to the merge() that does not preserve order
    data.activity <- join(data.frame(id = data.activity), a_activity_labels, by = 'id')

    # 2. Read the observations from the sensors
    debug_print('Reading observations from <', filepath, '>');
    filename_facts = paste0('X_', a_dirname, '.txt');
    filepath = get_full_filename(dir_data, a_dirname, filename_facts);
    # Note: use 'white space' as separator (DEFAULT) since some of the numbers are separated by one space while others
    # are separated by several, i.e.  there is no consistency
    data.facts <- read.table(filepath, as.is = TRUE);
    data.facts.dims = dim(data.facts);
    debug_print('Read ', data.facts.dims[1], ' x ', data.facts.dims[2], ' observations from <', filepath, '>');

    # If the a_indices_wanted is not NA, use it to only have sertain columns left
    feature_labels <- a_feature_labels;
    if( !all(is.na(a_ind_features_wanted)) ) {
        debug_print('Filtering out features using the pre-specified set');

        ind_features_wanted = as.integer(a_ind_features_wanted);
        if( any(is.na(ind_features_wanted)) ) {
            stop(paste0('Cannot coerce a_ind_features_wanted to a vector of integers'));
        } 

        feature_labels <- feature_labels[ind_features_wanted];
        data.facts <- data.facts[, ind_features_wanted]; 

        data.facts.dims = dim(data.facts);
        debug_print('After filtering there are ', data.facts.dims[1], ' x ', data.facts.dims[2], ' observations left');
    } 

    # Add feature names
    colnames(data.facts) <- feature_labels;

    # Add subjects and activities to observations
    # Note: since we want them to be first columns (for readability), use cbind
    data.facts <- cbind(subject = data.subjects, activity = data.activity$name, data.facts);
    # data.facts <- mutate(data.facts, subject = data.subjects, activity = data.activity$name)

    return(data.facts);
}

########################################################################################################################
## MAIN
########################################################################################################################

# Read activity labels
filename_activity_labels = paste0('activity_labels.txt');
filepath = get_full_filename(dir_data, filename_activity_labels);
activity_labels <- read.table(filepath, sep = ' ', as.is = TRUE, col.names = c('id', 'name'));

# Explicitly assign levels so they are in the same order as IDs
activity_labels$name =  factor(activity_labels$name, levels = activity_labels$name)


# Read features names
filename_features_labels = paste0('features.txt');
filepath = get_full_filename(dir_data, filename_features_labels);
feature_labels <- read.table(filepath, sep = ' ', as.is = TRUE, col.names = c('id', 'name'));

# Find mean and standard deviation measurements indices
indices_features_wanted <- grep('(std)|(mean)', feature_labels$name, ignore.case = TRUE, perl = TRUE);

# TODO: create feature names suitable for conventient column naming for the data frame with observations
# Note: nice to have, not really needed for this assignment

# Read the datasets for train and test
d1 <- read.dataset('train', activity_labels, feature_labels$name, indices_features_wanted);
d2 <- read.dataset('test', activity_labels, feature_labels$name, indices_features_wanted);

# Since the merged dataset is only needed to be aggregated as one, this factor variable is not used. In fact, it makes
# specifying the aggregation below significantly more cumbersome. But it is nice to have if the merged dataset is to be
# used for other work, so I am leaving it as a flag-controlled feature
if(do_add_dataset_factor) {
    # Label the frames as train and test
    d1$dataset = factor('train');
    d2$dataset = factor('test');

}

# Merge them together for one combined dataset
d <- rbind(d1, d2);

# Melt the dataset using 'subject' and 'activity' pivots, everything else as unpivoted observations
if(do_add_dataset_factor) {
    # Here we'll need to explicitly exclude the column name for the dataset
    measure.vars <- colnames(d);
    ind_dataset_col <- which(measure.vars == 'dataset');

    # Exclude dataset, subject and activity columns
    measure.vars <- measure.vars[-c(1,2,ind_dataset_col)]; 

    d_melt <- melt(d, id.vars = c('subject', 'activity'), measure.vars = measure.vars);
} else {
    d_melt <- melt(d, id.vars = c('subject', 'activity'));
}

# Cast it back computing mean along the way. Basically, aggregation with a GROUP BY from SQL
d_avgs <- dcast(d_melt, subject+activity~variable, mean)

# Add 'avg_' prefixes to columns with averages
d_avgs.colnames = colnames(d_avgs);
d_avgs.colnames[-c(1,2)] = paste0('avg_', d_avgs.colnames[-c(1,2)]);
colnames(d_avgs) <- d_avgs.colnames;

# Output the result
print(d_avgs)

# Write to the file for submission
# write.table(d_avgs, "result.txt", row.name = FALSE)
