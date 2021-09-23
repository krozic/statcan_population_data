library(shiny)
library(dplyr)
library(data.table)
library(sf)
library(RColorBrewer)
library(leaflet)

ui <- dashboardPage(
    skin = 'red',
    dashboardHeader(title = 'Canada Population Change'),
    dashboardSidebar(
        sidebarPanel(
            h1('Choose Year'),
            selectInput('date1', 'Start Date:', seq(2000, 2020)),
            selectInput('date2', 'End Date:', seq(2000, 2020))
        )
    ),
    dashboardBody(
        # fluidRow(box(width = 12, leafletOutput(ouputId = 'map'))),
        fluidRow(box(dataTableOutput(outputId = 'summary_table')))
    )
    
)

popTot <- read.csv('../../tables/popTot.csv')
metadata <- read.csv('../../tables/metadata.csv')
shp <- st_read('../../data/division_shapes/lcd_000b16a_e.shp', stringsAsFactors = F)

popTot <- merge(popTot, metadata)

server <- function(input, output) {
        date1 <- reactive({grep(input$date1, names(popTot))})
        date2 <- reactive({grep(input$date2, names(popTot))})
        inputData <- reactive({data.frame(c(date1, date2))})
        # inputData <- reactive({
        #         popTot %>% 
        #                 mutate(CHANGE = (popTot[,date2()]-popTot[,date1()])/popTot[,date1()]*10000) %>%
        #                 select(GEO, CITY, PROVINCE, CHANGE, CDUID)
        # })
        # 
        # popMap <- reactive({st_as_sf(merge(inputData(), shp))})
        # 
        # minVal <- reactive({min(popMap()$CHANGE)})
        # maxVal <- reactive({max(popMap()$CHANGE)})
        # domain <- reactive({c(minVal(), maxVal())})
        # 
        # colorPal <- reactive({c(colorRampPalette(colors = brewer.pal(11, 'RdBu')[c(1:4, 6)],
        #                                space = 'Lab')(abs(minVal()/10)),
        #               colorRampPalette(colors = brewer.pal(11, 'RdBu')[c(6, 8:11)],
        #                                space = 'Lab')(maxVal()/10)[-1])})
        # 
        # labels = reactive({sprintf('<strong>%s</strong><br/>%g net migration/10k',
        #                  popMap()$GEO, 
        #                  round(popMap()$CHANGE)) %>%
        #         lapply(htmltools::HTML)})
        # 
        # output$map <- renderLeaflet(
        #         st_transform(popMap(), '+init=epsg:4326') %>%
        #         leaflet() %>%
        #         addProviderTiles('Stamen.TonerLite') %>%
        #         setView(lng = -95, lat = 60, zoom = 3) %>%
        #         addPolygons(color = '#444444', 
        #                     weight = 1, 
        #                     smoothFactor = 0.5, 
        #                     opacity = 1, 
        #                     fillOpacity = 0.7, 
        #                     fillColor = ~get('colorNumeric')(colorPal(), domain())(popMap()$CHANGE),
        #                     highlightOptions = highlightOptions(color = 'white', 
        #                                                         weight = 2, 
        #                                                         bringToFront = T),
        #                     label = labels(),
        #                     labelOptions = labelOptions(
        #                             style = list('font-weight' = 'normal', 
        #                                          padding = '3px 8px'),
        #                             textsize = '15px',
        #                             direction = 'auto')) %>%
        #         addLegend(pal = colorNumeric(colorPal(), domain = domain()), 
        #                   values = domain(), 
        #                   opacity = 0.7, 
        #                   title = 'Net Migration Per 10k', 
        #                   position = 'bottomright')
        # )
        # 
        output$summary_table <- renderDataTable(inputData())

}

shinyApp(ui = ui, server = server)
