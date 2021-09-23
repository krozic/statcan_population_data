library(shiny)
library(shinydashboard)
library(leaflet)

shinyUI(dashboardPage(
    skin = 'blue',
    dashboardHeader(title = 'Canada Population Change'),
    dashboardSidebar(
        h1('Choose Year'),
        selectInput('date1', 'Start Date:', seq(2001, 2020)),
        selectInput('date2', 'End Date:', seq(2001, 2020), selected = 2002),
        h1('Choose Table Type'),
        selectInput('tableType', 'Contents:', c('All Years', 'Change')),
        column(12, 
               style = 'margin-left: 70px', 
               submitButton('Apply'))
    ),
    dashboardBody(
        fluidRow(box(width = 12, leafletOutput(outputId = 'map', height = 500))),
        fluidRow(box(width = 12, dataTableOutput(outputId = 'summary_table')))
    )
))
