if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

#Install rTandem 
BiocManager::install("rTANDEM")
library(rTANDEM)
#Install shinyTandem 
BiocManager::install("shinyTANDEM")
library(shinyTANDEM)
