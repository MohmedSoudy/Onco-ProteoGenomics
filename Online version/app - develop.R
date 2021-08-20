## app.R ##
library(shiny)
library(shinyjs)
library(shinyalert)
library(shinydashboard)
library(dashboardthemes)
library(shinycustomloader)
library(shinyFiles)
library(markdown)
library(rTANDEM)
library(XML)
library(DT)
source("Scripts/ConstructSpectra.R")
source("Scripts/TandemSearch.R")
source("Scripts/RemoveIdentification.R")
source("Scripts/Pars Spectrum.R")
source("Scripts/WriteSpectra.R")


ui <- dashboardPage(
  dashboardHeader(title = "Onco-proteogenomics"),
  ## Sidebar content
  dashboardSidebar( 
    sidebarMenu(id = "tabs",
      menuItem("Documentation", tabName = "Doc", icon = icon("users-cog")),
      menuItem("Data analysis", tabName = "Data_analysis", icon = icon("database"),
               menuSubItem("Upload data", tabName = "upload", icon = icon("upload")),
               menuSubItem("Database Search", tabName = "search", icon = icon("search")),
               menuSubItem("Viuslaization", tabName = "Visualaize", icon = icon("chart-bar")),
               menuSubItem("Remove Identified Spectra", tabName = "remove", icon = icon("trash-alt"))
               )#Data analysis menu 
    )#Sidebar menu
  ),#Side bar closing
  dashboardBody(
    shinyDashboardThemes(
      theme = "flat_red"
    ),
    useShinyalert(),
    tabItems(
      # Boxes need to be put in a row (or column)
      tabItem(tabName = "Doc",
              includeMarkdown("assets/Documentation.md")), #Documentation 
      tabItem(tabName = "upload",
              h2("Upload your spectral files to start the analysis"),
              h6("Spectral files shoud be MGF or RAW files"),
              shinyFilesButton(id = "Spectra", label = "Upload spectral files",title = "Upload MGF files",
                               multiple = F,icon = icon("file")), br(), br(),
              shinyFilesButton(id = "DB", label = "Browse database files", title = "Select databases",
                             icon = icon("database"), multiple = F), br(), br(),
              textInput(inputId = "Taxonomy", label = "Taxonomy", value = "ex: human, yeast"),
              shinyDirButton(id = "output", label = "Output Path", title = "Browse output folder"), br(), br(),
              actionButton(inputId = "Submit", label = "Submit")
      ),#Upload 
      tabItem(tabName = "search",
        tabsetPanel(
          tabPanel("Spectral", withLoader(DT::dataTableOutput("Spectral"), type = "html", loader = "loader6")),
          tabPanel("Peptides", withLoader(DT::dataTableOutput("Peptides"), type = "html", loader = "loader6")),
          tabPanel("Proteins", withLoader(DT::dataTableOutput("Proteins"), type = "html", loader = "loader6")),
          tabPanel("PTMs", withLoader(DT::dataTableOutput("PTMs"), type = "html", loader = "loader6"))
        )#tabset closing 
      ),#Search
      tabItem(tabName = "Visualaize", 
              tabPanel("Spectral visualization", 
                       h2("Select Spectral ID"),
                       textInput(inputId = "SpecID", label = "Enter Spectral ID"),
                       plotOutput("Spectraplot"))#spectra
              ),#visualization tab
      tabItem(tabName = "remove",
              h2("This Tab removes the identified spectra resulting from the search and write the new spectral file into user-defined directory"),
              shinyDirButton(id = "OutSpec",label = "Select the path to write output", title = "Select Output path"), br(),
              actionButton(inputId = "Submit_spec", label = "Submit")
              )#Remove and write spectra
    )#tab items
  )#Dashboard body
)#UI

server <- function(input, output, session) {
  #For browsing files and directories
  volumes = getVolumes()()
  
  MGF_Path <- ""
  DBPath <- ""
  Outpath <- ""
  Result.Path <- ""
  
  SpecDF <- NULL
  
  observeEvent(input$Spectra,{  
    
    shinyFileChoose(input, "Spectra", roots = volumes, session = session)
    
        # browser()
        MGF <- parseFilePaths(volumes, input$Spectra)
        MGF_Path <<- as.character(MGF$datapath)
        shinyalert(title = "Spectral upload",text = MGF_Path, type = "success")
  }) #observe closing 
  
  observeEvent(input$DB,{
    
    shinyFileChoose(input, 'DB', roots=volumes, session=session)
        # browser()
        DBPath <- parseFilePaths(volumes, input$DB)
        DBPath <<- as.character(DBPath$datapath)
        shinyalert(title = "Database upload",text = DBPath, type = "success")
        
  })# observe closing 
  
  observeEvent(input$output,{
    
      Dirvolumes <- getVolumes()()
      shinyDirChoose(input, 'output', roots=Dirvolumes, session=session)
    
      Outpath <<- parseDirPath(Dirvolumes, input$output)
      shinyalert(title = "Output path",text = Outpath, type = "success")
  })#Observe closing  
  
  observeEvent(input$Submit,{
    #Build spectral library
    updateTabItems(session = session,inputId = "tabs", selected = "search")
  })
  
  Results <- NULL
  output$Spectral <- DT::renderDataTable({
    
   SpecDF <<- Construct_SpectraDF(MGF_Path)
   shinyalert(title = "Spectral indexing", text = paste0("Number of spectra in file: ", dim(SpecDF)[1]), type = "success")
    #Perform search 
    Result.Path <<- TandemSearch(taxon = input$Taxonomy, MGFPath = MGF_Path, FastaPath = DBPath,
                 InputPara = "assets/par files/default_input.xml", Output_Path = paste0(Outpath, "/output.xml"))
    Results <<- GetResultsFromXML(Result.Path)
    Results@spectra
    
  })
  
  output$Peptides <- DT::renderDataTable({
    Results@peptides
  })
  
  output$Proteins <- DT::renderDataTable(
    Results@proteins,
    options = list(scrollX = TRUE)
  )
  
  output$PTMs <- DT::renderDataTable({
    Results@ptm
  })
  
  #Spectral Plotting 
  output$Spectraplot <- renderPlot({
    if (input$SpecID != "")
    {
      ms2.plot(spectrum.id = input$SpecID, result = Results)
    }
  })
  
  #Remove identification and write new mgf 
  OutpathSpec <- ""
  observeEvent(input$OutSpec,{
    
    Dirvolumes <- getVolumes()()
    shinyDirChoose(input, 'OutSpec', roots=Dirvolumes, session=session)
    
    OutpathSpec <<- parseDirPath(Dirvolumes, input$OutSpec)
    shinyalert(title = "Output path",text = OutpathSpec, type = "success")
  })#Observe closing  
  
  observeEvent(input$Submit_spec,{
    #Get identified spectra
    IdentSpectra <- Parse.Spectrum(Result.Path)
    print(head(IdentSpectra))
    #Remove identified spectra
    NewSpectra <- RemoveIdentification(SpectraDF =  SpecDF, Spec.ID = IdentSpectra)
    print(head(NewSpectra))
    #Write spectra to file 
    WriteSpectra(NewSpectra = NewSpectra, FilePath = OutpathSpec, FileName = "NewSpectra.MGF")
    
    shinyalert(title = "Spectral identification",text = "Spectral library generated!", type = "success")
  })
}

shinyApp(ui = ui, server = server)
