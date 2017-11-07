# ###### Instructions ##############################
# 
# The below app explores the build-in R dataset "mtcars". In this tutorial you
# will expand this app.
# 
# Run the app by either using the runApp() command or by hitting "Run App" in the
# upper right corner of the script editor. Explore the interactive behaviour of 
# the app and how it is implemented codewise.
#
#
# ### 1st task ###
# 
# Improve the layout of the tab "Scatter Plots" by moving the input elements into
# a side bar and the plot into the main panel. You can do this using the 
# sidebarLayout function.
# 
# 
# ### 2nd task ###
# 
# Add a check box to the sidebar panel that allows the user to add a regression
# line to the plot.
#
# Hint: You can add geom_smooth(method = "lm") to the ggplot object to add a
# regression line to the plot.
# 
# 
# ### 3rd task ###
# 
# The "Data" tab is blank. Implement the following:
# The tab should display the mtcars data in a table. The sidebar panel should allow
# user to filter the data for specific levels of the variables cyl and gear (e.g.  
# drop down menus or radio buttons).
#
#

###Setup
if(!require("shiny")) install.packages("shiny")
if(!require("ggplot2")) install.packages("ggplot2")
if(!require("dplyr")) install.packages("dplyr")



###### Shiny App ################################


### UI
ui <- fluidPage(
	titlePanel("mtcars Shiny Tutorial"),
	tabsetPanel(
		tabPanel("Scatter Plots",
				
			#Select axes variables
			selectInput(inputId = "yvar", label = "y Axis",
						choices = c("mpg", "disp", "hp", "drat", "wt", "qsec"),
						selected = "mpg"),
			
			selectInput(inputId = "xvar", label = "x Axis",
						choices = c("mpg", "disp", "hp", "drat", "wt", "qsec"),
						selected = "disp"),
			
			#Scatter plot output
			plotOutput(outputId = "scatter", height = "400px")
			
		),
		tabPanel("Data")
	),
	#Source link
	tags$a(href = "https://stat.ethz.ch/R-manual/R-devel/library/datasets/html/mtcars.html", 
		   "Source: Henderson and Velleman (1981)", target = "_blank")
)


### Server function
server <- function(input, output) {
	#Create scatterplot
	output$scatter <- renderPlot({
		plot <- ggplot(mtcars, aes_(y = as.name(input$yvar), x = as.name(input$xvar))) +
			geom_point(size = 2.5)
		plot
	})
	
	#Add data table code here
}

### Create Shiny object
shinyApp(ui = ui, server = server)
