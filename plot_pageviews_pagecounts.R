library(tidyr)

## Reading 'pageviews_mobile-web_201507-201709.csv' and  
pv_mob_web <- read.csv('pageviews_mobile-web_201507-201709.csv')
pv_mob_web$DATE <- as.Date(as.character(pv_mob_web$timestamp), format='%Y%m%d')

pv_mob_app <- read.csv('pageviews_mobile-app_201507-201709.csv')
pv_mob_app$DATE <- as.Date(as.character(pv_mob_app$timestamp), format='%Y%m%d')

pv_desktop <- read.csv('pageviews_desktop_201507-201709.csv')
pv_desktop$DATE <- as.Date(as.character(pv_desktop$timestamp), format='%Y%m%d')

pc_mobile <- read.csv('pagecounts_mobile_200801-201607.csv')
pc_mobile$DATE <- as.Date(as.character(pc_mobile$timestamp), format='%Y%m%d')

pc_desktop <- read.csv('pagecounts_desktop_200801-201607.csv')
pc_desktop$DATE <- as.Date(as.character(pc_desktop$timestamp), format='%Y%m%d')


pageviews <- merge(pv_mob_app[,c(2,7,8)], pv_mob_web[,c(2,7,8)], by = 'DATE')
pv_mobile <- data.frame('DATE' = pageviews$DATE, 'mobileviews' = pageviews$views.x+pageviews$views.y)
pageviews <- merge(pv_desktop[,c(7,8)], pv_mobile, by = 'DATE')
colnames(pageviews) <- c('Date', 'pageview_desktop_views', 'pageview_mobile_views')



pagecounts <- merge(pc_desktop[,c(2,3,7)], pc_mobile[,c(2,3,7)], by = 'DATE', all.x = TRUE)
pagecounts[is.na(pagecounts)] <- 0
pagecounts <- pagecounts[,c(1,3,5)]
colnames(pagecounts) <- c('Date', 'pagecount_desktop_views', 'pagecount_mobile_views')


finaldf <- merge(pagecounts, pageviews, all = T)
finaldf$pagecount_all_views <- finaldf$pagecount_desktop_views + finaldf$pagecount_mobile_views
finaldf$pageview_all_views <- finaldf$pageview_desktop_views + finaldf$pageview_mobile_views
finaldf$DATE <- finaldf$Date
finaldf <- separate(finaldf, 'Date', c('year', 'month', 'day'), sep = '-')

write.csv(finaldf, file = "wikipedia-data.csv",row.names=FALSE)

#plot(finaldf$DATE, (finaldf$pagecount_desktop_views+finaldf$pageview_desktop_views)/1000000, type = 'l', color ='blue', lty = 2, ylim = c(0,12000))
#lines(finaldf$DATE, (finaldf$pagecount_mobile_views+finaldf$pageview_mobile_views)/1000000, type="l", lty=2, col="brown")
xmin<-min(finaldf$DATE,na.rm=T)
xmax<-max(finaldf$DATE,na.rm=T)
xseq<-seq.Date(xmin,xmax,by='1 month')

png(filename="plot.png", width = 580, height = 480, units = 'px')

plot(finaldf$DATE, finaldf$pagecount_desktop_views/1000000, type = 'l', lty = 2, lwd = 2,
     col = 'red', ylim = c(800,12000),
     main = 'Page Views on English Wikipedia (x 1,000,000)', xlab = '', ylab = '')
legend("topleft",legend=c('pagecount_desktop_views', 'pagecount_mobile_views',
                          'pagecount_all_views', 'pageview_desktop_views',
                          'pageview_mobile_views', 'pageview_all_views'),
       lty=c(2,2,1,2,2,1),col=c("red","red","brown", "blue", "blue", "black" ),lwd=2, bg = 'white', 
       y = 10000, ncol = 2, cex = 0.75)
lines(finaldf$DATE, finaldf$pagecount_mobile_views/1000000, type = 'l', lty = 2, lwd = 2,
      col = 'red')
lines(finaldf$DATE, finaldf$pagecount_all_views/1000000, type = 'l', lty = 1, lwd = 2,
      col = 'brown')
lines(finaldf$DATE, finaldf$pageview_desktop_views/1000000, type = 'l', lty = 2, lwd = 2,
      col = 'blue')
lines(finaldf$DATE, finaldf$pageview_mobile_views/1000000, type = 'l', lty = 2, lwd = 2,
      col = 'blue')
lines(finaldf$DATE, finaldf$pageview_all_views/1000000, type = 'l', lty = 1, lwd = 2,
      col = 'black')
grid(lty = 1, lwd = 0.5)

dev.off()