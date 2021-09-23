library(shiny)
library(dplyr)
library(data.table)
library(sf)
library(RColorBrewer)
library(leaflet)
library(tidyr)

popTot <- read.csv('./data/popTot.csv', 
                   na.strings = '')
popTot <- spread(popTot, YEAR, POPULATION) %>%
        select(-GEO)
shp <- st_read('./data/division_shapes_digital/lcd_000a16a_e.shp', 
               stringsAsFactors = F)

shinyServer(function(input, output) {
        date1 <- reactive({grep(input$date1, names(popTot))})
        date2 <- reactive({grep(input$date2, names(popTot))})
        inputData <- reactive({
                popTot %>%
                        mutate(CHANGE_PER_10k = round((popTot[date2()]-popTot[date1()])/popTot[date1()]*10000)) %>%
                        select(CITY, PROVINCE, CHANGE_PER_10k, CDUID)
        })
        popMap <- reactive({st_as_sf(merge(inputData(), shp)) %>%
                st_transform('+init=epsg:4326')})

        minVal <- reactive({min(popMap()$CHANGE_PER_10k)})
        maxVal <- reactive({max(popMap()$CHANGE_PER_10k)})
        domain <- reactive({c(minVal(), maxVal())})
        colorPal <- reactive({c(colorRampPalette(colors = brewer.pal(11, 'RdBu')[c(1:4, 6)],
                                       space = 'Lab')(abs(minVal()/10)),
                      colorRampPalette(colors = brewer.pal(11, 'RdBu')[c(6, 8:11)],
                                       space = 'Lab')(maxVal()/10)[-1])})
        colorPalInput <- reactive({colorNumeric(colorPal(), domain())})

        labels = reactive({sprintf('<strong>%s, %s</strong><br/>%g net migration/10k',
                         popMap()$CITY,
                         popMap()$PROVINCE,
                         popMap()$CHANGE_PER_10k[[1]]) %>%
                lapply(htmltools::HTML)})

        output$map <- renderLeaflet({
                popMap() %>%
                leaflet() %>%
                addProviderTiles('Stamen.TonerLite') %>%
                setView(lng = -95, lat = 60, zoom = 3) %>%
                addPolygons(color = '#444444',
                            weight = 1,
                            smoothFactor = 0.5,
                            opacity = 1,
                            fillOpacity = 0.7,
                            fillColor = ~colorPalInput()(popMap()$CHANGE_PER_10k[[1]]),
                            highlightOptions = highlightOptions(color = 'white',
                                                                weight = 2,
                                                                bringToFront = T),
                            label = labels(),
                            labelOptions = labelOptions(
                                    style = list('font-weight' = 'normal',
                                                 padding = '3px 8px'),
                                    textsize = '15px',
                                    direction = 'auto')) %>%
                addLegend(pal = colorPalInput(),
                          values = domain(),
                          opacity = 0.7,
                          title = 'Net Migration Per 10k',
                          position = 'bottomright')
        })
        tableType <- reactive({if(input$tableType == 'All Years'){popTot} else{inputData()}})
        output$summary_table <- renderDataTable(tableType(), 
                                                options = list(pageLength = 25,
                                                               width = '100%',
                                                               scrollx = T))
})
