library(shiny)

ui <- fluidPage(
  selectInput(
    inputId = "selected_store",
  label = "select store:",
  choices = unique(sales_df$scode)
  ),
  selectInput(
    inputId = "selected_sku",
    label = "select SKU:",
    choices = unique(sales_df$pcode)
  ),
    plotOutput("ts_plot"),
    verbatimTextOutput("debug")
  )

