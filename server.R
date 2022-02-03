library(shiny)

server <- function(input, output) {
  output$debug <- renderPrint({

    })
  output$ts_plot <- renderPlot({
    plot_df <- sales_df[
      sales_df$scode == input$selected_store &
        sales_df$pcode == input$selected_sku,
      ]

    autoplot(plot_df)
  })
}
