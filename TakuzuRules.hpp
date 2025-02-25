#include <iostream>
#include <math.h>

class TakuzuRules
{


public:

    //size of the grid
    #define SIZE 6
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
                if(i > 1 && i < SIZE && grid[i][j] == grid[i-1][j] && grid[i][j] == grid[i+1][j] && grid[i][j] != -1){
                    return false;
                }
                if(j > 1 && i < SIZE && grid[i][j] == grid[i][j-1] && grid[i][j] == grid[i][j+1] && grid[i][j] != -1){
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

    //generate a grid and print it and also check if it is valid
    void generateBoard(){
        for(int i = 0; i < SIZE; i++){
            for(int j = 0; j < SIZE; j++){
                grid[i][j] = rand() % 2;
                std::cout << grid[i][j] << " ";
            }
            std::cout << std::endl;
        }
        std::cout << std::endl;
        std::cout << "Is valid: " << isValid() << std::endl;
    }

    int main(){
        srand(time(NULL));
        generateBoard();
        generateBoard();
        generateBoard();
        return 0;
    }

};