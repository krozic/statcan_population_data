library(shiny)
library(data.table)
library(shinydashboard)

testData <- data.frame(replicate(70, sample(0:10, 90000, rep=TRUE)))
# write.csv(testData, file = "testData.csv", row.names = FALSE)
# csvData <- read.csv("testData.csv")
popTot <- read.csv('../../tables/popTot.csv')

ui <- dashboardPage(
    dashboardHeader(title = 'Canada Population Change'),
    dashboardSidebar(
        h1('Choose Year'),
        selectInput('date1', 'Start Date:', seq(2000, 2020)),
        selectInput('date2', 'End Date:', seq(2000, 2020))
    ),
    dashboardBody(
        fluidRow(box(width = 12, dataTableOutput(outputId = 'mytable')))
    )
    # dataTableOutput('mytable')
)

server <- function(input, output) {
    output$mytable <- renderDataTable(popTot, 
                                      options = list(pageLength = 10, 
                                                     width = '100%', 
                                                     scrollx = T))
}

shinyApp(ui = ui, server = server)
