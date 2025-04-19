#include <iostream>
#include <math.h>
#include <vector>

#include <Rcpp.h> // To interface with our R program;
using namespace Rcpp;
using namespace std;

//size of the TrueGrid
int SIZE = 8; //need always pair
vector<vector<int>> TrueGrid;
vector<vector<int>> ActualGrid;
vector<vector<int>> HiddenGrid;

// rules


/**
*@brief Cette fonction à pour objectif de vérifier pour chacune de nos lignes et colonnes que nous avons bien autant de cellules avec 0 qu'avec 1.
*@param une grille à vérifier : Grid
*@param 
*@warning Cette fonction peut entraîner un comportement imprévisible si la taille de la grille est incorrecte ou trop fréquemment générée

*@return True si nos règles de parités sont respectées, le cas échéant False.
*/
bool isValidNumber(const vector<vector<int>>& Grid) {
    for (int i = 0; i < SIZE; i++) {
        int count0Row = 0, count1Row = 0, count0Col = 0, count1Col = 0;
        for (int j = 0; j < SIZE; j++) {
            if (Grid[i][j] == 7 || Grid[j][i] == 7) return true;

            if (Grid[i][j] == 0) count0Row++;
            else if (Grid[i][j] == 1) count1Row++;

            if (Grid[j][i] == 0) count0Col++;
            else if (Grid[j][i] == 1) count1Col++;
        }
        if (count0Row != count1Row || count0Col != count1Col) return false;
    }
    return true;
}

/**
*@brief Cette fonction vérifie qu'aucune de nos lignes ou colonnes ne contiennent plus de deux valeurs identiques consécutives. 
*@param une grille à vérifier : Grid
*@param 
*@warning Cette fonction peut entraîner un comportement imprévisible si la taille de la grille est incorrecte ou trop fréquemment générée.

*@return True si nos règles de parités sont respectées, le cas échéant False.
*/


bool isValidBoard(const vector<vector<int>>& Grid)
{
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            if(i > 1 && Grid[i][j] == Grid[i-1][j] && Grid[i][j] == Grid[i-2][j] && Grid[i][j] != 7){
                return false;
            }
            if(j > 1 && Grid[i][j] == Grid[i][j-1] && Grid[i][j] == Grid[i][j-2] && Grid[i][j] != 7){
                return false;
            }
        }
    }
    return true;
}


/**
*@brief Cette fonction nous sert à comparer toutes les lignes et les colonnes les unes avec les autres, elle compulse les regles de similarité, de validité et d'alignement. 
*@param une grille à vérifier : Grid
*@warning Cette fonction peut entraîner un comportement imprévisible si la taille de la grille est incorrecte ou trop fréquemment générée.

*@return True si notre règle de validité est respectée,  le cas échéant False.
*/

bool isValid(const vector<vector<int>>& Grid) {
  for(int i = 0; i < SIZE; i++){
    for(int j = i + 1; j < SIZE; j++){
      bool same = true;
      for(int k = 0; k < SIZE; k++){
        if(Grid[k][i] == 7 || Grid[k][i] != Grid[k][j]){
          same = false;
          break;
        }
      }
      if(same){
        return false;
      }
    }
  }
  
  for(int i = 0; i < SIZE; i++){
    for(int j = i + 1; j < SIZE; j++){
      bool same = true;
      for(int k = 0; k < SIZE; k++){
        if(Grid[k][i] == 7 || Grid[i][k] != Grid[j][k]){
          same = false;
          break;
        }
      }
      if(same){
        return false;
      }
    }
  }
  return isValidBoard(Grid);
}
//end rules


/**
 * @brief Cette fonction à pour objectif de réinitialiser les trois grilles (TrueGrid, ActualGrid, HiddenGrid).
 */
 
