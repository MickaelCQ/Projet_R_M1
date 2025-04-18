# README pour le jeu Takuzu² LM

## Contexte du projet
### En français :
**Takuzu² LM** est un projet pédagogique entre Mickaël et Loïk, étudiants en Master Bioinformatique sous la direction du Professeur JM Marin. Nous sommes très heureux de vous présenter cette version 1.0.0  de notre jeu Takuzu, un casse-tete logique où il faudra emplir une grille avec des valeurs binaires {0,1} en s'assurant de respecter un certains nombres de  regles de parité et de symétrie .

L'objectif pédagogique de ce jeu étant d'exploiter et de mettre en oeuvre les différents concepts étudiés en cours tels que Shiny et Rcpp, l'encapsulation, les environnements dans R studio et bien d'autres ! La logique de vérification de la grille est gérer en C++ (Rcpp ) et nous vous proposon une interface intuitive et agréable via Shiny.

Nous espérons que vous apprécierez jouer à notre jeu !


### In English:
**Takuzu² LM** is an educational project between Mickaël and Loïk, Master's students in Bioinformatics under the supervision of Professor JM Marin. We are very excited to present version 1.0.0 of our Takuzu game, a logic puzzle where you must fill a grid with binary values {0,1} while ensuring compliance with several parity and symmetry rules.

The educational goal of this game is to explore and implement various concepts studied in class, such as R, Shiny, and Rcpp, encapsulation, environments in R Studio, and many more! The grid verification logic is handled in C++ (Rcpp), and we offer you an intuitive and enjoyable interface via Shiny.

We hope you enjoy playing our game!

## Fonctionnement du jeu

### En français :
Le but du jeu est simple : remplir une grille de zéros et de uns tout en respectant les règles suivantes :

1. Chaque ligne et chaque colonne doit contenir un nombre égal de 0 et de 1.
2. Aucune ligne ne peut être identique à une autre.
3. Chaque case de la grille peut être modifiée en cliquant dessus. Vous pouvez également demander un "coup de main" pour vous aider à avancer.
4. Vous gagnez lorsque toutes les règles sont respectées.

### In English:
The goal of the game is simple: fill a grid with zeros and ones while adhering to the following rules:

1. Each row and each column must contain an equal number of 0s and 1s.
2. No row can be identical to another.
3. Each cell of the grid can be changed by clicking on it. You can also request a "help" if you get stuck.
4. You win when all rules are followed correctly.

## Choix de paramétrage

### En français :
Au début de chaque partie, vous choisissez la taille de la grille. Voici les options disponibles :

- **Facile 6x6** : Pour les débutants ou ceux qui souhaitent une expérience rapide.
- **Moyen 8x8** : Pour les joueurs un peu plus expérimentés.
- **Expert 10x10** : Pour ceux qui cherchent un défi de taille.
- **Impossible 14x14** : Pour les experts du Takuzu prêts à affronter une grille très grande.

### In English:
At the beginning of each game, you choose the size of the grid. Here are the available options:

- **Easy 6x6**: For beginners or those looking for a quick experience.
- **Medium 8x8**: For players with a bit more experience.
- **Expert 10x10**: For those seeking a challenging puzzle.
- **Impossible 14x14**: For Takuzu experts ready to take on a very large grid.

## Stratégie générale

### En français :
La stratégie dans Takuzu repose sur la réflexion logique. Voici quelques astuces pour vous aider à progresser :

1. **Recherchez les cases déjà remplies** : Les cases pré-remplies peuvent vous aider à déduire les valeurs des autres cases.
2. **Soyez attentif à l'équilibre** : Assurez-vous qu'il y ait toujours un nombre égal de 0 et de 1 sur chaque ligne et chaque colonne.
3. **Ne laissez pas deux lignes ou colonnes identiques** : Cela peut rapidement être un piège dans les niveaux plus difficiles.

### In English:
The strategy in Takuzu relies on logical thinking. Here are some tips to help you progress:

1. **Look for pre-filled cells**: The pre-filled cells can help you deduce the values of other cells.
2. **Pay attention to balance**: Make sure there is always an equal number of 0s and 1s in each row and column.
3. **Avoid identical rows or columns**: This can quickly become a trap in the harder levels.

## Lancer le jeu

### En français :
Pour jouer à ce jeu Takuzu, suivez les étapes ci-dessous :

1. Clonez ou téléchargez le repository.
2. Installez les dépendances nécessaires, notamment **R**, **Shiny** et **Rcpp**.
3. Chargez votre fichier `Takuzulm.R` dans R.
4. Exécutez le script pour lancer l'application Shiny et commencez à jouer !

### In English:
To play this Takuzu game, follow these steps:

1. Clone or download the repository.
2. Install the necessary dependencies, including **R**, **Shiny**, and **Rcpp**.
3. Load the `Takuzulm.R` script in R.
4. Run the script to launch the Shiny app and start playing!
## Commande d'exécution (en bash)

### En français :
Si vous souhaitez exécuter le jeu directement depuis le terminal, vous pouvez utiliser la commande suivante :
## Commande d'exécution (en bash)

### En français :
Si vous souhaitez exécuter le jeu directement depuis le terminal, vous pouvez utiliser la commande suivante :

```bash
Rscript -e "shiny::runApp('Takuzulm.R')"

