#include <iostream>
#include <math.h>

//size of the TrueGrid
#define SIZE 6 //need always pair
int TrueGrid[SIZE][SIZE];
int ActualGrid[SIZE][SIZE];

// rules
bool isValidLine(int line, int Grid[SIZE][SIZE]){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
        if(Grid[line][i] == 0){
            count0++;
        }else if(Grid[line][i] == 1){
            count1++;
        }
    }
    return count0 == count1;
}

bool isValidCol(int col,  int Grid[SIZE][SIZE]){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
        if(Grid[i][col] == 0){
            count0++;
        }else if(Grid[i][col] == 1){
            count1++;
        }
    }
    return count0 == count1;
}

bool isValidBoard( int Grid[SIZE][SIZE]){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            if(i > 1 && Grid[i][j] == Grid[i-1][j] && Grid[i][j] == Grid[i-2][j] && Grid[i][j] != -1){
                return false;
            }
            if(j > 1 && Grid[i][j] == Grid[i][j-1] && Grid[i][j] == Grid[i][j-2] && Grid[i][j] != -1){
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
                if(Grid[k][i] != Grid[k][j]){
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
                if(Grid[i][k] != Grid[j][k]){
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


// clone the board
void cloneBoard(int TrueGrid[SIZE][SIZE], int ActualGrid[SIZE][SIZE]){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            ActualGrid[i][j] = TrueGrid[i][j];
        }
    }
}

// remove value (to a 7) if the value here cannot be change (only one possibility of completiun) (but not working because next ca be also change so need to check taht latter)
void removeValue(int i, int j){
    int tmp = TrueGrid[i][j];
    int count = 0;
    for(int k = 0; k < 2; k++){
        TrueGrid[i][j] = k;
        if(isValidBoard(TrueGrid)){
            count++;
        }
    }
    std::cout << count << std::endl;
    TrueGrid[i][j] = tmp; // restore the original value
    if(count == 1){
        ActualGrid[i][j] = 7;
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

void changeValue(int iteration){
    if (iteration > SIZE * SIZE * SIZE)
    {
        std::cout << "you don't have luck bro" << std::endl;
        return;
    }

    int i = rand() % SIZE;
    int j = rand() % SIZE;
    if(ActualGrid[i][j] != 0 && ActualGrid[i][j] != 1){
        ActualGrid[i][j] = TrueGrid[i][j];
        return;
    }
    else
    {
        changeValue(iteration + 1);
    }
}



int main(){
    //srand(1);    //initialize notrandom seed
    srand(time(NULL));    //initialize random seed
    generateValidBoard();   //generate the valid TrueGrid
    //printBoard(TrueGrid);
    cloneBoard(TrueGrid, ActualGrid);
    for (int i = 0; i < SIZE; i++){
        for (int j = 0; j < SIZE; j++){
            removeValue(i, j);
        }
    }
    printBoard(ActualGrid);
    for (int i = 0; i < SIZE * 3; i++){ // Here change for the difficulty and the size of board // ex EZ : Size * 3, ex Hard : Size * 1
        changeValue(0); // also be used for help when player blocked
    }
    printBoard(ActualGrid);
    return 0;
}