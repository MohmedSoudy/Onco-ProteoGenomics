#Write New Soectra to file 
WriteSpectra <- function(NewSpectra, FilePath, FileName)
for (i in 1:dim(NewSpectra)[1]){
  
  colnames(NewSpectra) <- "ID"
  Spec <- gsub("#", "\n", NewSpectra$ID[i])
  write(x = Spec, file = paste0(FilePath, "/", FileName), append = T)
}