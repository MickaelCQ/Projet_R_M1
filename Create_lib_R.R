# Un package est une bibliothèque qui contient un ensemble d'objets
# Avantage distribution, documentation, test, etc ...

# Bonnes pratiques :
#   - Projet strucuté, code, donnée et doc . 
#   - Documentation .
#   - Code standardisé
#   - Gérer les dépendances.  (ordonnancement, reproductibilité)
#   - 

# R CMD build construire un package. 
# R CMD check
# usethis : automatisé les projets
install.packages(c("devtools","roxygen2","rmarkdown","lintr")) # Accès à bioconductor

# Opérateur de portée.
pkg::fun()



