dta <- read.table('Crop_recommendation.csv', sep = ';', header = TRUE, stringsAsFactors = TRUE)
summary(dta)

library (FactoMineR)

permuteLigne <- function(v) {return(v[sample(1:length(v),replace=FALSE)])}
quantile.inertie2 <- function(nbsimul, data){
  res <- NULL
  for (i in 1:nbsimul){
    data <- apply(data,2,permuteLigne)
    PCA <- PCA(data, graph=FALSE)
    pourcentage.inertie <- PCA$eig[2,3]
    res <- c(pourcentage.inertie)}
  quantile <- quantile(res,probs=0.95)
  return(quantile)
}

quantile.inertie2(1000, dta[,-8])
## Inertie totale = 30.1% pour données déstructurées

res_PCA <- PCA(dta[,-8], scale.unit = TRUE)
res_PCA$eig[2,3]
## Inertie totale = 46%

##########################################
## Classification des cultures avec CAH
##########################################

library(factoextra)

res_HCPC <- HCPC(res_PCA, nb.clust = 3) ## 3 clusters

dta$clust <- res_HCPC$data.clust$clust
table_clusters_label <- table(dta$label, dta$clust)
print(table_clusters_label)
## Cluster 1 = Banana, Coconut, Coffee, Cotton, Jute, Maize, Muskmelon, Orange, Papaya, Pomegranate, Rice, Watermelon
## Cluster 2 = Blackgram, Chickpea, Kidneybeans, Lentil, Mango, Mothbeans, Mungbean, Pigeonpeas
## Cluster 3 = Apple, Grapes

## Clusters très déséquilibrés

dta2 <- dta[,-8]
summary(dta2)
res_PCA <- PCA(dta2, scale.unit = TRUE, quali.sup = 8)

res_HCPC$desc.var$quanti$`1` ## Fruits tropicaux et cultures de rente : sol riche en N et pauvre en P, sol humide et précipitations plus importantes
res_HCPC$desc.var$quanti$`2` ## Légumineuses : sol peu humide, sol pauvre en N
res_HCPC$desc.var$quanti$`3` ## Fruits tempérés : sol riche K et P mais pauvre en N

resPCA2 <- PCA(dta[,-9], scale.unit = TRUE, quali.sup = 8)
plot(resPCA2,habillage=8,label="quali")

## Choix des cultures semblables
labels_to_filter <- c("banana", "lentil", "apple", "mango", "chickpea") ## Accuracy = 1
labels_to_filter <- c("maize", "papaya", "rice", "watermelon", "jute") ## Accuracy knn = 0.936 / Accuracy glm = 0.96
filtered_data <- dta[dta$label %in% labels_to_filter, 1:8]
filtered_data <- droplevels(filtered_data)
summary(filtered_data)

##########################################################
## Création des échantillons d'apprentissage et de test
##########################################################

require(class)
require(caret)
trainIndex <- createDataPartition(filtered_data$label, p = 0.75, list = FALSE)

data.train <- filtered_data[trainIndex, ]
data.test <- filtered_data[-trainIndex, ]

##########################################
## KNN 
##########################################

# Définir les contrôles de la validation croisée
ctrl <- trainControl(method = "cv", number = 10) # 10-fold cross-validation

# Définir la grille pour tester plusieurs valeurs de k
tuneGrid <- expand.grid(k = 1:20) # Tester les valeurs de k de 1 à 20

# Entraîner le modèle KNN avec la validation croisée
set.seed(123)  # Fixer une graine pour la reproductibilité
knn_model <- train(label ~ .,  # Spécifier la formule (variable à prédire et prédicteurs)
                   data = data.train, 
                   method = "knn", 
                   tuneGrid = tuneGrid, 
                   trControl = ctrl)

# Meilleur k trouvé
best_k <- knn_model$bestTune
print(best_k)

# Prédire avec le meilleur modèle
pred_knn <- predict(knn_model, newdata = data.test)

