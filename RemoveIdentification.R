RemoveIdentification <- function(SpectraDF, Search_results)
{
  IdentifiedSpectra <- Search_results@spectra
  rownames(IdentifiedSpectra) <- IdentifiedSpectra$id 
  #Remove identified spectra from MGF 
  SpectraDF <- SpectraDF[-rownames(IdentifiedSpectra),]
  return(SpectraDF)
}

