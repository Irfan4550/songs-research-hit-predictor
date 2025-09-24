# =======================================================
# PROJECT:What Differentiates a Hit Song from a Super-Hit?(Statistical Analysis)
# AUTHOR: Irfan
# DATE: 2025-09-24
# GOAL: See if data can prove there's a formula for a mega-hit.
# =======================================================


# 1. INITIAL SETUP AND DATA GRAB


library(tidyverse)      
library(janitor)        
library(skimr)          
library(ggthemes)       
library(broom)          
library(rsample)        

# Loading the raw data and cleaning the column names 
songs <- read.csv("billboard_top_100_final.csv") %>%
  clean_names()

 #A quick peek to check the data types and structure
glimpse(songs)


# 2. DEFINING "SUPER-HIT" (Our Target Variable)


# Creating a simple binary rule: if a song scores high on Danceability Energy and Valence
# (Spotify's measures of upbeat positive party vibes) it's a "Super-Hit".
songs <- songs %>%
  mutate(
    hit_class = ifelse(danceability + energy + valence > 2, "Super-Hit", "Regular Hit"),
    # We turn this into a factor for the classification model
    hit_class = factor(hit_class, levels = c("Regular Hit", "Super-Hit"))
  )

# How many songs landed in each category?
table(songs$hit_class)


# 3. QUICK DATA CHECK (EDA)


# List of the main numeric features we're interested in
features <- c("danceability", "energy", "loudness", "speechiness",
              "acousticness", "duration_ms", "liveness", "valence", "tempo")

# Restructure the data to make plotting all features easier
songs_long <- songs %>%
  pivot_longer(cols = all_of(features), names_to = "feature", values_to = "value")

# Density plots: Does one group lean higher than the other?
ggplot(songs_long, aes(x = value, fill = hit_class)) +
  geom_density(alpha = 0.4) +
  facet_wrap(~feature, scales = "free") +
  labs(
    title = "Super-Hits vs Regular Hits: Audio Feature Distributions",
    subtitle = "Plots show how often each feature appears for the two hit classes.",
    fill = "Hit Class"
  ) +
  theme_fivethirtyeight() +
  scale_fill_manual(values = c("Regular Hit" = "#30a2da", "Super-Hit" = "#fc4f30"))

# Statistical Significance: Are the differences real or just random chance?
t_test_results <- map_df(features, function(feat) {
  t_out <- t.test(songs[[feat]] ~ songs$hit_class)
  tibble(
    feature = feat,
    # Calculate means for direct comparison
    mean_superhit = mean(songs %>% filter(hit_class == "Super-Hit") %>% pull(.data[[feat]]), na.rm = TRUE),
    mean_regular = mean(songs %>% filter(hit_class == "Regular Hit") %>% pull(.data[[feat]]), na.rm = TRUE),
    p_value = t_out$p.value
  )
}) %>%
  mutate(
    # Check if the p-value is below the standard 0.05 threshold
    significance = ifelse(p_value < 0.05, "Significant", "Not Significant")
  )

print(t_test_results)


# 4. PREDICTIVE MODELING (LOGISTIC REGRESSION)


# Splitting data to ensure we test the model on songs it hasn't seen yet
set.seed(123) # Lock in the random split for reproducibility
split <- initial_split(songs, prop = 0.7, strata = hit_class) # 70% for training
train_data <- training(split)
test_data  <- testing(split)

# Build the Logistic Regression Model
# We're asking which features predict the "Super-Hit" class (family=binomial)
model <- glm(hit_class ~ danceability + energy + loudness + valence + tempo,
             data = train_data, family = binomial)

summary(model)

# Odds Ratios: This is the easiest way to understand the model's impact.
# An OR > 1 means the feature increases the odds of being a Super-Hit.
coef_df <- tidy(model, exponentiate = TRUE, conf.int = TRUE) %>%
  filter(term != "(Intercept)")

# Visualize the Odds Ratios
ggplot(coef_df, aes(x = reorder(term, estimate), y = estimate)) +
  geom_point(size = 3, color = "#fc4f30") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2) +
  geom_hline(yintercept = 1, linetype = "dashed") +
  coord_flip() +
  labs(
    title = "Odds Ratios for Super-Hit Prediction",
    subtitle = "Features with odds ratios > 1 increase the likelihood of being a Super-Hit",
    y = "Odds Ratio", x = "Feature"
  ) +
  theme_fivethirtyeight()

# Model Evaluation on the Test Data

# 1. Predict class probabilities and assign the final class (threshold > 0.5)
test_data <- test_data %>%
  mutate(
    pred_prob = predict(model, newdata = test_data, type = "response"),
    pred_class = ifelse(pred_prob > 0.5, "Super-Hit", "Regular Hit")
  )

# 2. Confusion Matrix (how many correct vs incorrect predictions)
cat("Confusion Matrix:\n")
table(Predicted = test_data$pred_class, Actual = test_data$hit_class)

# 3. Calculate Model Accuracy
accuracy <- mean(test_data$pred_class == test_data$hit_class)
cat("\nModel Accuracy:", round(accuracy, 3), "\n")


# 5. TREND ANALYSIS (Time Series)
# Group by year and find the average of the three main features
songs %>%
  group_by(year) %>%
  summarise(
    avg_dance = mean(danceability, na.rm = TRUE),
    avg_energy = mean(energy, na.rm = TRUE),
    avg_valence = mean(valence, na.rm = TRUE)
  ) %>%
  # Plot: Are pop songs getting more danceable energetic or positive over time?
  ggplot(aes(x = year)) +
  geom_line(aes(y = avg_dance, color = "Danceability")) +
  geom_line(aes(y = avg_energy, color = "Energy")) +
  geom_line(aes(y = avg_valence, color = "Valence")) +
  labs(
    title = "Trends in Hit Song Audio Features Over Time",
    subtitle = "Modern pop music appears more danceable and energetic.",
    y = "Average Feature Value (0-1)", x = "Year", color = "Feature"
  ) +
  theme_fivethirtyeight()

