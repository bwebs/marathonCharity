shinyServer(function(input, output) {
  
  output$dygraph <- renderDygraph({
    dy
  })
  
})