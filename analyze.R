list.of.packages <- c("ggplot2","grid","gridExtra","reshape","scales","lattice","ggthemes","table","dplyr","ggthemes","tm","SnowballC","wordcloud")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.us.r-project.org")

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

df = read.csv("/tmp/out-full.csv", header=TRUE)
df$date_new <- as.Date(df$ymd , "%Y-%m-%d")
df$date_month <- format(df$date_new, "%Y-%m")
df$date_week <- format(df$date_new, "%Y-%W")
df$date_year <- format(df$date_new, "%Y")
df$dow <- paste(format(df$date_new, "%w"), weekdays(as.Date(df$date))) # deal with sorting later

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

plot_has <- function(df, str) {
  str_esc = paste(list(str, "[ \\.]"), collapse='')
  df$has_str <- grepl(str_esc, df$text, ignore.case = TRUE)  * 1
  p <- ggplot(df, aes(date_year, has_str)) + geom_bar(stat="identity") +
    xlab("Year") + ylab(str) + ggtitle(paste(list("Mentions of", str, "by Year"), collapse=" "))
  ggsave(filename=paste(list("/tmp/mentions-",str,".png"), collapse=''), plot=p)
}

plot_by <- function(df, col_names, col1lbl, col2lbl) {
  fn <- paste(col_names, collapse = '-')
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
    p1 <- ggplot(by_col_summary, aes_string(x=first_col, y="count", group=second_col, color=second_col)) +
      geom_line() +
      theme_few() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      xlab(col1lbl) + ylab(col2lbl) + theme(legend.title = element_blank())
    p2 <- ggplot(by_col_summary, aes_string(x=second_col, y="count", group=first_col, color=first_col)) +
      geom_line() +
      theme_few() +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      xlab(col2lbl) + ylab(col1lbl) + theme(legend.title = element_blank())
    ggsave(filename=paste(list("/tmp/", fn, "-plot1.png"), collapse=''), plot=p1)
    ggsave(filename=paste(list("/tmp/", fn, "-plot2.png"), collapse=''), plot=p2)
  } else {
    p1 <- ggplot(by_col_summary, aes_string(first_col, "count")) +
      geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
      theme_few() + scale_colour_few() +
      theme(legend.position="none") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      xlab(col1lbl) + ylab("Num Posts") + ggtitle("Posts over time")
    p2 <- ggplot(by_col_summary, aes_string(first_col, "num_words")) +
      geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
      theme_few() + scale_colour_few() +
      theme(legend.position="none") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      xlab(col1lbl) + ylab("Num Words") + ggtitle("Words over time")
    p3 <- ggplot(by_col_summary, aes_string(first_col, "num_links")) +
      geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
      theme_few() + scale_colour_few() +
      theme(legend.position="none") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      xlab(col1lbl) + ylab("Num Links") + ggtitle("Links over time")
    p4 <- ggplot(by_col_summary, aes_string(first_col, "num_tags")) +
      geom_bar(stat="identity", aes(size = 1), alpha = 1/2) +
      theme_few() + scale_colour_few() +
      theme(legend.position="none") +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
      xlab(col1lbl) + ylab("Num Tags") + ggtitle("Tags over time")
    # multiplot(p1, p2, p3, p4, cols=2)
    ggsave(filename=paste(list("/tmp/", fn, "-plot-count.png"), collapse=''), plot=p1)
    ggsave(filename=paste(list("/tmp/", fn, "-plot-words.png"), collapse=''), plot=p2)
    ggsave(filename=paste(list("/tmp/", fn, "-plot-links.png"), collapse=''), plot=p3)
    ggsave(filename=paste(list("/tmp/", fn, "-plot-tags.png"), collapse=''), plot=p4)
  }
}

plot_wordcloud <- function(text_col, fn) {
  corpus <- Corpus(VectorSource(text_col))
  corpus <- tm_map(corpus, PlainTextDocument)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeWords, stopwords('english'))
  # corpus <- tm_map(corpus, stemDocument)
  corpus <- tm_map(corpus, removeWords, c('the', 'this', stopwords('english')))
  corpus <- iconv(corpus, to = "utf-8")
  corpus <- (corpus[!is.na(corpus)])

  png(fn, width=2, height=2, units="in", res=300)
  wordcloud(corpus, max.words = 100, random.order = FALSE, scale=c(1,.5))
  dev.off()
}

# General stats
length(df$text)
sum(df$num_links)
sum(df$num_tags)
sum(df$num_keywords)
sum(df$num_text_description)
sum(df$num_text_words)

# Posts over time (day? week? month? year?)
plot_by(df, list("date_new"), "Date", "")
plot_by(df, list("date_week"), "Week", "")
plot_by(df, list("date_month"), "Month", "")
plot_by(df, list("date_year"), "Year", "")
plot_by(df, list("dow"), "Day of Week", "")

