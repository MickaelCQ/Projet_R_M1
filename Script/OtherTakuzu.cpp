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

bool isValidNumber(vector<vector<int>>& Grid){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
      for(int j = 0; j < SIZE; j++){
          if(Grid[i][j] == 7)
          {
              return true;
          }
          if(Grid[i][j] == 0){
              count0++;
          }
          else if(Grid[i][j] == 1){
              count1++;
          }
      }
      if(count0 != count1)
        {
          return false;
        }
      else
      {
        count0 = 0;
        count1 = 0;
      }
    }
    
    for(int i = 0; i < SIZE; i++){
      for(int j = 0; j < SIZE; j++){
        if(Grid[j][i] == 7)
        {
          return true;
        }
        if(Grid[j][i] == 0){
          count0++;
        }
        else if(Grid[j][i] == 1){
          count1++;
        }
      }
      if(count0 != count1)
      {
        return false;
      }
      else
      {
        count0 = 0;
        count1 = 0;
      }
    }
    
    return true;
}

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


//generate valid TrueGrid
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

// clone the board
void cloneToHiddenBoard(vector<vector<int>> OldGrid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            HiddenGrid[i][j] = OldGrid[i][j];
        }
    }
}

void cloneActualBoard(vector<vector<int>> OldGrid){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            ActualGrid[i][j] = OldGrid[i][j];
        }
    }
}
// remove value (to a 7) if the value here cannot be change (only one possibility of completiun) (but not working because next ca be also change so need to check taht latter)
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


// [[Rcpp::export]]
void SetSize(int size)
{
    SIZE = size;
}

// [[Rcpp::export]]
int GetSize()
{
    return SIZE;
}

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

    for (int i = 0; i < SIZE * 1; i++){ // Here change for the difficulty and the size of board // ex EZ : Size * 3, ex Hard : Size * 1
        changeValue(HiddenGrid, 0); // also be used for help when player blocked
    }
    
    printBoard(HiddenGrid);
    printBoard(TrueGrid);
    cloneActualBoard(HiddenGrid);
    //printBoard(ActualGrid);

}

// [[Rcpp::export]]
int GetCaseValue(int i, int j)
{
    return ActualGrid[i][j];
}

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

int main(){
    return 0;
}