# Accuracy
conf_matrix <- confusionMatrix(pred_knn, data.test$label)
confusionMatrix(pred_knn, data.test$label)
accuracy <- conf_matrix$overall['Accuracy']
print(paste("Accuracy: ", accuracy))


res_ACP <- PCA(filtered_data, scale.unit = TRUE, quali.sup = 8)
plot(res_ACP,habillage=8,label="quali")

##########################################
## Régression logistique
##########################################

glm_model <- train(label ~ ., data = data.train, method = "multinom", trControl = ctrl)
pred_glm <- predict(glm_model, newdata = data.test)

# Accuracy
conf_matrix <- confusionMatrix(pred_glm, data.test$label)
confusionMatrix(pred_glm, data.test$label)
accuracy <- conf_matrix$overall['Accuracy']
print(paste("Accuracy: ", accuracy))

##########################################
## Random Forest 
##########################################


library(caret)

# Diviser les données en ensembles d'entraînement et de test
trainIndex <- createDataPartition(dta$label, p = 0.75, list = FALSE)
data.train <- dta[trainIndex, ]
data.test <- dta[-trainIndex, ]

# Configurer la validation croisée
ctrl <- trainControl(method = "cv", number = 10) # 10-fold cross-validation
tuneGrid <- expand.grid(k = 1:20)

# Entraîner le modèle KNN avec la validation croisée
set.seed(123)
knn_model <- train(label ~ .,
                   data = data.train, 
                   method = "knn", 
                   tuneGrid = tuneGrid, 
                   trControl = ctrl)

# Meilleur k trouvé
best_k <- knn_model$bestTune
print(paste("Best k found: ", best_k$k))

# Prédire avec le meilleur modèle sur l'ensemble de test complet
pred_knn <- predict(knn_model, newdata = data.test)

# Créer toutes les combinaisons possibles de 5 cultures
labels_to_test <- c("banana", "coconut", "coffee", "cotton", "jute", "maize", "muskmelon", "orange", "papaya", "pomegranate", "rice", "watermelon")
combinations <- combn(labels_to_test, 5, simplify = FALSE)

set.seed(123)
selected_combinations <- sample(combinations)

# Initialiser des vecteurs pour stocker les taux d'erreur
accuracy_knn <- numeric(length(selected_combinations))

# Boucle pour tester chaque combinaison
for (i in 1:length(selected_combinations)) {
  
  # Filtrer les données pour ne garder que les modalités de la combinaison courante
  selected_labels <- selected_combinations[[i]]
  filtered_test_data <- data.test[data.test$label %in% selected_labels, ]
  filtered_test_data <- droplevels(filtered_test_data)
  summary(filtered_test_data)

  # Prédiction avec le sous-ensemble de cultures
  pred_knn_filtered <- predict(knn_model, newdata = filtered_test_data)
    
  # S'assurer que les niveaux de facteur correspondent
  pred_knn_filtered <- factor(pred_knn_filtered, levels = levels(filtered_test_data$label))
    
  # Accuracy
  pred_knn_filtered <- factor(pred_knn_filtered, levels = levels(filtered_test_data$label))
  conf_matrix_filtered <- confusionMatrix(pred_knn_filtered, filtered_test_data$label)
  print(conf_matrix_filtered)
  accuracy_filtered[i] <- conf_matrix_filtered$overall['Accuracy']
}

# Trouver la combinaison avec le taux d'erreur le plus élevé (le modèle KNN le moins performant)
worst_combination_index_knn <- which.min(accuracy_filtered)
worst_combination_knn <- selected_combinations[worst_combination_index_knn]
worst_error_rate_knn <- accuracy_filtered[worst_combination_index_knn]
print(paste("Worst combination for KNN: ", paste(worst_combination_knn, collapse = ", ")))
print(paste("Worst accuracy for KNN: ", worst_error_rate_knn))

