# Define server logic
shinyServer(function(input, output, session) {
        
        ## Raw data tab
        # output conditional panels for conditional user selection
        
        output$chickUi <- renderUI({
                selectizeInput("chick", "", 
                               as.factor(CW$Chick), selected = 1,
                               multiple = TRUE,
                               options = list(placeholder = "Select chick"))
        })
        
        output$dietUi <- renderUI({
                selectizeInput("diet", "",
                               as.factor(CW$Diet), selected = NULL,
                               multiple = TRUE,
                               options = list(placeholder = "Select diet"))
        })
        
        output$dietIDUi <- renderUI({
                selectizeInput("dietID", "",
                               as.factor(CW$Diet), selected = NULL,
                               multiple = TRUE,
                               options = list(placeholder = "Select diet"))
        })
        
        output$timeIDUi <- renderUI({
                selectizeInput("timeID", "",
                               as.factor(CW$Time), selected = NULL,
                               multiple = TRUE,
                               options = list(placeholder = "Select time"))
        })
        
        output$timeUi <- renderUI({
                selectizeInput("time", "",
                               as.factor(CW$Time), selected = NULL,
                               multiple = TRUE,
                               options = list(placehoder = "Select time"))
        })
        
        output$Chicktable <- DT::renderDataTable(DT::datatable({
                
                data <- CW
                
                if(input$ShowID == 'All' && input$ShowDiet == 'All' && input$ShowTime == 'All')
                
                        data <- CW %>%
                                filter(between(Weight, input$rangeWgt[1], input$rangeWgt[2]))
                
                
                else if(input$ShowTime == 'time' && input$ShowID == 'chick' && input$ShowDiet == 'diet')

                        CW %>%
                                filter(between(Weight, input$rangeWgt[1], input$rangeWgt[2])) %>%
                                filter(Chick %in% input$chick) %>%
                                filter(Diet %in% input$diet) %>%
                                filter(Time %in% input$time)
                
                else if(input$ShowTime == 'time' && input$ShowID == 'chick' && input$ShowDiet == 'All')
                        CW %>% 
                                filter(between(Weight, input$rangeWgt[1], input$rangeWgt[2])) %>%
                                filter(Chick %in% input$chick) %>%
                                filter(Time %in% input$time) 
                        
                else if(input$ShowID == 'chick')
                        
                        CW %>%
                                filter(between(Weight, input$rangeWgt[1], input$rangeWgt[2])) %>%
                                filter(Chick %in% input$chick)
                
                else if(input$ShowDiet == 'diet')
                        
                        CW %>%
                                filter(between(Weight, input$rangeWgt[1], input$rangeWgt[2])) %>%
                                filter(Diet %in% input$diet)
                
                else if(input$ShowTime == 'time')
                        
                        CW %>%
                                filter(between(Weight, input$rangeWgt[1], input$rangeWgt[2])) %>%
                                filter(Time %in% input$time)
                
        
                
        },  style = "default", rownames = FALSE, options = list(pageLength = 15)))
        
        
        
        ## Summaries tab
        
        output$sumtable <- DT::renderDataTable(DT::datatable({
                
                data <- CW_sum_stats %>%
                        filter(Diet %in% input$dietID) %>%
                        filter(Time %in% input$timeID) %>%
                        arrange(Diet, Time)
                
                if(input$DietID == 'All' && input$TimeID == 'All')
                        
                        data <- CW_sum_stats 
                
                else if(input$TimeID == 'timeID' && input$DietID == 'dietID')
                        
                        CW_sum_stats %>%
                                filter(Diet %in% input$dietID) %>%
                                filter(Time %in% input$timeID)
                
                
                else if(input$DietID == 'dietID')
                        
                        CW_sum_stats %>%
                                filter(Diet %in% input$dietID)
                
                else if(input$TimeID == 'timeID')
                        
                        CW_sum_stats %>%
                                filter(Time %in% input$timeID)
           
        },
        style = "default", rownames = FALSE, options = list(pageLength = 15))
        %>% DT::formatRound(c('Mean', 'SD', 'Median'), digits = c(1, 2, 1)))
        
        output$sumplot <- renderPlotly({
                
                CW_dat <- CW %>%
                        filter(Diet %in% input$dietID) %>%
                        filter(Time %in% input$timeID) %>%
                        ggplot(., aes(Time, Weight, colour = Diet, text = paste("Chick:", Chick))) +
                        scale_x_continuous(breaks=unique(CW$Time)) +
                        scale_y_continuous(breaks=seq(50, 350, by = 50)) +
                        scale_colour_tableau() +
                        theme_hc() +
                        xlab("Time (days)") + 
                        ylab("Weight (grams)") 
                
                if(input$DietID == 'All' && input$TimeID == 'All')
                        
                        CW_dat <- CW %>%
                                ggplot(., aes(Time, Weight, colour = Diet, text = paste("Chick:", Chick))) +
                                scale_x_continuous(breaks=unique(CW$Time)) +
                                scale_y_continuous(breaks=seq(50, 350, by = 50)) +
                                scale_colour_tableau() +
                                theme_hc() +
                                xlab("Time (days)") + 
                                ylab("Weight (grams)") 
                        
                if("Plot diets separately" %in% input$plotType) {
                        
                CWplot <- CW_dat +
                        facet_wrap(~Diet) +
                        theme(legend.position = "none") #+ 
                        #geom_boxplot(aes(group=interaction(Time, Diet))) 
                
                } else {
                        CWplot <- CW_dat + theme(legend.position = "bottom")
                
                }
                
                if("Box-Whisker Plot" %in% input$plotShow){
                        
                        CWplot <- CWplot +
                                # use interaction to combine two variables into a new factor
                                geom_boxplot(aes(group=interaction(Time, Diet))) 
                }
                 if("Scatter Plot" %in% input$plotShow){
                         
                         CWplot <- CWplot + geom_jitter(size = .4)
                 }
                 if("Mean Lines" %in% input$plotShow){
                         
                         CWplot <- CWplot + stat_summary(fun.y = "mean", 
                                                         geom = "line",
                                                         aes(group = Diet), size = 1)
                 }
                
                 CWplot <- ggplotly(CWplot)
        CWplot
   
        })
        
        #  R Help for the Chick Weight Data
        output$RHelp <- renderText(
                paste(br(), tags$pre("help(ChickWeight)"), p(" "), helpCW)
        )

}
)






