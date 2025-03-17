#include <iostream>
#include <math.h>


#include <Rcpp.h> // To interface with our R program;
using namespace Rcpp;

//size of the TrueGrid
#define SIZE 6 //need always pair
int TrueGrid[SIZE][SIZE];
int ActualGrid[SIZE][SIZE];
int HiddenGrid[SIZE][SIZE];



// rules
bool isValidLine(int line, int Grid[SIZE][SIZE]){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){

        if(Grid[line][i] == 7){
            return true;
        }
        if(Grid[line][i] == 0){
            count0++;
        }
        else if(Grid[line][i] == 1){
            count1++;
        }
    }
    return count0 == count1;
}

bool isValidCol(int col, int Grid[SIZE][SIZE]){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
        if(Grid[i][col] == 7)
        {
            return true;
        }
        if(Grid[i][col] == 0){
            count0++;
        }
        else if(Grid[i][col] == 1){
            count1++;
        }
    }
    return count0 == count1;
}

bool isValidBoard( int Grid[SIZE][SIZE]){
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

//need to check that never two columns are the same
bool isValid(int Grid[SIZE][SIZE]){
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



//generate valid TrueGrid
void generateValidBoard(){
    while(!isValid(TrueGrid) || !isValidLine(0, TrueGrid) || !isValidCol(0, TrueGrid))
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

    std::cout << "Board generated" << std::endl;
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            std::cout << TrueGrid[i][j] << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}


void clearGrid()
{
    for (int i = 0; i < SIZE; ++i) 
    {
        for (int j = 0; j < SIZE; ++j) 
        {
            TrueGrid[i][j] = -1;    
        }
    }    
}

// clone the board
void cloneBoard(int TrueGrid[SIZE][SIZE], int ActualGrid[SIZE][SIZE]){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            ActualGrid[i][j] = TrueGrid[i][j];
        }
    }
}

// remove value (to a 7) if the value here cannot be change (only one possibility of completiun) (but not working because next ca be also change so need to check taht latter)
void removeValue(int grid[SIZE][SIZE],int i, int j){
    int tmp = TrueGrid[i][j];
    int count = 0;
    for(int k = 0; k < 2; k++){
        TrueGrid[i][j] = k;
        if(isValid(TrueGrid)){
            count++;
        }

        if (grid[i-1][j] == 7 && grid[i-2][j] == 7 && grid[i][j-3] == 7)
        {
            count++;
        }



        if (grid[i][j-1] == 7 && grid[i][j-2] == 7 && grid[i][j-3] == 7)
        {
            count++;
        }

    }
    TrueGrid[i][j] = tmp; // restore the original value
    if(count == 1){
        grid[i][j] = 7;
    }
}

// print board enter in parameter of the void
void printBoard(int Grid[SIZE][SIZE]){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            std::cout << Grid[i][j] << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
}

void changeValue(int grid[SIZE][SIZE], int iteration){
    if (iteration > SIZE * SIZE * SIZE)
    {
        std::cout << "you don't have luck bro" << std::endl;
        return;
    }

    int i = rand() % SIZE;
    int j = rand() % SIZE;
    if(grid[i][j] != 0 && grid[i][j] != 1){
        grid[i][j] = TrueGrid[i][j];
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
    //printBoard(TrueGrid);
    cloneBoard(TrueGrid, HiddenGrid);
    for (int i = 0; i < SIZE; i++){
        for (int j = 0; j < SIZE; j++){
            removeValue(HiddenGrid, i, j);
        }
    }

    

    for (int i = 0; i < SIZE * 0; i++){ // Here change for the difficulty and the size of board // ex EZ : Size * 3, ex Hard : Size * 1
        changeValue(HiddenGrid, 0); // also be used for help when player blocked
    }


    cloneBoard(HiddenGrid, ActualGrid);
    printBoard(ActualGrid);
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
        else if(!isValidLine(i, ActualGrid) || !isValidCol(j, ActualGrid))
        {
            std::cerr << "pas les mêmes quantités de 0 et de 1 !" << std::endl;    
        }
        else if(!isValid(ActualGrid))
        {
            //not opti becase with check again validBoard
            std::cerr << "Deux collone ou ligne identique !" << std::endl;    
        }
        printBoard(ActualGrid);
    }
}



int main(){
    return 0;
}