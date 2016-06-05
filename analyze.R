install.packages("ggplot2")
install.packages("grid")
install.packages("gridExtra")
install.packages("reshape")
install.packages("scales")
install.packages("lattice")
install.packages("ggthemes")
install.packages("table")
install.packages("dplyr")
install.packages('ggthemes')

library(ggplot2)
library(grid)
library(gridExtra)
library(reshape)
library(scales)
library(lattice)
library(ggthemes)
library(data.table)
library(dplyr)
library(ggthemes)

df = read.csv("/tmp/out.csv", header=TRUE)
df$date_new <- as.Date(df$date , "%Y-%m-%d")
df$date_month <- format(df$date_new, "%Y-%m")
df$date_week <- format(df$date_new, "%Y-%W")
df$date_year <- format(df$date_new, "%Y")
df$dow <- weekdays(as.Date(df$date))

names(df)

ggplot(data=df, aes(x=date_new, y=num_text_words)) +
  geom_bar(stat="identity", position="identity") +
  theme_few() + scale_colour_few() +
  xlab('Date') +
  ylab('Num words') +
  ggtitle("Number of words") +
  theme(legend.title=element_blank())

ggplot(data=df, aes(x=num_images, y=num_links)) +
  geom_point(size=1) +
  theme_few() + scale_colour_few()

by_month <- group_by(df, date_month)
by_month_summary <- summarise(by_month,
  count = n(),
  num_words = sum(num_text_words, na.rm = TRUE),
  avg_words = mean(num_text_words, na.rm = TRUE))

ggplot(by_month_summary, aes(date_month, num_words)) +
  geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
  theme_few() + scale_colour_few() +
  theme(legend.position="none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

by_week <- group_by(df, date_week)
by_week_summary <- summarise(by_week,
  count = n(),
  num_words = sum(num_text_words, na.rm = TRUE),
  avg_words = mean(num_text_words, na.rm = TRUE))

ggplot(by_week_summary, aes(date_week, num_words)) +
  geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
  theme_few() + scale_colour_few() +
  theme(legend.position="none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

by_dow <- group_by(df, dow)
by_dow_summary <- summarise(by_dow,
  count = n(),
  num_words = sum(num_text_words, na.rm = TRUE),
  avg_words = mean(num_text_words, na.rm = TRUE))

ggplot(by_dow_summary, aes(dow, count)) +
  geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
  theme_few() + scale_colour_few() +
  theme(legend.position="none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

by_dow_year <- group_by(df, dow, date_year)
by_dow_year_summary <- summarise(by_dow_year,
  count = n(),
  num_words = sum(num_text_words, na.rm = TRUE),
  avg_words = mean(num_text_words, na.rm = TRUE))

ggplot(by_dow_year_summary, aes(x=date_year, y=count, group=dow, color=dow)) +
  geom_line() +
  theme_few() + scale_colour_few() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

ggplot(by_dow_year_summary, aes(x=dow, y=count, group=date_year, color=date_year)) +
  geom_line() +
  theme_few() + scale_colour_few() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Posts over time (day? week? month? year?)

# Words over time

# Links/images over time

# Correlations between links/images?

# Keywords

# Avg length over time

# Day of week

