library(Rcpp)

Rcpp::sourceCpp('~/git/Projet_R_M1/TakuzuRules.cpp')

grid <- generateValidBoard()
hiddengrid <- partialBoard()

print(grid)
print(hiddengrid)
