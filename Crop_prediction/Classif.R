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
## Cluster 1 = Banana, Coconut, Coffee, Cotton, Jute, Maize, Muskmelon, Orange, Papaya, Pomegrade, Rice, Watermelon
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

## Choix des cultures semblables
labels_to_filter <- c("muskmelon", "watermelon", "jute", "rice")
labels_to_filter <- c("orange", "mungbean", "maize", "blackgram")
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

# Afficher les résultats
print(knn_model)

# Meilleur k trouvé
best_k <- knn_model$bestTune
print(best_k)

# Prédire avec le meilleur modèle
pred_knn <- predict(knn_model, newdata = data.test)

## Test

get.error <- function(class,pred){
  cont.tab <- table(class,pred)
  print(cont.tab)
  return((cont.tab[2,1]+cont.tab[1,2])/(sum(cont.tab)))
}

k.vec <- seq(20,1)

err.k <- rep(NA,times=length(k.vec))

for (i in 1:length(k.vec)){
  k <- k.vec[i]
  pred.train.knn <- knn(data.train[,-8],data.test[,-8],cl=data.train$label,k=k)
  err.k[i] <- get.error(data.test$label, pred.train.knn)
}

plot(k.vec,err.k,type="b")


pred_knn <- knn(train=data.train[,-8],test= data.test[,-8], cl=data.train$label, k = k)

cM.knn <- confusionMatrix(data = pred_knn, reference = data.test$label)
cM.knn$overall["Accuracy"]


PCA(filtered_data, scale.unit = TRUE, quali.sup = 8)

##########################################
## Random Forest 
##########################################

# Charger les packages nécessaires
library(class)
library(caret)

# Créer toutes les combinaisons possibles de 5 cultures
labels_to_test <- c("banana", "coconut", "coffee", "cotton", "jute", "maize", "muskmelon", 
                    "orange", "papaya", "pomegrade", "rice", "watermelon", "blackgram", 
                    "chickpea", "kidneybeans", "lentil", "mango", "mothbeans", "mungbean", 
                    "pigeonpeas", "apple", "grapes")

combinations <- combn(labels_to_test, 5, simplify = FALSE)

set.seed(123)
selected_combinations <- sample(combinations, 10)

# Initialiser un vecteur pour stocker les taux d'erreur
error_rates <- numeric(length(combinations))

# Fonction pour calculer le taux d'erreur
get.error <- function(class,pred){
  cont.tab <- table(class,pred)
  print(cont.tab)
  return((cont.tab[2,1]+cont.tab[1,2])/(sum(cont.tab)))
}

# Boucle pour tester chaque combinaison
for (i in 1:length(combinations)) {
  
  # Filtrer les données pour ne garder que les modalités de la combinaison courante
  selected_labels <- combinations[[i]]
  filtered_data <- dta[dta$label %in% selected_labels, ]
  filtered_data <- droplevels(filtered_data)
  filtered_data <- filtered_data[, -ncol(filtered_data)]
  
  # Créer des échantillons de train et test
  set.seed(123)  # Pour la reproductibilité
  trainIndex <- createDataPartition(filtered_data$label, p = 0.75, list = FALSE)
  data.train <- filtered_data[trainIndex, ]
  data.test <- filtered_data[-trainIndex, ]
  
  ctrl <- trainControl(method = "cv", number = 10)  # Validation croisée à 10 folds
  
  # Définir la grille pour tester plusieurs valeurs de k
  tuneGrid <- expand.grid(k = 1:20)  # Tester les valeurs de k de 1 à 20
  
  # Entraîner le modèle KNN avec la validation croisée pour optimiser k
  knn_model <- train(label ~ .,  # Spécifier la formule (variable à prédire et prédicteurs)
                     data = data.train, 
                     method = "knn", 
                     tuneGrid = tuneGrid, 
                     trControl = ctrl)
  
  # Meilleur k trouvé
  best_k <- knn_model$bestTune

  pred.knn <- knn(data.train[,-8], data.test[,-8], cl = data.train$label, k = best_k)
  
  # Calculer le taux d'erreur pour cette combinaison
  error_rates[i] <- get_error(data.test$label,pred.knn)
}

# Trouver la combinaison avec le taux d'erreur le plus élevé (le modèle le moins performant)
worst_combination_index <- which.max(error_rates)
worst_combination <- combinations[[worst_combination_index]]
worst_error_rate <- error_rates[worst_combination_index]

# Afficher la combinaison la moins performante et son taux d'erreur
print(paste("Worst combination: ", paste(worst_combination, collapse = ", ")))
print(paste("Worst error rate: ", worst_error_rate))

