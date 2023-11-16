setwd("~/git/baseball-exercise")

library(DBI)
library(RPostgres)
library(aws.s3)

# this file aims to demostrate some simple data analysis, to prove that the db
# is working and the data model is correct. All excercises taken from:
# https://gist.github.com/bcm/026b4b2d4499001979970b4f23b4183d
# 
# 1. Calculate the average salary for infielders and pitchers for each year.
# 
# after the result has been quries, it will be uploaded to an S3 bucket. 

average_salaries <- DBI::dbGetQuery(conn = con, query = "
 WITH outfield_salaries AS (
	SELECT 
		s.yearid 			       AS year,
		round(avg(s.salary)) AS salary
	FROM salaries s 
	JOIN fieldings f on (s.playerid = f.playerid AND s.yearid = f.yearid)
	WHERE f.pos = 'OF'
	GROUP BY s.yearid, f.pos
), pitching_salaries AS (
	SELECT 
		s.yearid 			       AS year,
		round(avg(s.salary)) AS salary
	FROM salaries s 
	JOIN fieldings f on (s.playerid = f.playerid AND s.yearid = f.yearid)
	WHERE f.pos = 'P'
	GROUP BY s.yearid, f.pos
)
SELECT 
	os.year, 
	os.salary             AS fielding,
	ps.salary             AS pitching
from outfield_salaries os
join pitching_salaries ps on os.year = ps.year ")

# Upload he file the queried data to an S3 bucket, as requested in the exercise. 

Sys.setenv("AWS_ACCESS_KEY_ID" = "baseball_access_key",
           "AWS_SECRET_ACCESS_KEY" = "baseball_secret_key",
           "AWS_DEFAULT_REGION" = "baseball_aws_region")

write.csv(x = average_salaries, file = "./uploads/average_salaries.csv", row.names = FALSE)

aws.s3::put_object(file = "./uploads//average_salaries.csv",
                   object = "average_salaries.csv",
                   bucket = "baseball_bucket")
