#' Find and SPSS variable names
#'
#' @export

binoculaR <- function(data) {

  library(shiny)
  library(miniUI)
  library(labelled)
  library(magrittr)
  library(dplyr)
  library(DT)

  remove_nulls  <-  function(list){   # delele null/empty entries in a list
    list[unlist(lapply(list, length) != 0)]
  }

  var_names <- function(data, keyword = "") {
    keyword <- ifelse(keyword %in% "all", "", keyword)
    #if 'all' turn into void, else copy keyword
    lablist <-  data %>%
      var_label() %>% # extract variable labels
      remove_nulls() %>% #remove empty lists
      dplyr::bind_rows() %>% # binding list elements as dataframe
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
      cat("Variable Name not found. Try again with a different name.")
    }
  }





  ui <- miniPage(
    gadgetTitleBar("binoculaR (Roth & Votta)"),
      miniTabstripPanel(
        miniTabPanel(
          "Full Dataset",
          icon = icon("table"),
          miniContentPanel(
            DT::dataTableOutput("tab")
          )
        ),
        miniTabPanel(
          "Selected",
          icon = icon("sliders"),
          miniContentPanel(
            DT::dataTableOutput("selected")
          )
        )
      )
  )

  server <- function(input, output, session) {

    dat <- reactive({var_names(data, "")})

    output$tab <- DT::renderDataTable({
      return(dat())
    })

    output$selected <- DT::renderDataTable({
      req(input$tab_rows_selected)
      return(dat()[input$tab_rows_selected, ])
    })

    observeEvent(input$done, {
      print(input$tab_rows_selected)
      returnValue <- data.frame(dat()[input$tab_rows_selected,], index = input$tab_rows_selected)
      stopApp(returnValue)
    })
  }

  runGadget(ui, server, viewer = dialogViewer(dialogName = "binoculaR", width = 900, height = 800))
}
