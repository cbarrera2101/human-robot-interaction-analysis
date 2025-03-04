# human-robot-interaction-analysis

Data for this analysis can be downloaded from https://drive.google.com/file/d/11h_iw9fyVmnAk68wJTry60qR3GW08L35/view?usp=sharing

This R script analyzes eye-tracking fixation data using linear mixed models. The goal is to examine the proportion of fixation on a target over time while comparing different conditions

Data Import and Preparation:
- Loads the dataset (PropData_bin10.csv).
- Installs and loads necessary packages.
- Filters the data to include only positive time values.
- Computes a fixation rate per unit of time and applies z-score standardization.

Linear Mixed Model Analysis:
- Fits a mixed-effects model to analyze the effects of Agent, Language, and Trial Type on fixation proportion, accounting for Subject ID and Item as random effects.
- Extracts and prints model summaries.

Bayesian Hypothesis Testing:
- Compares fixation rates between different conditions using Bayesian t-tests.
- Runs 1000 iterations of sampling and computes Bayes Factors (BF) to assess the strength of evidence supporting differences between groups.

Visualization:
- Generates interaction plots to visualize model predictions for different conditions.

The script provides statistical insights into how fixation behavior varies across different experimental conditions and helps evaluate evidence for group differences using both frequentist and Bayesian approaches.
