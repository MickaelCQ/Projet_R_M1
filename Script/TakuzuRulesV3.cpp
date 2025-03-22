#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

#include <Rcpp.h>
using namespace Rcpp;

using namespace std;

int SIZE = 6;
vector<vector<int>> TrueGrid;
vector<vector<int>> ActualGrid;
vector<vector<int>> HiddenGrid;

void initializeGrids(int size) {
    SIZE = size;
    // Initialise les grilles avec des cases vides (valeur 6 pour les cases non remplies)
    TrueGrid.assign(SIZE, vector<int>(SIZE, 6));  
    ActualGrid.assign(SIZE, vector<int>(SIZE, 6));
    HiddenGrid.assign(SIZE, vector<int>(SIZE, 6));
}

void cloneToHiddenBoard(vector<vector<int>> &OldGrid) {
    HiddenGrid = OldGrid;
}

void cloneActualBoard(vector<vector<int>> &OldGrid) {
    ActualGrid = OldGrid;
}

bool isValid(const vector<vector<int>> &grid);
bool isValidLine(int line, const vector<vector<int>> &grid);
bool isValidCol(int col, const vector<vector<int>> &grid);

bool isValid(const vector<vector<int>> &grid) {
    // Vérifie si toutes les lignes et colonnes sont valides
    for (int i = 0; i < SIZE; i++) {
        if (!isValidLine(i, grid) || !isValidCol(i, grid)) {
            return false;
        }
    }
    return true;
}

bool isValidLine(int line, const vector<vector<int>> &grid) {
    // Vérifie si la ligne respecte les règles de Takuzu
    int count0 = 0, count1 = 0;
    for (int j = 0; j < SIZE; j++) {
        if (grid[line][j] == 0) count0++;
        if (grid[line][j] == 1) count1++;
        if (j >= 2 && grid[line][j] == grid[line][j-1] && grid[line][j] == grid[line][j-2]) {
            return false;
        }
    }
    return count0 == count1;
}

bool isValidCol(int col, const vector<vector<int>> &grid) {
    // Vérifie si la colonne respecte les règles de Takuzu
    int count0 = 0, count1 = 0;
    for (int i = 0; i < SIZE; i++) {
        if (grid[i][col] == 0) count0++;
        if (grid[i][col] == 1) count1++;
        if (i >= 2 && grid[i][col] == grid[i-1][col] && grid[i][col] == grid[i-2][col]) {
            return false;
        }
    }
    return count0 == count1;
}

void removeValue(int i, int j) {
    // Modifie la valeur d'une cellule dans la grille (ajuste le grid en fonction des règles)
    if (i < 2 || j < 2) return;
    int tmp = TrueGrid[i][j];
    int count = 0;

    for (int k = 0; k < 2; k++) {
        TrueGrid[i][j] = k;
        if (isValid(TrueGrid)) {
            count++;
        }
    }
    TrueGrid[i][j] = tmp;
    if (count == 1) {
        HiddenGrid[i][j] = 7;
    }
}

// [[Rcpp::export]]
void SetSize(int size) {
    initializeGrids(size);
}

// [[Rcpp::export]]
void generateValidBoard() {
    // La génération de la grille valide se fait ici (aléatoire, mais assure qu'elle respecte les règles)
    srand(time(0));
    int maxTries = 1000, tries = 0;
    do {
        // Remplir TrueGrid avec des valeurs aléatoires (0 ou 1) tout en respectant les règles de Takuzu
        for (int i = 0; i < SIZE; i++) {
            int count0 = 0, count1 = 0;
            for (int j = 0; j < SIZE; j++) {
                // Assure que les valeurs sont soit 0 soit 1
                TrueGrid[i][j] = rand() % 2;
                if (i > 1 && TrueGrid[i][j] == TrueGrid[i-1][j] && TrueGrid[i][j] == TrueGrid[i-2][j]) {
                    TrueGrid[i][j] = 1 - TrueGrid[i][j]; // Inverse la valeur si elle viole la règle des 3 consécutifs
                }
                if (j > 1 && TrueGrid[i][j] == TrueGrid[i][j-1] && TrueGrid[i][j] == TrueGrid[i][j-2]) {
                    TrueGrid[i][j] = 1 - TrueGrid[i][j]; // Inverse la valeur si elle viole la règle des 3 consécutifs
                }
                (TrueGrid[i][j] == 0) ? count0++ : count1++;
            }
        }
        tries++;
        if (tries > maxTries) {
            cerr << "Erreur: impossible de générer un tableau valide après " << maxTries << " essais." << endl;
            return;
        }
    } while (!isValid(TrueGrid)); // Assure que la grille est valide selon les règles de Takuzu
    cout << "Board generated successfully!" << endl;
}

// [[Rcpp::export]]
int GetCaseValue(int i, int j) {
    return TrueGrid[i][j];
}

int main() {
    srand(time(0));
    initializeGrids(6); // Initialise avec une taille par défaut de 6
    generateValidBoard(); // Génére un tableau valide
    return 0;
}

