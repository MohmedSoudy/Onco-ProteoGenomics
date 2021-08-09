RemoveIdentification <- function(SpectraDF, Spec.ID)
{
  #Remove identified spectra from MGF
  SpectraDF <- data.frame(SpectDF[!rownames(SpectDF) %in% Spec.ID,]) 
  return(SpectraDF)
}

