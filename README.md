<a id="readme-top"></a>

<!-- PROJECT LOGO -->

<a href="https://github.com/eliselon/MLAgriculture"> ![Logo](images/INSTITUT_AGRO_Rennes-Angers_CMJN_png.png) </a>

<h3 align="center">

**Le Machine Learning au service de l'agriculture de précision**

</h3>

<h3 align="center">

Contribution à la conférence

"One Health : Le Machine Learning pour la santé du monde"

du 24/10/2024

</h3>


<!-- TABLE DES MATIÈRES -->

<details>

<summary>Table des matières</summary>

<ol>

<li>

<a href="#description-du-projet">Description du projet</a>

<ul>

<li><a href="#resume">Résumé</a></li>

</ul>

</li>

<li><a href="#le-jeu-de-données">Le jeu de données</a></li>

<li><a href="#structure-des-fichiers-du-repository">Structure des fichiers du repository</a></li>

<li><a href="#contributrices">Contributrices</a></li>

<li><a href="#contact">Contact</a></li>

</ol>

</details>

<!-- Description du projet -->

## Description du projet

L'objectif principal est d'aider les agriculteurs à faire des choix éclairés en matière de cultures en fonction des caractéristiques physico-chimiques des sols.

### Résumé

D'ici 2050, la population mondiale atteindra 9,1 milliards d'habitants, entraînant une augmentation de 70 % des besoins alimentaires. Cette situation, combinée à la réduction des terres agricoles disponibles en raison de l'urbanisation rapide, nécessite des innovations majeures dans la gestion agricole. L’agriculture de précision, un domaine en plein essor, utilise les données et la technologie pour optimiser la production agricole, en intégrant la variabilité biophysique des sols dans le processus décisionnel.

Le travail proposé a été réalisé à partir d’un jeu de données collecté en Inde, un pays où 70 % de la population pratique l’agriculture, contribuant à environ 17 % du PIB national. Le jeu de données inclut 2200 observations réparties sur huit variables : six variables physico-chimiques des sols, une variable météorologique et une variable décrivant le type de culture adaptée. L’objectif est d’utiliser le machine learning pour prédire les cultures les plus adaptées en fonction des caractéristiques du sol et de l'environnement, optimisant ainsi l’usage des ressources agricoles.

Les méthodes de machine learning envisagées pour cette étude comprennent un modèle de régression, un modèle basé sur la similarité tel que les k-nearest neighbors (KNN), ainsi qu’un modèle d’ensemble comme les forêts aléatoires (random forests). Ces deux derniers modèles sont particulièrement efficaces pour améliorer la précision des prédictions, car ils intègrent et exploitent les interactions complexes entre les différentes variables explicatives. Dans un premier temps, les trois modèles seront optimisés à l'aide de techniques de sélection de variables, notamment la méthode stepwise et l'élimination récursive de variables (RFE). Cela permettra de déterminer les caractéristiques les plus influentes pour la prédiction des cultures. Par la suite, nous évaluerons l’accuracy des modèles complets et des modèles sélectionnés afin d’identifier celui qui offre la meilleure performance pour prédire la culture appropriée en fonction des caractéristiques du sol. En complément, une nouvelle série de prédictions sera réalisée sur un sous-ensemble de cultures similaires, sélectionnées à l’aide d’une classification ascendante hiérarchique. Cette étape vise à évaluer la capacité des modèles à différencier efficacement les cultures qui ont des besoins agronomiques proches. 

En termes de perspectives, l’application de ces méthodes pourrait être étendue à d’autres régions géographiques et cultures, permettant une gestion plus fine et durable des ressources agricoles. De plus, l'intégration de méthodes plus avancées comme le deep learning, avec les réseaux de neurones multi-couches (MLP), ouvre des perspectives intéressantes pour améliorer encore la précision des recommandations.

En termes de perspectives, l’application de ces méthodes pourrait être étendue à d’autres régions géographiques et cultures, permettant une gestion plus fine et durable des ressources agricoles. De plus, l'intégration de méthodes plus avancées comme le deep learning, avec les réseaux de neurones multi-couches (MLP), ouvre des perspectives intéressantes pour améliorer encore la précision des recommandations.

**Mots-clés** : agriculture de précision, prédiction des cultures, KNN, random forest, échantillonnage

<p align="right">

(<a href="#readme-top">back to top</a>)

</p>

<!-- LE JEU DE DONNES -->

## Le jeu de données

Le jeu de données utilisé pour ce projet provient de [source de données] (ajoute un lien vers la source). Il contient diverses informations agronomiques, telles que :

-   2200 individus

-   *Les cultures* : variable à 22 modalités

-   Description des sols : 7 variables quantitatives

1.  *Azote*

2.  *Phosphore*

3.  *Potassium*

4.  *Température*

5.  *Humidité*

6.  *pH*

7.  *Pluie*

<p align="right">

(<a href="#readme-top">back to top</a>)

</p>

<!-- STRUCTURE DES FICHIERS DU REPOSITORY -->

## Structure des fichiers du repository

README.md : Ce fichier, document expliquant le projet, ses objectifs et sa structure

diapo.pptx : Présentation PowerPoint du projet

Conference_abstract.docx : Résumé de cette contribution à la conférence

Crop_prediction/ : Dossier contenant les scripts liés aux prédictions de cultures et le jeu de données

-   Crop_recommendation.csv : Fichier CSV du jeu de données utilisé pour les prédictions de cultures

-   Crop_prediction.Rproj : Fichier de projet RStudio définissant l'environnement de travail pour les scripts R

-   Crop_prediction.Rmd : Script Markdown R pour la prédiction et l'analyse des données

-   Crop_prediction.html : Version HTML généré à partir de Crop_prediction.Rmd

-   random_forest.py : Script Python pour l'entraînement et l'évaluation du modèle Random Forest généré via Google Colab

-   Random_Forest.ipynb : Notebook Jupyter généré via Google Colab à partir de random_forest.py

images/ : Dossier contenant une image

.gitignore : Fichier indiquant à Git quels fichiers doivent être ignorés dans le contrôle de version

(Conseil : Ne pas oublier d'importer le fichier .csv sur google colab lors de l'importation du fichier .ipynb)

<p align="right">

(<a href="#readme-top">back to top</a>)

</p>

<!-- CONTRIBUTRICES -->

## Contributrices

<p align="right">

</p>

<a href="https://github.com/eliselon/MLAgriculture/graphs/contributors"> ![contrib.rocks image](https://contrib.rocks/image?repo=eliselon/MLAgriculture)

</a>

</p>

<!-- CONTACT -->

## Contact

Elise Lonchampt - elise.lonchampt\@agrocampus-ouest.fr

Emma Da Costa Silva - emma.dacostasilva\@agrocampus-ouest.fr

Maud Lesage - maud.lesage\@agrocampus-ouest.fr

<p align="right">

(<a href="#readme-top">back to top</a>)

</p>