void clearGrid()
{
  //dependant de size
 //creer les trois grilles et vide chaque case

  TrueGrid.clear();
      ActualGrid.clear();
      HiddenGrid.clear();


      TrueGrid.resize(SIZE);
      ActualGrid.resize(SIZE);
      HiddenGrid.resize(SIZE);
      for(int i = 0; i < SIZE; i++){
            TrueGrid[i].resize(SIZE);
            ActualGrid[i].resize(SIZE);
            HiddenGrid[i].resize(SIZE);
            for (int j = 0; j < SIZE; j++)
            {
                  TrueGrid[i][j] = 6;
            }
     }

}


/**
 * @brief Cette fonction est majeure elle génère une grille valide de manière aléatoire selon les règles de Takuzu, expressèments vérifiées plus haut.
 */
void generateValidBoard(){
    while(!isValid(TrueGrid) || !isValidNumber(TrueGrid))
    {
        for(int i = 0; i < SIZE; i++){
            int count0 = 0;
            int count1 = 0;
            for(int j = 0; j < SIZE; j++){
                if(count0 < SIZE / 2 && count1 < SIZE / 2){
                    TrueGrid[i][j] = rand() % 2;
                    if (i > 1 && TrueGrid[i][j] == TrueGrid[i-1][j] && TrueGrid[i][j] == TrueGrid[i-2][j] && TrueGrid[i][j] != 7)
                    {
                        TrueGrid[i][j] = 1 - TrueGrid[i][j];
                    }
                    if (j > 1 && TrueGrid[i][j] == TrueGrid[i][j-1] && TrueGrid[i][j] == TrueGrid[i][j-2] && TrueGrid[i][j] != 7)
                    {
                        TrueGrid[i][j] = 1 - TrueGrid[i][j];
                    }

                } else if(count0 < SIZE / 2){
                    TrueGrid[i][j] = 0;
                } else {
                    TrueGrid[i][j] = 1;
                }
                if(TrueGrid[i][j] == 0){
                    count0++;
                } else {
                    count1++;
                }
            }
        }
    } 

}

/**
 * @brief Copie une grille dans HiddenGrid.
 * @param OldGrid La grille source.
 */
void cloneToHiddenBoard(vector<vector<int>> OldGrid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            HiddenGrid[i][j] = OldGrid[i][j];
        }
    }
}


/**
 * @brief Copie une grille dans ActualGrid.
 * @param OldGrid La grille source.
 */
void cloneActualBoard(vector<vector<int>> OldGrid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            ActualGrid[i][j] = OldGrid[i][j];
        }
    }
}
// remove value (to a 7) if the value here cannot be change (only one possibility of completiun) (but not working because next ca be also change so need to check taht latter)

/**
 * @brief Remplace une valeur de la grille par 7 si elle est imposée et non ambigüe.
 * @param i Ligne
 * @param j Colonne
 */
void removeValue(int i, int j){

    if (HiddenGrid[i][j] != 7) {
        int tmp = TrueGrid[i][j];
        TrueGrid[i][j] = 0;
        bool valid0 = isValid(TrueGrid);
        TrueGrid[i][j] = 1;
        bool valid1 = isValid(TrueGrid);
        TrueGrid[i][j] = tmp;
        if (valid0 != valid1) HiddenGrid[i][j] = 7;
    }

}

/**
 * @brief Définit la taille de la grille utilisée dans le jeu. Cette fonction sera exploiter et appelé dans R via l'interface Shiny, pour changer dynamiquement la valeur de la grille dans l'interface. 
 * @param size La taille à utiliser.
 */
// [[Rcpp::export]]
void SetSize(int size)
{
    SIZE = size;
}

/**
 * @brief Récupère la taille actuelle de la grille.
 * @return La taille de la grille.
 */
 
// [[Rcpp::export]]
int GetSize()
{
    return SIZE;
}


/**
 * @brief Affiche la grille dans la console (debug).
 * @param Grid La grille à afficher.
 */
 
