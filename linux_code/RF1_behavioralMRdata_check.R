# This code is used to verify 225 collected behavioral task and MR data (from in the scanner) for RF1.
# It looks at the raw behavioral task data from within the scanner (rf1-sra/stimuli) for each task, 
# and then checks if the MR data was pre-processed successfully 
# (rf1-sra-data/code/sublist_225.txt here, but other sublists can be input and dynamically read).
#
# File outputs of this code can be found in linux_code/output.
# 
# The "debug" df logs subjects with issues in their data, namely too many trials' worth of data for each task. 
# This type of error typically indicates that a subject had to have a certain task be re-run in the scanner
# (e.g., had to stop halfway through to go to the bathroom), or that there was a typo when inputting subject ID.
# Regardless, the REDCap for these subjects should be checked, and the .csv file amended to reflect the proper row counts:
# 
# Shared Reward (Card Guessing task) = 54 rows/trial
# Trust (Investment task) = 42 rows/trial
# Social Doors (Door/Peer Feedback task) = 80 rows/trial (40 trials, information encoded in 2 lines for each trial)
# Ultimatum Game, Receiver (Let's Make a Deal task) = 48 rows/trial
#
# The "discrepancy" df compares behavioral data to whatever sublist you input to check for
# subjects that either 1) have behavioral data but no MR data (most common) or 2) MR data but no behavioral data (uncommon).
# In the first case, both REDCap and sourcedata (on the Linux) should be checked to:
# 1) REDcap, see if there were any issues with that subject's scan/if there were tasks that were not collected (and that you should log as missing for your analyses)
# 2) Linux, see if the data exists in sourcedata and just didn't make it through the pre-processing pipeline to get into 
# In the second case, you should assess if: 
# 1) There are typos in the subject as they were input into the MR scanner computer (cross-check REDCap for scanner date, etc.) or
# 2) The subject was just not pushed to XNAT from the scanner computer (this should never happen!). 
#
# The bonus portion of the script generates .txt files for each task where subjects have responded to 75%+ of trials, 
# following the exclusionary criteria for most tasks. This .txt file output is good to go as your "master" behavioral data sublist, 
# but you will still need to cross-reference for any subjects that need debugging or discrepancies,
# and manually amend the list as needed to fit your exclusionary criteria.


library(readr)
library(dplyr)
library(tidyr)
library(rstudioapi)

# Set wd to script directory, set other dirs
script_dir <- dirname(rstudioapi::getSourceEditorContext()$path)
setwd(script_dir)
base_dir <- file.path(script_dir, "..", "..", "rf1-sra", "stimuli")
sublist_path <- file.path(script_dir, "..", "..", "rf1-sra-data", "code", "sublist_225.txt") # Basically only this line should change if everything else is set up properly

# Dynamically named sublist
var_name <- gsub("-", "_", tools::file_path_sans_ext(basename(sublist_path)))
assign(var_name, read_lines(sublist_path))
sublist_vec <- get(var_name)

# Function to count rows of data to assess for (in)complete data
count_rows <- function(path) {
  if (!file.exists(path)) return(0)
  tryCatch({
    nrow(read_tsv(path, show_col_types = FALSE))
  }, error = function(e) {
    tryCatch({
      nrow(read_csv(path, show_col_types = FALSE))
    }, error = function(e) 0)
  })
}

# Pull subject IDs, generate df of all subjects with behavioral data in /logs
valid_subj <- function(subj) grepl("^1[01][0-9]{3}$", subj)
all_data <- tibble(sub_id = character())

# Expected row counts
expected_counts <- list(
  sharedreward_run1 = 54, sharedreward_run2 = 54,
  trust_run0 = 42, trust_run1 = 42,
  ugr_run0 = 48, ugr_run1 = 48,
  doors_run1 = 80, socialdoors_run1 = 80)

# Function to get row counts per subject per task
get_task_data <- function(task_name, dir_name, run_nums, filename_fmt) {
  dat <- tibble()
  for (subj in list.dirs(dir_name, recursive = FALSE, full.names = FALSE)) {
    if (!valid_subj(subj)) next
    vals <- sapply(run_nums, function(run) {
      fpath <- file.path(dir_name, subj, sprintf(filename_fmt, subj, run))
      count_rows(fpath)
    })
    run_cols <- setNames(as.list(vals), paste0(task_name, "_run", run_nums))
    dat <- bind_rows(dat, tibble(sub_id = subj, !!!run_cols))
  }
  dat
}

