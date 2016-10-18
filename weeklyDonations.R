library(plyr)

source('getRunningPlan.R')


rate = 10 # $10 brings in 1 mile
marathonPlan = getPlan(TRUE)
marathonPlan$TotalMiles = cumsum(marathonPlan$Miles)
#plot(marathonPlan$Date[1:40],marathonPlan$TotalMiles[1:40])

weekMax = ddply(marathonPlan, .(Week), summarize, End = max(Date))
weekMax$Start = weekMax$End-6

weekMiles = ddply(marathonPlan, .(Week), summarize, WeeklyMiles = sum(Miles))
weekMiles$TotalMiles = cumsum(weekMiles$WeeklyMiles)

donationPlan = merge(weekMax, weekMiles, by='Week')
rm(weekMiles,weekMax)
donationPlan$weeklyDonations = donationPlan$WeeklyMiles*rate
donationPlan$totalDonations = cumsum(donationPlan$weeklyDonations)

dailyPlan = data.frame(Dates = (marathonPlan$Date[1]):marathonPlan$Date[length(marathonPlan$Date)])
dailyPlan$Dates = as.Date.numeric(dailyPlan$Dates, origin='1970-01-01')
dailyPlan$Week = as.integer(floor(difftime(dailyPlan$Dates, dailyPlan$Date[1], units='weeks')+1))
dailyPlan = merge(dailyPlan, approx(marathonPlan$Date, marathonPlan$TotalMiles, xout = dailyPlan$Dates ), by.x='Dates', by.y = 'x')
names(dailyPlan)[names(dailyPlan)=='y'] = 'TotalMiles'
dailyPlan$TotalDonations = dailyPlan$TotalMiles*rate

#plot(dailyPlan$Dates[1:20], dailyPlan$TotalDonations[1:20], main = "approx(.) and approxfun(.)")
#points(dailyPlan$Dates, dailyPlan$TotalDonations, col = 2, pch = "*")


