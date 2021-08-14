TandemSearch <- function(taxon = 'yeast', format = 'peptide',
                         FastaPath = system.file("extdata/fasta/scd.fasta.pro", package="rTANDEM"),
                         MGFPath = system.file("extdata/200217-2-9-.mgf", package="rTANDEM"),
                         InputPara = system.file("extdata/default_input.xml", package="rTANDEM"),
                         Output_Path = paste(getwd(), "output.xml", sep="/"))
{
  taxonomy <- rTTaxo(taxon = taxon, format = format, URL = FastaPath)
  
  param <- rTParam()
  param <- setParamValue(param, 'protein', 'taxon', value=taxon)
  param <- setParamValue(param, 'list path', 'taxonomy information', taxonomy)
  param <- setParamValue(param, 'list path', 'default parameters',
                         value=InputPara)
  param <- setParamValue(param, 'spectrum', 'path',
                         value=MGFPath)
  param <- setParamValue(param, 'output', 'xsl path',
                         value="assets/par files/tandem-style.xsl")
  param <- setParamValue(param, 'output', 'path',
                         value=Output_Path)
  
  result.path <- tandem(param)
  return(result.path)
}