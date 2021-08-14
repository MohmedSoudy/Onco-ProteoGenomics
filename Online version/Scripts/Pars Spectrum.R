#Parse Extracted Spectra and get Spectral ID 
Parse.Spectrum <- function(Result.Path)
{
  
  Results.XML <- xmlParse(Result.Path)
  
  Spectrum.Info <- getNodeSet(Results.XML, '//note[@label="Description"]')
  
  Spectrum.data <- unlist(lapply(Spectrum.Info, function(x) xmlSApply(x, xmlValue)))
  
  Spectrum.ID <- as.character(sub("\\s.*","",Spectrum.data))
  return(Spectrum.ID)
}