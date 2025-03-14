#Cours1 :

sed.seed(1014) # germe du générateur aléatoire.

#df <- data.frame (replicate(6,sample(c(1:10,-99),6,rep = TRUE)))
#names(df) <- letters[1:6] ; df

#Utilisation de lapply. 

ajouter1 <- function(x){y <- x +1 ; return(y)}
x <- list(1,2,3,4)
lapply(x,ajouter1)
# voir purr::map

# Utiliser la programmation défensive (utiliser des points d'arrêts, avec des conditions logiques.)
# Comment identifier les comportements involontaires ? 
# Trois outils de debuggage :
  #- Inspecter l'erreur Rstudio : Traceback()
  #- Utiliser Rerun with Debug et la commande options(error = browser)
  #- Intégrer dans une fonction un point de débuggage (breakpoint) ou la commande
  #  browser qui ouvre une session sur un point déterminé par le créateur