# Correlations between links/images?
links_vs_images <- ggplot(data=df, aes(x=num_images, y=num_links)) +
  geom_point(size=1) +
  theme_few() + scale_colour_few() +
  xlab("Num Images") + ylab("Num Links") + ggtitle("Links vs Images")

ggsave(filename="/tmp/links-vs-images.png", plot=links_vs_images)

# DOW vs Date Year
plot_by(df, list("dow", "date_year"), "Day of Week", "Year")

# Word Clouds
# TODO: Make this variable
plot_wordcloud(df$keywords, "/tmp/wordcloud.png")
plot_wordcloud(df[df$date_year == "2013", ]$keywords, "/tmp/wordcloud_2013.png")
plot_wordcloud(df[df$date_year == "2014", ]$keywords, "/tmp/wordcloud_2014.png")
plot_wordcloud(df[df$date_year == "2015", ]$keywords, "/tmp/wordcloud_2015.png")
plot_wordcloud(df[df$date_year == "2016", ]$keywords, "/tmp/wordcloud_2016.png")
plot_wordcloud(df[df$date_year == "2017", ]$keywords, "/tmp/wordcloud_2017.png")
plot_wordcloud(df[df$date_year == "2018", ]$keywords, "/tmp/wordcloud_2018.png")
plot_wordcloud(df[df$date_year == "2019", ]$keywords, "/tmp/wordcloud_2019.png")
plot_wordcloud(df[df$date_year == "2020", ]$keywords, "/tmp/wordcloud_2020.png")

# TODO: Drive company and language from single list

# Company mentions
plot_has(df, "Google")
plot_has(df, "Facebook")
plot_has(df, "Twitter")
plot_has(df, "Microsoft")
plot_has(df, "Uber")
plot_has(df, "Snapchat")
plot_has(df, "Tesla")
plot_has(df, "Lyft")
plot_has(df, "Apple")

# Language
plot_has(df, "Java")
plot_has(df, "Python")
plot_has(df, "SQL")
plot_has(df, "JavaScript")
plot_has(df, "Scala")

# Company mentions
df$has_google <- grepl("Google[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_facebook <- grepl("Facebook[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_twitter <- grepl("Twitter[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_microsoft <- grepl("Microsoft[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_uber <- grepl("Uber[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_snapchat <- grepl("Snapchat[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_tesla <- grepl("Tesla[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_lyft <- grepl("Lyft[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_apple <- grepl("Apple[ \\.]", df$text, ignore.case = TRUE)  * 1

# Language mentions
df$has_java <- grepl("Java[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_python <- grepl("Python[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_sql <- grepl("SQL[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_javascript <- grepl("JavaScript[ \\.]", df$text, ignore.case = TRUE)  * 1
df$has_scala <- grepl("Scala[ \\.]", df$text, ignore.case = TRUE)  * 1

df_year <- as.data.frame(df %>% group_by(date_year) %>% summarise(Google = sum(has_google, na.rm = TRUE),
                                                                  Facebook = sum(has_facebook, na.rm = TRUE),
                                                                  Twitter = sum(has_twitter, na.rm = TRUE),
                                                                  Microsoft = sum(has_microsoft, na.rm = TRUE),
                                                                  Snapchat = sum(has_snapchat, na.rm = TRUE),
                                                                  Uber = sum(has_uber, na.rm = TRUE),
                                                                  Lyft = sum(has_lyft, na.rm = TRUE),
                                                                  Tesla = sum(has_tesla, na.rm = TRUE),
                                                                  Apple = sum(has_apple, na.rm = TRUE),
                                                                  Java = sum(has_java, na.rm = TRUE),
                                                                  Python = sum(has_python, na.rm = TRUE),
                                                                  SQL = sum(has_sql, na.rm = TRUE),
                                                                  JavaScript = sum(has_javascript, na.rm = TRUE),
                                                                  Scala = sum(has_scala, na.rm = TRUE)))

dfm_companies <- melt(df_year, id.vars = "date_year", measure.vars = c("Google", "Facebook", "Twitter", "Microsoft", "Snapchat", "Uber", "Tesla", "Lyft", "Apple"))

p <- ggplot(dfm_companies, aes(x = date_year, y = value, color = variable, group=variable)) +
  geom_line() + theme_few() +
  theme(legend.title = element_blank()) +
  xlab("Year") + ylab("Num Posts") + ggtitle("Company Mentions by Year")
ggsave(filename="/tmp/company-mention.png", plot=p)

dfm_languages <- melt(df_year, id.vars = "date_year", measure.vars = c("Java", "Python", "SQL", "JavaScript", "Scala"))

p <- ggplot(dfm_languages, aes(x = date_year, y = value, color = variable, group=variable)) +
  geom_line() + theme_few() +
  theme(legend.title = element_blank()) +
  xlab("Year") + ylab("Num Posts") + ggtitle("Language Mentions by Year")
ggsave(filename="/tmp/language-mention.png", plot=p)
