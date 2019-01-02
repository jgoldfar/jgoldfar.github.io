df <- read.csv("Swipes-Time-Only.csv", header=TRUE)
library(lubridate)
library(dplyr)

df$TimeInHour <- df$Time.In %>% ymd_hms %>% hour

UsersInEachHour <- df %>% count(TimeInHour)

library(ggplot2)
p<-ggplot(data=UsersInEachHour, aes(x=TimeInHour, y=n)) +
  geom_bar(stat="identity", fill="black")+
  xlab("Hour of Day") + ylab("Number of Visitors")+
  geom_text(aes(label=n), vjust=1.6, color="white", size=3.5)+
  theme_minimal()

ggsave("Busy-Hours-R.png", p, width=5.56, height=5.35, units="in", dpi="screen")
