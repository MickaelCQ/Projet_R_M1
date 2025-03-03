#include <Rcpp.h>
#include "/home/mickael/Projets_GIT/Projet_R_M1/TakuzuRulesOld.cpp"  

using namespace Rcpp;

// [[Rcpp::export]]
IntegerMatrix generateTakuzuBoard() {
    generateValidBoard();  
    IntegerMatrix grid(SIZE, SIZE);
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            grid(i, j) = TrueGrid[i][j];
        }
    }
    return grid;
}

// [[Rcpp::export]]
IntegerMatrix getActualGrid() {
    IntegerMatrix grid(SIZE, SIZE);
    for (int i = 0; i < SIZE; i++) {
        for (int j = 0; j < SIZE; j++) {
            grid(i, j) = ActualGrid[i][j];
        }
    }
    return grid;
}

// [[Rcpp::export]]
void changeCellValue(int i, int j) {
    if (i >= 0 && i < SIZE && j >= 0 && j < SIZE) {
        ActualGrid[i][j] = (ActualGrid[i][j] == 0) ? 1 : 0; 
    }
}

