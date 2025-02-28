# Import data from PropData_bin10.csv and call it 'data'

#table(data$SubID)
#plot(ecdf(data$Prop))
attach(data)
install.packages("lmerTest")
install.packages("multcomp")
library(dplyr)
library(tidyr)
library(Matrix)
library(lme4)
library(multcomp)
library(car)
library(lmerTest)

# Since the measurements have a temporal dimension, we use a 
# linear mixed model to analyze the proportion of fixation on the Target 
# over time and compare the blocks.

################################################### OBJECTIVE 1

# Fit the linear mixed model
modelo <- lmer(Prop ~ Agent * Language * trial_type + (1 | SubID) + (1 | Item) + Time, data = data)

# Get the model summary
resumen_modelo <- summary(modelo)

# Print the results
print(resumen_modelo)


################################################### OBJECTIVE 3
#####################################

############################################
# Model for the fixation rate on the target over time
############################################ 
install.packages("BayesFactor")
library(BayesFactor)
library(lme4)
library(broom.mixed)
library(dplyr)

# Filter the data to use positive times
data_filtered <- data %>%
  filter(Time > 0 & Time <= 1200)

# Create the fixation rate per unit of time
data_filtered <- data_filtered %>%
  mutate(Prop_Time_Ratio = ifelse(Time > 0, Prop / Time, NA))

# Apply z-score standardization to reduce the number of zeros
data_filtered <- data_filtered %>%
  mutate(Prop_T.R_z = scale(Prop_Time_Ratio))

# Fit the mixed model
model2 <- lmer(Prop_T.R_z ~ Agent * Language * InterestArea + (1 | SubID) + (1 | Item), data = data_filtered)
summary(model2)

# Extract predicted values and residuals
augmented_results <- augment(model2)

# Define the number of repetitions
n_reps <- 1000

# Initialize a list to store the results
results_list <- list()

# Groups to compare
grupos <- list(
  list("Group 1", "Human", "Hindi", "Target", "Robot", "Hindi", "Target"),
  list("Group 2", "Human", "English", "Target", "Robot", "English", "Target"),
  list("Group 3", "Human", "English", "Distractor", "Robot", "English", "Distractor"),
  list("Group 4", "Human", "Hindi", "Distractor", "Robot", "Hindi", "Distractor")
)

# Loop through the 4 groups
for (g in 1:length(grupos)) {
  # Extract information for the current group
  grupo_info <- grupos[[g]]
  grupo_nombre <- grupo_info[[1]]
  agent1 <- grupo_info[[2]]
  language1 <- grupo_info[[3]]
  interest1 <- grupo_info[[4]]
  agent2 <- grupo_info[[5]]
  language2 <- grupo_info[[6]]
  interest2 <- grupo_info[[7]]
  
  # Initialize vectors to store means and BF values for each repetition
  mean_values <- numeric(n_reps)
  bf_values <- numeric(n_reps)
  
  # Loop to repeat the process 1000 times
  for (i in 1:n_reps) {
    
    # Filter the relevant combinations for each group
    target_agent1 <- augmented_results %>% 
      filter(Agent == agent1, Language == language1, InterestArea == interest1)
    
    target_agent2 <- augmented_results %>% 
      filter(Agent == agent2, Language == language2, InterestArea == interest2)
    
    # Calculate the mean of the adjusted difference
    mean_values[i] <- mean(target_agent1$.fitted) - mean(target_agent2$.fitted)
    
    # Select a random sample of 80% of the data for each group
    sample_agent1 <- target_agent1 %>% sample_frac(0.8)
    sample_agent2 <- target_agent2 %>% sample_frac(0.8)
    
    # Extract the fitted values (.fitted)
    fitted_agent1 <- sample_agent1$.fitted
    fitted_agent2 <- sample_agent2$.fitted
    
    # Compute the Bayes Factor for the comparison between the two groups
    bf_result <- ttestBF(x = fitted_agent1, y = fitted_agent2)
    
    # Store the Bayes Factor value
    bf_values[i] <- bf_result@bayesFactor$bf
    
  }
  
  # Save the group's results in the list
  results_list[[grupo_nombre]] <- data.frame(
    Repetition = 1:n_reps,
    Mean_Difference = mean_values,
    BF_Value = bf_values
  )
  
}

# Create a table to store the averages for each group
summary_table <- data.frame(
  Group = character(),
  Mean_Difference = numeric(),
  Mean_BF = numeric()
)

# Compute the averages per group and add them to the table
for (grupo in names(results_list)) {
  group_data <- results_list[[grupo]]
  mean_diff <- mean(group_data$Mean_Difference)
  mean_bf <- mean(group_data$BF_Value)
  
  summary_table <- rbind(summary_table, data.frame(
    Group = grupo,
    Mean_Difference = mean_diff,
    Mean_BF = mean_bf
  ))
}

# Print the final results
print(summary_table)

# Interpretation of the Bayes Factor:
for (i in 1:nrow(summary_table)) {
  cat("Group:", summary_table$Group[i], "\n")
  if (summary_table$Mean_BF[i] > 1) {
    cat("There is more evidence in favor of the alternative hypothesis (difference between groups).\n")
  } else {
    cat("There is more evidence in favor of the null hypothesis (no significant difference between groups).\n")
  }
  cat("\n")
}


#### Interaction plot

install.packages(c("sjPlot","sjmisc","ggplot2"))
library(sjPlot)
library(sjmisc)
library(ggplot2)
theme_set(theme_sjplot())
plot_model(modelo, type = "pred", terms=c("Agent","Language"),data=data)
plot_model(modelo, type = "pred", terms=c("Agent","trial_type"),data=data)