// print board enter in parameter of the void
void printBoard(vector<vector<int>>& Grid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            std::cout << Grid[i][j] << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

/**
 * @brief Remplit une case vide aléatoire avec sa valeur correcte issue de TrueGrid.
 * @param grid La grille à modifier.
 * @param iteration Limiteur de récursion.
 */
void changeValue(vector<vector<int>>& grid, int iteration){
    if (iteration > SIZE * SIZE * SIZE)
    {
        std::cout << "you don't have luck bro" << std::endl;
        return;
    }

    int i = rand() % SIZE;
    int j = rand() % SIZE;
    if(grid[i][j] != 0 && grid[i][j] != 1){
        grid[i][j] = TrueGrid[i][j];
      std::cout << "changed by : " << TrueGrid[i][j] << endl;
        return;
    }
    else
    {
        changeValue(grid, iteration + 1);
    }
}

/**
 * @brief Fonction principale de génération d'une nouvelle grille de Takuzu.
 */
 
// [[Rcpp::export]]
void mainGenerate()
{    
    clearGrid();
    //srand(1740728974);    //initialize notrandom seed
    //std::cout << "seed : " << time(NULL) << std::endl;
    srand(time(NULL));    //initialize random seed
    generateValidBoard();   //generate the valid TrueGrid
    cloneToHiddenBoard(TrueGrid);
    //printBoard(HiddenGrid);
    for (int i = 0; i < SIZE; i++){
        for (int j = 0; j < SIZE; j++){
            removeValue(i, j);
        }
    }

    for (int i = 0; i < SIZE * 1.5; i++){ // Here change for the difficulty and the size of board // ex EZ : Size * 3, ex Hard : Size * 1
        changeValue(HiddenGrid, 0); // also be used for help when player blocked
    }
    cloneActualBoard(HiddenGrid);
    //printBoard(ActualGrid);

}
/**
 * @brief Récupère la valeur d'une case dans la grille de jeu.
 * @param i Ligne
 * @param j Colonne
 * @return La valeur actuelle de la case
 */
 
// [[Rcpp::export]]
int GetCaseValue(int i, int j)
{
    return ActualGrid[i][j];
}


// [[Rcpp::export]]
int GetHiddenCaseValue(int i, int j)
{
    return HiddenGrid[i][j];
}

/**
 * @brief Change la valeur d'une cellule cliquée par l'utilisateur dans ActualGrid.
 *        Respecte les règles de modification (seulement les cases modifiables).
 * @param i Ligne
 * @param j Colonne
 */
 
// [[Rcpp::export]]
void PlayerChangeValue(int i, int j)
{
    if(HiddenGrid[i][j] == 7) // is valeur non fixé
    {
        if(ActualGrid[i][j] == 0) 
        {
        ActualGrid[i][j] = 1;
        }
        else if(ActualGrid[i][j] == 1)
        {
            ActualGrid[i][j] = 7;
        }
        else
        {
            ActualGrid[i][j] = 0;
        }

        if(!isValidBoard(ActualGrid))
        {
            std::cerr << "3 d'affilé !" << std::endl;
        }
        else if(!isValidNumber(ActualGrid))
        {
            std::cerr << "pas les mêmes quantités de 0 et de 1 !" << std::endl;    
        }
        else if(!isValid(ActualGrid))
        {
            //not opti becase with check again validBoard
            std::cerr << "Deux collone ou ligne identique !" << std::endl;    
        }
    }
}


// [[Rcpp::export]]
bool CheckVictory() {
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            if (ActualGrid[i][j] == 7) {
                return false;
            }
        }
    }

    return isValidNumber(ActualGrid) && isValidBoard(ActualGrid) && isValid(ActualGrid);
}


