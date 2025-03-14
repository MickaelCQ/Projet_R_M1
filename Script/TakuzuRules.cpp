#include <iostream>
#include <math.h>

#include <Rcpp.h> // To interface with our R program;
using namespace Rcpp;

//size of the grid
#define SIZE 12 //need always pair

NumericMatrix grid(SIZE, SIZE);
NumericMatrix ActualGrid(SIZE, SIZE);
NumericMatrix HiddenGrid(SIZE, SIZE);


// https://cran.r-project.org/web/packages/Rcpp/vignettes/Rcpp-quickref.pdf
// [[Rcpp::export]]
NumericMatrix change_val(int i, int j) 
{
    if (i >= 0 && i < SIZE && j >= 0 && j < SIZE) {
        ActualGrid(i, j) = (ActualGrid(i, j) == 1) ? 0 : 1;
    }
    return clone(ActualGrid); 
}

// rules
bool isValidLine(int line, NumericMatrix &Grid){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
        if(Grid(line, i) == 0){
            count0++;
        }else if(Grid(line, i) == 1){
            count1++;
        }
    }
    return count0 == count1;
}

bool isValidCol(int col, NumericMatrix &Grid){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
        if(Grid(col, i) == 0){
            count0++;
        }else if(Grid(col, i) == 1){
            count1++;
        }
    }
    return count0 == count1;
}

bool isValidBoard(NumericMatrix &Grid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            if(i > 1 && Grid(i, j) == Grid(i-1, j) && Grid(i, j) == Grid(i-2, j) && Grid(i, j) != -1){
                return false;
            }
            if(j > 1 && Grid(i, j) == Grid(i, j-1) && Grid(i, j) == Grid(i, j-2) && Grid(i, j) != -1){
                return false;
            }
        }
    }
    return true;
}

bool isValiCase(NumericMatrix &Grid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            if(i > 1 && Grid(i, j) == Grid(i-1, j) && Grid(i, j) == Grid(i-2, j) && Grid(i, j) != -1){
                return false;
            }
            if(j > 1 && Grid(i, j) == Grid(i, j-1) && Grid(i, j) == Grid(i, j-2) && Grid(i, j) != -1){
                return false;
            }
        }
    }
    return true;
}


//need to check that never two columns are the same
bool isValid(NumericMatrix &Grid){
    for(int i = 0; i < SIZE; i++){
        for(int j = i + 1; j < SIZE; j++){
            bool same = true;
            for(int k = 0; k < SIZE; k++){
                if(Grid(k, i) != Grid(k, j)){
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
                if(Grid(i, k) != Grid(j, k)){
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


//-----------------------------------------------------
// Génère une grille valide
// [[Rcpp::export]]
NumericMatrix generateValidBoard(){
    while(!isValid(grid) || !isValidLine(0, grid) || !isValidCol(0, grid))
    {
        for(int i = 0; i < SIZE; i++){
            int count0 = 0;
            int count1 = 0;
            for(int j = 0; j < SIZE; j++){
                if(count0 < SIZE / 2 && count1 < SIZE / 2){
                    grid(i,j) = rand() % 2;
                    if (i > 1 && grid(i,j) == grid(i-1,j) && grid(i,j) == grid(i-2,j) && grid(i,j) != -1)
                    {
                        grid(i,j) = 1 - grid(i,j);
                    }
                    if (j > 1 && grid(i,j) == grid(i,j-1) && grid(i,j) == grid(i,j-2) && grid(i,j) != -1)
                    {
                        grid(i,j) = 1 - grid(i,j);
                    }
                    
                } else if(count0 < SIZE / 2){
                    grid(i,j) = 0;
                } else {
                    grid(i,j) = 1;
                }
                if(grid(i,j) == 0){
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
            std::cout << grid(i,j) << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;

    return grid;
}


// clone the board
void cloneBoard(NumericMatrix &PastGrid, NumericMatrix &NewGrid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            NewGrid(i,j) = PastGrid(i,j);
        }
    }
}


// remove value (to a 7) if the value here cannot be change (only one possibility of completiun) (but not working because next ca be also change so need to check taht latter)
// [[Rcpp::export]]
void removeValue(NumericMatrix &Grid, int i, int j){
  int tmp = grid(i,j);
  int count = 0;
  for(int k = 0; k < 2; k++){
    grid(i,j) = k;
    if(isValid(grid)){
      count++;
    }
    
    if (Grid(i-1, j) == 7 && Grid(i-2,j) == 7)
    {
      count++;
    }
    
    if (Grid(i, j-1) == 7 && Grid(i, j-2) == 7)
    {
      count++;
    }
    
  }
  grid(i,j) = tmp; // restore the original value
  if(count == 1){
    Grid(i, j) = 7;
  }
}


// [[Rcpp::export]]
NumericMatrix NewGrid()
{
    cloneBoard(grid, ActualGrid);
    for (int i = 0; i < SIZE; i++){
        for (int j = 0; j < SIZE; j++){
            removeValue(ActualGrid, i, j);
        }
    }
    
    return clone(ActualGrid);
}

// print board enter in parameter of the void
void printBoard(NumericMatrix &Grid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            if(Grid(i, j) == 1)
            {
                std::cout << "X ";
            }
            else if(Grid(i, j) == 0)
            {
                std::cout << "O ";
            }
            else
            {

                std::cout << "  ";
            }
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

void changeValue(NumericMatrix &Grid,int iteration){
    if (iteration > SIZE * SIZE * SIZE * SIZE)
    {
        std::cout << "you don't have luck bro" << std::endl;
        return;
    }

    int i = rand() % SIZE;
    int j = rand() % SIZE;
    if(Grid(i, j) != 0 && Grid(i, j) != 1){
        Grid(i, j) = grid(i,j);
        return;
    }
    else
    {
        changeValue(Grid, iteration + 1);
    }
}

