library(rTANDEM)
source("ConstructSpectra.R")
source("TandemSearch.R")
source("RemoveIdentification.R")

MGF.map <- Construct_SpectraDF(MGFPATH)
#Apply tandem search
Results <- TandemSearch()
#Remove identified spectra
Filtered.MGF <- RemoveIdentification(MGF.map, Results)