#include <iostream>
#include <math.h>

//size of the grid
#define SIZE 8 //need always pair
int grid[SIZE][SIZE];

// rules
bool isValidLine(int line){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
        if(grid[line][i] == 0){
            count0++;
        }else if(grid[line][i] == 1){
            count1++;
        }
    }
    return count0 == count1;
}

bool isValidCol(int col){
    int count0 = 0;
    int count1 = 0;
    for(int i = 0; i < SIZE; i++){
        if(grid[i][col] == 0){
            count0++;
        }else if(grid[i][col] == 1){
            count1++;
        }
    }
    return count0 == count1;
}

bool isValidBoard(){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            if(i > 1 && grid[i][j] == grid[i-1][j] && grid[i][j] == grid[i-2][j] && grid[i][j] != -1){
                return false;
            }
            if(j > 1 && grid[i][j] == grid[i][j-1] && grid[i][j] == grid[i][j-2] && grid[i][j] != -1){
                return false;
            }
        }
    }
    return true;
}

//need to check that never two columns are the same
bool isValid(){
    for(int i = 0; i < SIZE; i++){
        for(int j = i + 1; j < SIZE; j++){
            bool same = true;
            for(int k = 0; k < SIZE; k++){
                if(grid[k][i] != grid[k][j]){
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
                if(grid[i][k] != grid[j][k]){
                    same = false;
                    break;
                }
            }
            if(same){
                return false;
            }
        }
    }
    return isValidBoard();
}
//end rules



//generate valid grid
void generateValidBoard(){
    while(!isValid())
    {
        for(int i = 0; i < SIZE; i++){
            int count0 = 0;
            int count1 = 0;
            for(int j = 0; j < SIZE; j++){
                if(count0 < SIZE / 2 && count1 < SIZE / 2){
                    grid[i][j] = rand() % 2;
                } else if(count0 < SIZE / 2){
                    grid[i][j] = 0;
                } else {
                    grid[i][j] = 1;
                }
                if(grid[i][j] == 0){
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
            std::cout << grid[i][j] << " ";
        }
        std::cout << std::endl;
    }
    std::cout << std::endl;
    std::cout << "Board is valid: " << isValid() << std::endl;
}


void showBoard(){
    for(int i = 0; i < SIZE; i++){
        for(int j = 0; j < SIZE; j++){
            if(rand() % 3 == 0){ //change value for more difficulty
                std::cout << grid[i][j] << " ";
            } else {
                std::cout << "X ";
            }
        }
        std::cout << std::endl;
    }
}

int main(){
    srand(time(NULL));    //initialize random seed
    generateValidBoard();   //generate the valid grid
    showBoard();            //show the grid with hidden value
    return 0;
}

