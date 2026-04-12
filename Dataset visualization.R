library(tidyverse)
library(ggplot2)
library(corrplot)
library(caret)
library(randomForest)
library(rpart)
library(rpart.plot)
library(pROC)

diabetes <- read.csv("diabetes.csv", stringsAsFactors = FALSE)

diabetes$Outcome <- factor(diabetes$Outcome, levels = c(0, 1),
                           labels = c("Non-Diabetic", "Diabetic"))

cat("===== DATASET OVERVIEW =====\n")
cat("Dimensions:", nrow(diabetes), "rows x", ncol(diabetes), "columns\n\n")

cat("--- First 6 Rows ---\n")
print(head(diabetes))

cat("\n--- Summary Statistics ---\n")
print(summary(diabetes))

cat("\n--- Missing Values per Column ---\n")
print(colSums(is.na(diabetes)))

cat("\n--- Outcome Distribution ---\n")
print(table(diabetes$Outcome))
cat("Proportion:\n")
print(prop.table(table(diabetes$Outcome)))

zero_cols <- c("Glucose", "BloodPressure", "SkinThickness", "Insulin", "BMI")
diabetes_clean <- diabetes
diabetes_clean[, zero_cols] <- lapply(diabetes_clean[, zero_cols],
                                      function(x) ifelse(x == 0, NA, x))

cat("\n--- Missing / Zero Values After Cleaning ---\n")
print(colSums(is.na(diabetes_clean)))

diabetes_clean <- diabetes_clean %>%
  mutate(across(all_of(zero_cols),
                ~ ifelse(is.na(.), median(., na.rm = TRUE), .)))

cat("\n--- Summary After Imputation ---\n")
print(summary(diabetes_clean))

ggplot(diabetes_clean, aes(x = Outcome, fill = Outcome)) +
  geom_bar(width = 0.5) +
  scale_fill_manual(values = c("#2ecc71", "#e74c3c")) +
  labs(title = "Diabetes Outcome Distribution",
       x = "Outcome", y = "Count") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("plot_outcome_distribution.png", width = 6, height = 4)

diabetes_clean %>%
  select(-Outcome) %>%
  gather(key = "Variable", value = "Value") %>%
  ggplot(aes(x = Value, fill = Variable)) +
  geom_histogram(bins = 25, color = "white", alpha = 0.8) +
  facet_wrap(~ Variable, scales = "free") +
  labs(title = "Distribution of All Features") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("plot_histograms.png", width = 10, height = 7)

diabetes_clean %>%
  gather(key = "Variable", value = "Value", -Outcome) %>%
  ggplot(aes(x = Outcome, y = Value, fill = Outcome)) +
  geom_boxplot(outlier.alpha = 0.4) +
  scale_fill_manual(values = c("#2ecc71", "#e74c3c")) +
  facet_wrap(~ Variable, scales = "free_y") +
  labs(title = "Feature Distributions by Outcome") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("plot_boxplots.png", width = 12, height = 8)

numeric_vars <- diabetes_clean %>% select(-Outcome)
cor_matrix <- cor(numeric_vars, use = "complete.obs")

png("plot_correlation.png", width = 700, height = 700)
corrplot(cor_matrix, method = "color", type = "upper",
         addCoef.col = "black", tl.col = "black",
         tl.srt = 45, title = "Correlation Matrix",
         mar = c(0, 0, 2, 0))
dev.off()

ggplot(diabetes_clean, aes(x = Glucose, y = BMI, color = Outcome)) +
  geom_point(alpha = 0.6, size = 2) +
  scale_color_manual(values = c("#2ecc71", "#e74c3c")) +
  labs(title = "Glucose vs BMI by Outcome",
       x = "Glucose", y = "BMI") +
  theme_minimal()

ggsave("plot_glucose_bmi.png", width = 7, height = 5)

set.seed(42)
train_index <- createDataPartition(diabetes_clean$Outcome, p = 0.75, list = FALSE)
train_data  <- diabetes_clean[train_index, ]
test_data   <- diabetes_clean[-train_index, ]

