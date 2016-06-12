install.packages("ggplot2")
install.packages("grid")
install.packages("gridExtra")
install.packages("reshape")
install.packages("scales")
install.packages("lattice")
install.packages("ggthemes")
install.packages("table")
install.packages("dplyr")
install.packages("ggthemes")
install.packages("tm")
install.packages("SnowballC")
install.packages("wordcloud")

library(ggplot2)
library(grid)
library(gridExtra)
library(reshape)
library(scales)
library(lattice)
library(ggthemes)
library(dplyr)
library(ggthemes)
library(tm)
library(SnowballC)
library(wordcloud)

df = read.csv("/tmp/out.csv", header=TRUE)
df$date_new <- as.Date(df$date , "%Y-%m-%d")
df$date_month <- format(df$date_new, "%Y-%m")
df$date_week <- format(df$date_new, "%Y-%W")
df$date_year <- format(df$date_new, "%Y")
df$dow <- weekdays(as.Date(df$date))

# From http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/
# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

plot_by <- function(df, col_names) {
  dots <- lapply(col_names, as.symbol)
  by_col_summary <- df %>% group_by_(.dots=dots) %>% summarise(count = n(),
                                                        num_words = sum(num_text_words, na.rm = TRUE),
                                                        avg_words = mean(num_text_words, na.rm = TRUE),
                                                        num_keywords = sum(num_keywords, na.rm = TRUE),
                                                        avg_keywords = mean(num_keywords, na.rm = TRUE),
                                                        num_tags = sum(num_tags, na.rm = TRUE),
                                                        avg_tags = mean(num_tags, na.rm = TRUE),
                                                        num_links = sum(num_links, na.rm = TRUE),
                                                        avg_links = mean(num_links, na.rm = TRUE),
                                                        num_images = sum(num_images, na.rm = TRUE),
                                                        avg_images = mean(num_images, na.rm = TRUE)
                                                        )
  first_col <- as.String(col_names[1])
  if (length(col_names) > 1) {
    second_col <- as.String(col_names[2])
    ggplot(by_dow_year_summary, aes_string(x=first_col, y="count", group=second_col, color=second_col)) +
      geom_line() +
      theme_few() + scale_colour_few() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
  } else {
    p1 <- ggplot(by_col_summary, aes_string(first_col, "num_words")) +
      geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
      theme_few() + scale_colour_few() +
      theme(legend.position="none") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    p2 <- ggplot(by_col_summary, aes_string(first_col, "num_keywords")) +
      geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
      theme_few() + scale_colour_few() +
      theme(legend.position="none") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    p3 <- ggplot(by_col_summary, aes_string(first_col, "num_links")) +
      geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
      theme_few() + scale_colour_few() +
      theme(legend.position="none") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    p4 <- ggplot(by_col_summary, aes_string(first_col, "num_tags")) +
      geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
      theme_few() + scale_colour_few() +
      theme(legend.position="none") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    multiplot(p1, p2, p3, p4, cols=2)
  }
}

plot_by(df, list("date_new"))
plot_by(df, list("date_week"))
plot_by(df, list("date_month"))
plot_by(df, list("dow"))

plot_by(df, list("dow", "date_year"))
plot_by(df, list("date_year", "dow"))

ggplot(data=df, aes(x=num_images, y=num_links)) +
  geom_point(size=1) +
  theme_few() + scale_colour_few()

corpus <- Corpus(VectorSource(df$keywords))
corpus <- tm_map(corpus, PlainTextDocument)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeWords, stopwords('english'))
# corpus <- tm_map(corpus, stemDocument)
corpus <- tm_map(corpus, removeWords, c('the', 'this', stopwords('english')))

wordcloud(corpus, max.words = 100, random.order = FALSE, scale=c(1,.5))

corpus <- Corpus(VectorSource(df$tags))
corpus <- tm_map(corpus, PlainTextDocument)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeWords, stopwords('english'))
# corpus <- tm_map(corpus, stemDocument)
corpus <- tm_map(corpus, removeWords, c('the', 'this', stopwords('english')))

wordcloud(corpus, max.words = 100, random.order = FALSE, scale=c(1.5,0.5))


# Posts over time (day? week? month? year?)

# Words over time

# Links/images over time

# Correlations between links/images?

# Keywords

# Avg length over time

# Day of week

