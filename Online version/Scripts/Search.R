library(rTANDEM)

#Database taxonmy ==> human 
#Path to database 
taxonomy <- rTTaxo(
  taxon = "human",
  format = "peptide", 
  URL = "D:/GSoC 2021/Shiny/assets/Database/uniprot-human-reviewed-trypsin.fasta"
)

param <- rTParam()
param <- setParamValue(param, 'protein', 'taxon', value="human")

param <- setParamValue(param, 'list path', 'taxonomy information', taxonomy)

param <- setParamValue(param, 'list path', 'default parameters',
                       value = "D:/GSoC 2021/Shiny/assets/par files/default_input.xml")

param <- setParamValue(param, 'spectrum', 'path',
                       value = "D:/GSoC 2021/Shiny/assets/raw data/200217-2-9-.mgf")

param <- setParamValue(param, 'output', 'xsl path',
                       value = "D:/GSoC 2021/Shiny/assets/par files/tandem-style.xsl")

param <- setParamValue(param, 'output', 'path',
                       value = "D:/GSoC 2021/Shiny/assets/Output/output.xml")

param <- setParamValue(param, 'output', 'sort results by', value = "spectrum")


result.path <- tandem(param)

result.R <- GetResultsFromXML(result.path)

library(XML)

Results.XML <- xmlParse(result.path)

Spectrum.Info <- getNodeSet(Results.XML, '//note[@label="Description"]')

Spectrum.data <- unlist(lapply(Spectrum.Info, function(x) xmlSApply(x, xmlValue)))

Spectrum.ID <- as.character(sub("\\s.*","",Spectrum.data))

SpectDF <- Construct_SpectraDF("D:/GSoC 2021/Shiny/assets/raw data/200217-2-9-.mgf")

NewSpectra <- data.frame(SpectDF[!rownames(SpectDF) %in% Spectrum.ID,]) 
