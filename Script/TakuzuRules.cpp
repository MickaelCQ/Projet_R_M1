#include <iostream>

#include <math.h>

#include <Rcpp.h> // To interface with our R program;
using namespace Rcpp;
 
//size of the grid
#define SIZE 8 //need always pair

//int grid[SIZE][SIZE];

NumericMatrix grid(SIZE, SIZE); // Utilisable directement dans R
// https://cran.r-project.org/web/packages/Rcpp/vignettes/Rcpp-quickref.pdf
// [[Rcpp::export]]
void change_val(int i, int j){
   if (i >= 0 && i < grid.nrow() && 
       j >= 0 && j < grid.ncol()){ // Vérifie que i et j tombent bien dans la matrice
       grid(i,j) = (grid(i,j) == 1) ? 0 : 1;  // Change la valuer par O si 1 sinon 1, (opérateur ternaire d'Alban)       
}
}



// Vérifier qu'on a bien nos comptes de zéros et uns égaux dans chaque ligne. (lignes équilibrées) 
bool isValidLine(int line, NumericMatrix &grid){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
        if(grid(line,i) == 0){  // [] > ()
            count0++;
        }else if(grid(line,i) == 1){  // [] > ()
            count1++;
        } 
    }
    return count0 == count1;
}

// Vérifier qu'on a bien nos comptes de zéros et uns égaux dans chaque ligne. (colonnes équilibrées) 
bool isValidCol(int col, NumericMatrix &grid){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
        if(grid(i,col) == 0){  // [] > ()
            count0++;
        }else if(grid(i,col) == 1){  // [] > ()
            count1++;
        }
    }
    return count0 == count1;
}

// Aucune colonne / ligne ne doit contenir trois éléments consécutifs identiques. 
bool isValidBoard(NumericMatrix &grid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            if(i > 1 && grid(i, j) == grid(i-1,j) && grid(i, j) == grid(i-2,j) && grid(i, j) != -1){ // [] > ()
            // le -1 peut merder avec les numericMatrix si ca plante faut qu'on mette : !NumericMatrix::is_na(grid(i, j))
                return false;
            } // end first if 
            if(j > 1 && grid(i, j) == grid(i,j-1) && grid(i, j) == grid(i,j-2) && grid(i, j) != -1){ // [] > ()
                return false;
            } // end second if 
        }// end second  loop
    }// end first loop
    return true;
}


//need to check that never two columns are the same

// Vérifie qu'aucune paire de colonnes ou de lignes identiques n'existe :

bool isValid(NumericMatrix &grid){
    // Vérification que deux colonnes ne sont pas identiques
    for(int i = 0; i < SIZE; i++){
        for(int j = i + 1; j < SIZE; j++){
            bool same = true;
            for(int k = 0; k < SIZE; k++){
                if(grid(k, i) != grid(k, j)){ // [] > ()
                    same = false;
                    break;
                }
            }
            if(same){
                return false;
            }
        }
    }
    
    // Vérification que deux lignes ne sont pas identiques
    for(int i = 0; i < SIZE; i++){
        for(int j = i + 1; j < SIZE; j++){
            bool same = true;
            for(int k = 0; k < SIZE; k++){
                if(grid(i, k) != grid(j, k)){ // [] > ()
                    same = false;
                    break;
                }
            }
            if(same){
                return false;
            }
        }
    }
    // Si aucune duplication de lignes/ colonnes  n'est détectée, on vérifie d'autres règles de validité
    return isValidBoard(grid);
} //end rules

//generate valid grid
/*void generateValidBoard(){
    while(!isValid())
    {
        for(int i = 0; i < SIZE; i++){
            int count0 = 0;
            int count1 = 0;
            for(int j = 0; j < SIZE; j++){
                if(count0 < SIZE / 2 && count1 < SIZE / 2){
                    grid(i, j) = rand() % 2;
                } else if(count0 < SIZE / 2){
                    grid(i, j) = 0;
                } else {
                    grid(i, j) = 1;
                }
                if(grid(i, j) == 0){
                    count0++;
                } else {
                    count1++;
                }
            }
        }
    } 

    std::cout << "Board generated" << std::endl;
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            std::cout << grid(i, j) << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
    std::cout << "Board is valid: " << isValid() << std::endl;
} */

//-----------------------------------------------------
// Génère une grille valide
// [[Rcpp::export]]
NumericMatrix generateValidBoard(){
    int tenta_max = 1000000; // On limite les tentatives à 10000
    int tenta = 0;
    // Regénère la grille tant qu'elle n'est pas valide
    while(!isValid(grid) && tenta < tenta_max){
        for(int i = 0; i < SIZE; i++){
            int count0 = 0, count1 = 0;
            for(int j = 0; j < SIZE; j++){
                if(count0 < SIZE / 2 && count1 < SIZE / 2)
                    grid(i, j) = rand() % 2;
                else if(count0 < SIZE / 2)
                    grid(i, j) = 0;
                else
                    grid(i, j) = 1;
                
                if(grid(i, j) == 0) count0++;
                else count1++;
            }
        }
        tenta++;

    }
    if (tenta == tenta_max) {
        Rcout << "Échec de génération de la grille après " << tenta_max << " tentatives." << std::endl;
    }
    else {
        Rcout << "Grille conforme générée avec succès après" << tenta << "tentatives." << std::endl;
    }
    return grid;
}


// generatePartialBoard ; 
// Génère une grille partiellement visible où environ 33% des cases conservent leur valeur originale de `full_grid` 
// (avec une chance de 1 sur 3), et les autres sont masquées avec la valeur -1.  Ce pourcentage de visibilité pourrait être ajusté pour changer notre difficulté de jeu (par exemple, 25% ou 50%).

NumericMatrix generatePartialBoard(NumericMatrix full_grid)
{ NumericMatrix partial_grid = clone(full_grid); //copie de la grille
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            partial_grid(i,j) = (rand() % 3 == 0) ? full_grid(i,j) : -1; // version ternaire
            
            //if(rand() % 3 == 0){ //change value for more difficulty
            //   grid(i, j) = grid(i, j);
            //} else {
              //  grid(i, j) = -1;
            //}
        }
    }
    return partial_grid;
}

// [[Rcpp::export]]
NumericMatrix getActualGrid() {
  return grid;
}

//int main(){
  //  srand(time(NULL));    //initialize random seed
  //  generateValidBoard();   //generate the valid grid
  //  showBoard();            //show the grid with hidden value
  //  return 0;
//}

