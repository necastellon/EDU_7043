#Bring in Data
acs<-read.csv(file = "https://raw.githubusercontent.com/mattdemography/EDU_7043/master/Data/2010_ACS_5Year_BlockGroup.csv", stringsAsFactors=F)
names(acs)

#Rename Some Variables
library(plyr)
acs<-rename(acs, c(JN9M001="Edu_Tot", JN9M002="Edu_Male", JN9M019="Edu_Female"))
names(acs)

#Create New Variables By Adding
acs$Nohs_male<-rowSums(acs[,261:268])
head(acs[,c(261:268,297)])

#acs$Nohs_female<-rowSums(acs[,])
#head(acs[,c()])

myvars<-c("YEAR", "STATE", "COUNTY", "Edu_Tot", "Edu_Male", "Edu_Female", "Nohs_male")
acs2<-acs[myvars]
names(acs2)

#Table
table(acs2$STATE)
table(acs2$COUNTY)
table(acs2$Edu_Female)

#Steam-Leaf
stem(acs2$Edu_Male, scale = 1, width = 80, atom = 1e-08)
stem(acs2$Edu_Female, scale = 1, width = 80, atom = 1e-08)

#Box Plots
boxplot(acs2$Edu_Tot, main="Title", xlab="X Axis Title", ylab="Y Axis Title")
boxplot(acs2$Nohs_male, main="Title", xlab="X Axis Title", ylab="Y Axis Title")

#Histograms
hist(acs2$Edu_Tot)
hist(acs2$Nohs_male, main="Male High School Non-Completion in Texas", xlab="Number of Males Not Graduating")
#hist(acs2$COUNTY)

#Bar Plots
#First Create A Count
Counties<-table(acs2$COUNTY)
barplot(Counties, main="Title", xlab="County")

#What Would be More Informative?

#Scatter Plot
plot(acs2$Edu_Female, acs2$Edu_Male, main="Scatter Plot Example", xlab="Number of Females", ylab="Number of Males")
plot(acs2$Nohs_male, acs2$Edu_Male, main="Scatter Plot Example", xlab="Number of Males w/o HS Degree", ylab="Number of Males")

#Line Graph
  #Create List of Numbers to Sample from
  nums<-c(1,2,3)
  obs<-nrow(acs2)
  acs2$Time_Period<-sample(nums, obs, replace=T)
  
  #After we create our fake time periods we can get sums by period for each county
  acs2$County_time<-plyr::id(acs2[c("COUNTY", "Time_Period")], drop=T)
  table(acs2$County_time)
  table(unique(acs2$County_time))
  
  acs_sum<-aggregate(acs2$Nohs_male, by=list(County_time=acs2$County_time), FUN=sum)
  acs_sum<-plyr::rename(acs_sum, c(x="Nohs_male_sum"))
  names(acs_sum)
  #I may want to bring in County Names. I use the merge function to do this.
  acs_sum<-merge(acs_sum, acs2[,c("COUNTY", "County_time", "Time_Period")], by="County_time")
  acs_sum<-subset(acs_sum, !duplicated(acs_sum$County_time))
  
  #Now do a temporal graph
  #Get Ranges - This Helps Set the Plot Space
  xrange<-range(acs_sum$Time_Period)
  yrange<-range(acs_sum$Nohs_male_sum)
  #Grab Max Number of Counties
  ncounty<-length(unique(acs_sum$COUNTY))
  #Create new variable numbered 1 to Max County Length
  acs_sum$cnt_num<-plyr::id(acs_sum[c("COUNTY")], drop=T)
    #Check Work
    table(acs_sum$cnt_num)
  
  #Setup the Plot
  plot(xrange, yrange, type="n", xlab="Time Periods", ylab="Variable of Interest")
  colors<- rainbow(ncounty)
  linetype<- c(1:as.numeric(ncounty))
  #Add Lines
  for(i in 1:ncounty){
    county<-subset(acs_sum, acs_sum$cnt_num==i)
    lines(county$Time_Period, county$Nohs_male_sum, type="b", lwd=1.5, lty=linetype[i], col=colors[i])
  }
  title("Fictionalized Line Graph") #Add a Title to the graph