// [[Rcpp::export]]
Rcpp::List GetErrorCells() {
    Rcpp::List errors;

    // Erreurs 3 identiques d'affilée
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            if (i > 1 && ActualGrid[i][j] == ActualGrid[i - 1][j] && ActualGrid[i][j] == ActualGrid[i - 2][j] && ActualGrid[i][j] != 7) {
                errors.push_back(Rcpp::IntegerVector::create(i, j));
                errors.push_back(Rcpp::IntegerVector::create(i - 1, j));
                errors.push_back(Rcpp::IntegerVector::create(i - 2, j));
            }
            if (j > 1 && ActualGrid[i][j] == ActualGrid[i][j - 1] && ActualGrid[i][j] == ActualGrid[i][j - 2] && ActualGrid[i][j] != 7) {
                errors.push_back(Rcpp::IntegerVector::create(i, j));
                errors.push_back(Rcpp::IntegerVector::create(i, j - 1));
                errors.push_back(Rcpp::IntegerVector::create(i, j - 2));
            }
        }
    }

    // Erreurs de parité
    for (int i = 0; i < SIZE; i++) {
        int count0 = 0, count1 = 0, unknown = 0;
        for (int j = 0; j < SIZE; j++) {
            if (ActualGrid[i][j] == 0) count0++;
            else if (ActualGrid[i][j] == 1) count1++;
            else unknown++;
        }
        if (unknown == 0 && (count0 > SIZE / 2 || count1 > SIZE / 2)) {
            for (int j = 0; j < SIZE; j++) {
                errors.push_back(Rcpp::IntegerVector::create(i, j));
            }
        }
    }

    for (int j = 0; j < SIZE; j++) {
        int count0 = 0, count1 = 0, unknown = 0;
        for (int i = 0; i < SIZE; i++) {
            if (ActualGrid[i][j] == 0) count0++;
            else if (ActualGrid[i][j] == 1) count1++;
            else unknown++;
        }
        if (unknown == 0 && (count0 > SIZE / 2 || count1 > SIZE / 2)) {
            for (int i = 0; i < SIZE; i++) {
                errors.push_back(Rcpp::IntegerVector::create(i, j));
            }
        }
    }

    // Lignes ou colonnes identiques
    for (int i = 0; i < SIZE; i++) {
        for (int j = i + 1; j < SIZE; j++) {
            bool sameRow = true, sameCol = true;
            for (int k = 0; k < SIZE; k++) {
                if (ActualGrid[i][k] == 7 || ActualGrid[j][k] == 7) sameRow = false;
                if (ActualGrid[k][i] == 7 || ActualGrid[k][j] == 7) sameCol = false;
                if (ActualGrid[i][k] != ActualGrid[j][k]) sameRow = false;
                if (ActualGrid[k][i] != ActualGrid[k][j]) sameCol = false;
            }
            if (sameRow) {
                for (int k = 0; k < SIZE; k++) {
                    errors.push_back(Rcpp::IntegerVector::create(i, k));
                    errors.push_back(Rcpp::IntegerVector::create(j, k));
                }
            }
            if (sameCol) {
                for (int k = 0; k < SIZE; k++) {
                    errors.push_back(Rcpp::IntegerVector::create(k, i));
                    errors.push_back(Rcpp::IntegerVector::create(k, j));
                }
            }
        }
    }

    return errors;
}




/**
 * @brief Fonction qui va permettre en exploitant la fonction changeValue d'aider l'utilisateur en remplissant à la volée une cellule aléatoirement, l'utilisation de changeValue est pertinence ici car elle ne touche qu'aux cellules toujours . (on ne touche pas ç HiddenGrid comme cela pas de conflits possibles, et on peut aussi modifier la difficulté sans impacté son comportement.)
 */

//[[Rcpp::export]]
void HelpPlayer(int iteration)
{
    if (iteration > SIZE * SIZE * SIZE)
    {
        std::cout << "you don't have luck bro" << std::endl;
        return;
    }

    int i = rand() % SIZE;
    int j = rand() % SIZE;
    if(HiddenGrid[i][j] != 0 && HiddenGrid[i][j] != 1){
        HiddenGrid[i][j] = TrueGrid[i][j];
        ActualGrid[i][j] = TrueGrid[i][j];
        std::cout << "changed by : " << TrueGrid[i][j] << endl;
        return;
    }
    else
    {
        HelpPlayer(iteration + 1);
    }
}


/**
 * @brief Point d'entrée du programme .
 * @return 0
 */
int main(){
    return 0;
}
