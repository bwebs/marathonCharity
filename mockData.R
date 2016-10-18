#Mock Up Actual Donations

donationActual = data.frame(Dates=dailyPlan$Dates[1:7], actualDonations = dailyPlan$TotalDonations[1:7])
donationActual$actualDonations = donationActual$actualDonations - sample(sample(-10:10),7)
donationActual$actualDonations[1] = donationActual$actualDonations[1]+sample(-20:10,1)
for(i in 2:length(donationActual$actualDonations)) {
  donationActual$actualDonations[i] = donationActual$actualDonations[i]+sample(-20:10,1)
  if (donationActual$actualDonations[i] < donationActual$actualDonations[i-1]) {
    donationActual$actualDonations[i] = donationActual$actualDonations[i-1]
  } 
}

milesActual = data.frame(Dates = sample(marathonPlan$Date[1:10],7), Miles = sample(marathonPlan$Miles[1:10],7) )
#milesActual = milesActual[order(milesActual$Dates),]
#milesActual$TotalActualMiles = cumsum(milesActual$Miles)           
