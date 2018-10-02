#' remove_nulls deleles null/empty entries in a list
#'
#' @export
remove_nulls  <-  function(list){   #
  list[unlist(lapply(list, length) != 0)]
}

#' var_names searches for variables by keyword
#'
#' @export
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
    return(dat)
  } else{
    cat("No variables found. Try again with a different search term.")
  }
}



#' Inspect SPSS dataset with little shiny app
#'
#' @export

binoculaR <- function(data, ...) {

  ### seems necessary
  library(shiny)
  library(miniUI)
  library(labelled)
  library(magrittr)
  library(dplyr)
  library(DT)
  library(sjPlot)
  library(lazyeval)

  ui <- miniPage(
    gadgetTitleBar("binoculaR"),
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
        ),
        miniTabPanel(
          "Levels",
          icon = icon("braille"),
          miniContentPanel(
            shiny::htmlOutput("levels", width = "100%")
          )
        ),
        miniTabPanel(
          "Code",
          icon = icon("code"),
          miniContentPanel(
            shiny::htmlOutput("variable_names", width = "100%")
          )
        )
      )
  )




  server <- function(input, output, session) {

    dat <- reactive({var_names(data, "")})
    full_data <- reactive({ data })

    output$tab <- DT::renderDataTable({
      return(dat())
    })

    output$selected <- DT::renderDataTable({
      req(input$tab_rows_selected)
      return(dat()[input$tab_rows_selected, ])
    })

    output$levels <- renderUI({
      req(input$tab_rows_selected)
      dataset <- full_data()[, input$tab_rows_selected]
      sjPlot::view_df(
        dataset,
        #show.frq = TRUE,
        # show.prc = TRUE,
        # show.na = T,
        use.viewer = F,
        ...
      )$knitr %>%
        shiny::HTML(.)
    })

    output$variable_names <- renderUI({
      req(input$tab_rows_selected)
      out_code <- dat()[input$tab_rows_selected, "var_codes"] %>%
        paste(collapse = ", ")
      data_name <- lazyeval::expr_find(data)
      out_code <- glue::glue("<h2>{data_name} %>%<br>
                                &nbsp;&nbsp;dplyr::select({out_code})
                             </h2>")
      tagList(
        out_code %>% shiny::HTML(.)
      )
    })


    # observeEvent(input$done, {
    #   stopApp(returnValue)
    # })
  }

  runGadget(ui, server, viewer = dialogViewer(dialogName = "binoculaR", width = 900, height = 800))
}
