library(RCurl)
library(XML)
library(rvest)

getPlan = function(skip) {
  if (!is.logical(skip)) { stop("Function needs a logical, do you want to Skip?") }
  
  #skip=TRUE
  if (skip) {
    load('datasets/marathonPlan.Rda')
  } else {
    
    url.pre = 'https://runkeeper.com/fitnessClassSession?userClassRegistrationId=&fitnessClassId=10&calendarType=MONTHLY&dayToView='
    url.post = '&startDate=11%2F15%2F16'
    
    day = 1
    count=0
    
    grabber = data.frame(day = as.integer(), miles = as.double(), date=as.character(), desc=as.character(), stringsAsFactors=FALSE)
    for (day in 1:130) {
      
      page = read_html(getURL(paste0(url.pre,day,url.post)))
      node = html_text(html_node(page,xpath = '//*[@id="dayDisplay"]/p'))
      
      if (is.na(node)) {
        count=count+1
        grabber[count,] = c( day, html_text(html_node(page,xpath = '//*[@id="dayDisplay"]/div/div[2]/div[2]/h2'))
                             , html_text(html_node(page,xpath = '//*[@id="dayDisplay"]/div/div[2]/div[2]/h3'))
                             , html_text(html_node(page,xpath = '//*[@id="dayDisplay"]/div/div[2]/div[2]/p')) )
        print(day)
      }
    }
    
    grabber$Date = as.Date(grabber$date, format='%a. %b %d, %Y')
    grabber$Miles = ifelse(substr(grabber$miles, nchar(grabber$miles)-1, nchar(grabber$miles))=='mi'
                           & !grepl('x', grabber$miles)
                           , substr(grabber$miles,1,regexpr(' ',grabber$miles)-1)
                           , grabber$miles )
    grabber$Miles = ifelse(substr(grabber$Miles, nchar(grabber$Miles)-1, nchar(grabber$Miles))=='mi'
                           & grepl('x', grabber$Miles)
                           , as.numeric(substr(grabber$Miles,1,regexpr('x',grabber$Miles)-1) ) *
                             as.numeric(substr(grabber$Miles,regexpr('x',grabber$Miles)+1,regexpr(' ',grabber$Miles)-1) )
                           , grabber$Miles )
    
    grabber$Miles = ifelse(grabber$Miles=='8x2' | grabber$Miles== '5x1000', 6, grabber$Miles)
    grabber$Miles = ifelse(grepl('\\+', grabber$Miles), substr(grabber$Miles,1,regexpr(' ',grabber$Miles)-1), grabber$Miles)
    grabber$Miles = ifelse(grabber$Miles=='15 min', 2, grabber$Miles)
    grabber$Miles = as.double(grabber$Miles)
    
    #table(grabber$Miles)
    
    grabber$Week = as.integer(floor(difftime(grabber$Date, grabber$Date[1], units='weeks')+1))
    grabber$Month = format(grabber$Date, '%B')
    grabber$Day = format(grabber$Date, '%A')
    
    marathonPlan = grabber
    rm(grabber)
    
    save(marathonPlan, file='datasets/marathonPlan.Rda')
    
  }
  return(marathonPlan)
}