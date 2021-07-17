#Read MGF 
Construct_SpectraDF <- function(MGF_path)
{
  MGF <- readLines(MGF_path)
  
  BEGINIONS <- "BEGIN IONS"
  ENDIONS <- "END IONS"
  
  Begin.index <- which(MGF %in% BEGINIONS) 
  END.index <- which(MGF %in% ENDIONS)
  
  NumberofSpectra <- length(Begin.index)
  message(paste("Number of spectra identified in file", NumberofSpectra))
  
  IndvidualSpectraDF <- c()
  for (i in 1:NumberofSpectra)
  {
    Spectra <- MGF[Begin.index[i]:END.index[i]]
    #Get locus of spectra 
    SpectraID <- gsub(".*=(.+) .*", "\\1", Spectra[2])
    IndvidualSpectraDF[i] <- paste(Spectra, collapse = "#") #replace # with \n when writing the file 
    names(IndvidualSpectraDF)[i] <- SpectraID
  }
  IndvidualSpectraDF <- data.frame(IndvidualSpectraDF)
  
  return(IndvidualSpectraDF)
}