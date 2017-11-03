#' Find and SPSS variable names
#'
#' @export

binoculaR <- function(data) {

  library(shiny)
  library(miniUI)
  library(labelled)
  library(magrittr)
  library(dplyr)

  var_names <- function(data, keyword = "") {
    keyword <- ifelse(keyword %in% "all", "", keyword)
    #if 'all' turn into void, else copy keyword
    lablist <-  data %>%
      var_label() %>% # extract variable labels
      bind_rows() %>% # binding list elements as dataframe
      t() # transpose dataframe
    name_pos <- stringr::str_detect(tolower(lablist[, 1]), tolower(keyword))
    # get position of string
    if(any(name_pos)){ #if the string is found
      dat <-data.frame(var_codes=names(lablist[name_pos, ]),
                       var_names=lablist[name_pos, ],
                       row.names = NULL, stringsAsFactors = F)
      #colnames(dat) <- "var_names"
      cat(paste0("####---- Nice! You found ", nrow(dat) , " variables! ----#### \n \n "))
      return(dat)
    } else{
      cat("Variable Name not found. Try again, Stupid!")
    }
  }


  ui <- miniPage(
    gadgetTitleBar("binoculaR (Roth & Votta)"),
    miniContentPanel(
      DT::dataTableOutput("tab")
    )
  )

  server <- function(input, output, session) {
    # Render the plot
    output$tab <- DT::renderDataTable({
      return(var_names(data, ""))
    })
  }

  runGadget(ui, server, viewer = dialogViewer(dialogName = "binoculaR", width = 900, height = 600))
}
