library(dygraphs)
library(xts)
library(RColorBrewer)

add_shades = function(df,dy,clr) {
  #df = donationPlan
  wks = unique(ceiling(df$Week/2))*2
  for (i in wks) {
    dy = dyShading(dy, from=df$Start[i], to=df$End[i]+1, color=clr)
  }
  return(dy)
} 

# CSS ---------------------------------------------------------------------


write('
.dygraph-axis-label {

}
.dygraph-ylabel {
  color: #8DA0CB; 
}
.dygraph-y2label {
  color: #66C2A5; 
}
.dygraph-legend {
  font-size: 12px !important;
  left: 80px !important;
  top: 20px !important;
  background: transparent !important;
}
.dygraph-legend span {
  color: #66C2A5;
}
.dygraph-legend span + br + span {
  color: #8DA0CB;
}
.dygraph-rangesel-zoomhandle{
  visibility: hidden !important;
}
' , 'www/dygraph.css')


# Variables ---------------------------------------------------------------

marathonPlan = getPlan(TRUE)
checkDate = Sys.Date()+35
colors = brewer.pal(8, 'Set2')

graph.df = merge(dailyPlan, donationActual, by = 'Dates', all.x=TRUE )
graph.df = merge(graph.df, milesActual, by='Dates',all.x=TRUE)


graph.df$Miles = ifelse(is.na(graph.df$Miles),0,graph.df$Miles)
graph.df$TotalActualMiles = cumsum(graph.df$Miles)
graph.df$TotalActualMiles = ifelse(graph.df$Dates>=checkDate,NA,graph.df$TotalActualMiles)
graph.df$TotalMiles = ifelse(graph.df$Dates>=checkDate,graph.df$TotalMiles,NA)
graph.df$TotalDonations = ifelse(graph.df$Dates>=checkDate,graph.df$TotalDonations,NA)
graph.df$actualDonations = ifelse(graph.df$Dates>=checkDate,NA,graph.df$actualDonations)

graph.df = graph.df[,-which(names(graph.df)=='Week' | names(graph.df)=='Miles')]

diff = data.frame(
    diff.date = checkDate
  , min.miles = min(graph.df$TotalMiles, na.rm = TRUE)
  , max.miles = max(graph.df$TotalActualMiles, na.rm = TRUE)
  , min.donation = min(graph.df$TotalDonations, na.rm = TRUE)
  , max.donation = max(graph.df$actualDonations, na.rm = TRUE) 
  , diff.miles = min(graph.df$TotalMiles, na.rm = TRUE) - max(graph.df$TotalActualMiles, na.rm = TRUE)
  , diff.donation = min(graph.df$TotalDonations, na.rm = TRUE) - max(graph.df$actualDonations, na.rm = TRUE) )



names(graph.df) = c('Dates','Target Miles','Target Donations', 'Donations Collected', 'Miles Ran')
#xts.dona =  dailyPlan[,c('Start','totalDonations','weeklyDonations')]
#graph.df$Dates = format(graph.df$Dates, '%b. %d')
xts.dona = xts(graph.df[,-1], order.by=graph.df[,1])

#index(xts.dona) = index(xts.dona)-0

# Draw Graph --------------------------------------------------------------


dy = dygraph(xts.dona) %>% 
  dyRangeSelector(dateWindow = c(checkDate-4,checkDate+4)
                  , retainDateWindow=TRUE, height = 40,fillColor=colors[1], strokeColor=colors[3] ) %>%
  
  dySeries("Target Miles", axis = 'y2', color=colors[1], strokePattern = 'dotdash') %>%
  dySeries("Miles Ran", axis = 'y2', stepPlot=TRUE, color=colors[1]) %>%
  dySeries("Donations Collected", axis = 'y', stepPlot=TRUE, color=colors[3]) %>%
  dySeries("Target Donations", axis = 'y', color=colors[3], strokePattern = 'dotdash') %>%
  
  dyAxis(name="y", label = "Donations", axisLineColor='transparent'
         , axisLabelColor=colors[3], axisLabelWidth = 60
         , valueFormatter = 'function(d){return "$" + d.toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ",");}' 
         , axisLabelFormatter = 'function(d){return "$" + d.toString().replace(/\\B(?=(\\d{3})+(?!\\d))/g, ",");}'
         ) %>%
  dyAxis("y2", label = "Miles", axisLineColor='transparent', axisLabelColor=colors[1], axisLabelWidth = 50 ) %>%  
  dyAxis("x", axisLineWidth=0, axisLineColor='transparent', axisLabelColor=colors[8] ) %>%
  
  dyLegend(show='always', width=200, labelsSeparateLines = TRUE) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 1,
              hideOnMouseOut = FALSE) %>%
  dyEvent(checkDate, label='Today', color=colors[8]) %>%
  dyCSS('www/dygraph.css') %>%
  dyOptions(axisLineWidth = 0, digitsAfterDecimal=0
            , drawGrid=FALSE, mobileDisableYTouch=TRUE
            , strokeWidth=3, axisLabelFontSize = 14, fillAlpha = 1.0)
dy = add_shades(donationPlan,dy,paste0('#',paste0(as.hexmode(col2rgb('grey98')),collapse = '')))
#dy

