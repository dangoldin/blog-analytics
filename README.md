# Blog Analysis

I run a Jekyll blog at [http://dangoldin.com](http://dangoldin.com) and have been blogging actively since 2013 and this is my attempt to track and analyze my writing over time.

The Python scripts goes through the entire directory and the R script provides some visualization.

```
# For simple CSV without the actual text. I load this into MySQL for analysis. 
~ python analyze.py ~/code/blog.dangoldin.com/_posts /tmp/out.csv text

# To feed into the analyze.R script.
~ python analyze.py ~/code/blog.dangoldin.com/_posts /tmp/out-full.csv
```

## Queries

```
CREATE USER 'stats_user'@'%' IDENTIFIED BY 'XYZ';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX,CREATE TEMPORARY TABLES,CREATE VIEW,SHOW VIEW ON stats.* TO 'stats_user'@'%';

CREATE USER 'stats_read'@'%' IDENTIFIED BY 'ABC';
GRANT SELECT ON stats.* TO 'stats_read'@'%';

create table blog_post (
    ymd date not null,
    slug varchar(200) not null,
    title varchar(200) not null,
    keywords varchar(1000) not null,
    description varchar(1000) not null,
    tags varchar(200) not null,
    num_chars int not null,
    num_text_words int not null,
    num_text_description int not null,
    num_keywords int not null,
    num_tags int not null,
    num_images int not null,
    num_links int not null,
    unique key (ymd, slug)
);

LOAD DATA LOCAL INFILE '/home/dan/code/blog-analytics/out.csv'
  REPLACE INTO TABLE blog_post
    FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 LINES
    (title,tags,keywords,description,num_chars,num_text_words,num_text_description,num_keywords,num_tags,num_images,num_links,ymd,slug);

SELECT
  UNIX_TIMESTAMP(ymd) AS "time",
  num_chars
FROM blog_post
ORDER BY UNIX_TIMESTAMP(ymd);

SELECT
  UNIX_TIMESTAMP(date_format(ymd, '%Y-%m-01')) AS "time",
  avg(num_chars) as average_monthly_chars
FROM blog_post
GROUP BY time
ORDER BY time
```
