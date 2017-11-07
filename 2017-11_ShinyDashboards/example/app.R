library(shiny)

# UI
ui <- fluidPage(
	titlePanel("Histogram"),
	#Input
	numericInput(inputId = "mean", 
				label = "Mean:",
				value = 0),
	numericInput(inputId = "sd", 
				label = "Standard Deviation:",
				value = 1, min = 0),
	#Output
	plotOutput(outputId = "hist")
)

# Server
server <- function(input, output) {
	output$hist <- renderPlot({
		sample <- rnorm(1000, 
					  mean = input$mean, 
					  sd = input$sd)
		hist(sample)
	})
}

# Shiny object
shinyApp(ui = ui, server = server)
