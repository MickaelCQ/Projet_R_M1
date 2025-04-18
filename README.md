# README pour le jeu Takuzu² LM

## Contexte du projet
### En français :
**Takuzu² LM** est un projet pédagogique entre Mickaël et Loïk, étudiants en Master Bioinformatique sous la direction du Professeur JM Marin. Nous sommes très heureux de vous présenter cette version 1.0.0  de notre jeu Takuzu, un casse-tete logique où il faudra emplir une grille avec des valeurs binaires {0,1} en s'assurant de respecter un certains nombres de  regles de parité et de symétrie .

L'objectif pédagogique de ce jeu étant d'exploiter et de mettre en oeuvre les différents concepts étudiés en cours tels que R, Shiny et Rcpp, l'encapsulation, les environnements dans R studio et bien d'autres ! La logique de vérification de la grille est gérer en C++ (Rcpp ) et nous vous proposon une interface intuitive et agréable via Shiny.

Nous espérons que vous apprécierez jouer à notre jeu !


### In English:
**Takuzu² LM** is an educational project between Mickaël and Loïk, Master's students in Bioinformatics under the supervision of Professor JM Marin. We are very excited to present version 1.0.0 of our Takuzu game, a logic puzzle where you must fill a grid with binary values {0,1} while ensuring compliance with several parity and symmetry rules.

The educational goal of this game is to explore and implement various concepts studied in class, such as R, Shiny, and Rcpp, encapsulation, environments in R Studio, and many more! The grid verification logic is handled in C++ (Rcpp), and we offer you an intuitive and enjoyable interface via Shiny.

We hope you enjoy playing our game!

## Fonctionnement du jeu


```bash
Rscript -e "shiny::runApp('Takuzulm.R')"
