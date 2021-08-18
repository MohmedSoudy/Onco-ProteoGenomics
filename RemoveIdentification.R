RemoveIdentification <- function(SpectraDF, Spec.ID)
{
  #Remove identified spectra from MGF
  SpectraDF <- data.frame(SpectraDF[!rownames(SpectraDF) %in% Spec.ID,]) 
  return(SpectraDF)
}