# SharedReward
shared_data <- get_task_data("sharedreward", file.path(base_dir, "Scan-Card_Guessing_Game", "logs"), 1:2,
                             "sub-%s_task-sharedreward_run-%d_raw.csv")
all_data <- full_join(all_data, shared_data, by = "sub_id")

# Trust
trust_data <- get_task_data("trust", file.path(base_dir, "Scan-Investment_Game", "logs"), 0:1,
                            "sub-%s_task-trust_run-%d_raw.csv")
all_data <- full_join(all_data, trust_data, by = "sub_id")

# UGR
ugr_data <- get_task_data("ugr", file.path(base_dir, "Scan-Lets_Make_A_Deal", "logs"), 0:1,
                          "sub-%s_task-ultimatum_run-%d_raw.csv")
all_data <- full_join(all_data, ugr_data, by = "sub_id")

# Social Doors
doors_data <- tibble()
doors_dir <- file.path(base_dir, "Scan-Social_Doors", "data")
for (subj in list.dirs(doors_dir, recursive = FALSE, full.names = FALSE)) {
  if (!valid_subj(subj)) next
  subj_path <- file.path(doors_dir, subj)
  doors_rows <- count_rows(list.files(subj_path, pattern = "doors.*_events\\.tsv$", full.names = TRUE)[1])
  faces_rows <- count_rows(list.files(subj_path, pattern = "faces.*_events\\.tsv$", full.names = TRUE)[1])
  doors_data <- bind_rows(doors_data, tibble(sub_id = subj, doors_run1 = doors_rows, socialdoors_run1 = faces_rows))
}
all_data <- full_join(all_data, doors_data, by = "sub_id")

# Pivot to long format to evaluate row counts
long_data <- all_data |>
  pivot_longer(-sub_id, names_to = "task", values_to = "n_rows") |>
  mutate(expected = unlist(expected_counts[task]))

# Identify rows where there are more rows than expected, save log and debug the subjects as outlined above
debug <- long_data |>
  filter(!is.na(n_rows) & n_rows > expected) |>
  arrange(sub_id)
write_csv(debug, file.path(getwd(), "output", "debuglog_alltasks_behavioraldata.csv"))

# Check for discrepancies between behavioral and dynamically input MR sublist of choice from above, save df and note missing runs, etc. for your analyses
discrepancy_df <- tibble(
  sub_id = union(all_data$sub_id, sublist_vec),
  in_behavior = sub_id %in% all_data$sub_id,
  in_mrlist = sub_id %in% sublist_vec
) |>
  filter(in_behavior != in_mrlist) |>
  left_join(all_data, by = "sub_id")
write_csv(discrepancy_df, file.path("output", "discrepancy_behavioralMR_data.csv"))

# Bonus stuff
# Export sublists by task (has any data for any task)
for (task in unique(gsub("_run[01]", "", names(expected_counts)))) {
  sub_cols <- grep(paste0("^", task, "_run"), names(all_data), value = TRUE)
  df_task <- dplyr::select(all_data, all_of(c("sub_id", sub_cols)))
  ids <- df_task[rowSums(df_task[, -1] > 0, na.rm = TRUE) > 0, "sub_id", drop = TRUE]
  assign(paste0(task, "_data"), ids)
}

# Export sublists for valid data (i.e., replied to 75%+ of trials)
for (task in unique(gsub("_run[01]", "", names(expected_counts)))) {
  sub_cols <- grep(paste0("^", task, "_run"), names(all_data), value = TRUE)
  thresholds <- unlist(expected_counts[sub_cols])
  
  df_subset <- all_data[, sub_cols]
  valid_mask <- sweep(df_subset, 2, 0.75 * thresholds, FUN = ">=")
  valid_ids <- all_data[rowSums(valid_mask, na.rm = TRUE) > 0, ]$sub_id
  valid_ids <- sort(unique(valid_ids))
  
  var_outname <- paste0("valid_", task, "_data_", var_name)
  assign(var_outname, valid_ids)
  write_lines(valid_ids, file.path(getwd(), "output", paste0(var_outname, ".txt")))
}