cat("\n===== TRAIN/TEST SPLIT =====\n")
cat("Training rows:", nrow(train_data), "\n")
cat("Testing rows: ", nrow(test_data),  "\n")


cat("\n===== LOGISTIC REGRESSION =====\n")

log_model <- glm(Outcome ~ ., data = train_data, family = binomial)
cat("\n--- Model Summary ---\n")
print(summary(log_model))

log_probs <- predict(log_model, newdata = test_data, type = "response")
log_preds <- factor(ifelse(log_probs > 0.5, "Diabetic", "Non-Diabetic"),
                    levels = c("Non-Diabetic", "Diabetic"))

cat("\n--- Confusion Matrix (Logistic Regression) ---\n")
print(confusionMatrix(log_preds, test_data$Outcome, positive = "Diabetic"))


roc_log <- roc(as.numeric(test_data$Outcome) - 1, log_probs)
png("plot_roc_logistic.png", width = 600, height = 500)
plot(roc_log, col = "#3498db", lwd = 2,
     main = paste("ROC Curve – Logistic Regression | AUC =",
                  round(auc(roc_log), 3)))
dev.off()
cat("\nLogistic Regression AUC:", round(auc(roc_log), 3), "\n")


cat("\n===== DECISION TREE =====\n")

tree_model <- rpart(Outcome ~ ., data = train_data, method = "class",
                    control = rpart.control(cp = 0.01, maxdepth = 5))

png("plot_decision_tree.png", width = 1000, height = 600)
rpart.plot(tree_model, type = 3, extra = 106,
           main = "Decision Tree – Diabetes Prediction")
dev.off()

tree_preds <- predict(tree_model, newdata = test_data, type = "class")

cat("\n--- Confusion Matrix (Decision Tree) ---\n")
print(confusionMatrix(tree_preds, test_data$Outcome, positive = "Diabetic"))


cat("\n===== RANDOM FOREST =====\n")

set.seed(42)
rf_model <- randomForest(Outcome ~ ., data = train_data,
                         ntree = 200, importance = TRUE)

cat("\n--- Random Forest Model ---\n")
print(rf_model)

rf_preds <- predict(rf_model, newdata = test_data)

cat("\n--- Confusion Matrix (Random Forest) ---\n")
print(confusionMatrix(rf_preds, test_data$Outcome, positive = "Diabetic"))

png("plot_variable_importance.png", width = 700, height = 500)
varImpPlot(rf_model, main = "Random Forest – Variable Importance")
dev.off()

rf_probs <- predict(rf_model, newdata = test_data, type = "prob")[, "Diabetic"]
roc_rf   <- roc(as.numeric(test_data$Outcome) - 1, rf_probs)
cat("\nRandom Forest AUC:", round(auc(roc_rf), 3), "\n")

cat("\n===== MODEL COMPARISON =====\n")

log_acc  <- confusionMatrix(log_preds,  test_data$Outcome)$overall["Accuracy"]
tree_acc <- confusionMatrix(tree_preds, test_data$Outcome)$overall["Accuracy"]
rf_acc   <- confusionMatrix(rf_preds,   test_data$Outcome)$overall["Accuracy"]

comparison <- data.frame(
  Model    = c("Logistic Regression", "Decision Tree", "Random Forest"),
  Accuracy = round(c(log_acc, tree_acc, rf_acc), 4),
  AUC      = round(c(auc(roc_log), NA, auc(roc_rf)), 4)
)
print(comparison)

ggplot(comparison, aes(x = Model, y = Accuracy, fill = Model)) +
  geom_bar(stat = "identity", width = 0.5) +
  scale_fill_manual(values = c("#3498db", "#f39c12", "#2ecc71")) +
  geom_text(aes(label = Accuracy), vjust = -0.5, fontface = "bold") +
  ylim(0, 1) +
  labs(title = "Model Accuracy Comparison", y = "Accuracy", x = "") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("plot_model_comparison.png", width = 7, height = 5)

cat("\n Alysis complete! All plots saved as PNG files.\n")
