setwd("~/git/baseball-exercise")

library(DBI)
library(RPostgres)
library(data.table)

url <- "https://web.archive.org/web/20230304031154/https://github.com/chadwickbureau/baseballdatabank/archive/master.zip"
destination <- "./downloads/v2021.zip"
curl::curl_download(url = url, destfile = destination) 
utils::unzip(zipfile = destination, 
             exdir = "./downloads")

# create a connection to the local postgres database
con <- DBI::dbConnect(
  drv = RPostgres::Postgres(),
  dbname = "baseball",
  host = "localhost",
  port = 5432,
  user = "postgres",
  password = "password123")

# Create tables in the Db and upload the csv data to the tables, to make be able
# to query the data from Db later in this exercise.
# Also set indexes on the primary key columns of the tables, to have optimal 
# performance in query by ID and joins on ID.

rs <- DBI::dbSendStatement(conn = con, statement = '
  CREATE TABLE IF NOT EXISTS players (
    playerID VARCHAR ( 50 ) PRIMARY KEY,
    birthYear INT,
    birthMonth INT,
    birthDay INT,
    birthCountry VARCHAR ( 255 ),
    birthState VARCHAR ( 255 ),
    birthCity VARCHAR ( 255 ),
    deathYear INT,
    deathMonth INT,
    deathDay INT,
    deathCountry VARCHAR ( 255 ),
    deathState VARCHAR ( 255 ),
    deathCity VARCHAR ( 255 ) ,
    nameFirst VARCHAR ( 255 ) ,
    nameLast VARCHAR ( 255 ),
    nameGiven VARCHAR ( 255 ),
    weight INT,
    height INT,
    bats CHAR ( 1 ),
    throws CHAR ( 1 ),
    debut DATE,
    finalGame DATE,
    retroID VARCHAR ( 50 ),
    bbrefID VARCHAR ( 50 )
  );'
)
DBI::dbClearResult(rs)

rs <- DBI::dbSendStatement(conn = con, statement = '
  CREATE INDEX idx_players_playerid 
  ON players(playerID);'
)
DBI::dbClearResult(rs)


rs <- DBI::dbSendStatement(conn = con, statement = '
  CREATE TABLE IF NOT EXISTS salaries (
    playerID VARCHAR ( 50 ) NOT NULL,
    yearID INT,
    teamID VARCHAR ( 50 ),
    lgID VARCHAR ( 50 ),
    salary INT
  );'
)
DBI::dbClearResult(rs)

rs <- DBI::dbSendStatement(conn = con, statement = '
  CREATE INDEX idx_salaries_player_year_team 
  ON salaries(playerid, yearid, teamid);'
)
DBI::dbClearResult(rs)


rs <- DBI::dbSendStatement(conn = con, statement = '
  CREATE TABLE IF NOT EXISTS fieldings (
    playerID VARCHAR ( 50 ) NOT NULL,
    yearID INT,
    stint INT,
    teamID VARCHAR ( 50 ),
    lgID VARCHAR ( 50 ),
    POS VARCHAR ( 2 ),
    G INT,
    GS INT,
    InnOuts INT,
    PO INT,
    A INT,
    E INT,
    DP INT,
    PB INT,
    WP INT,
    SB INT,
    CS INT,
    ZR INT
  );'
)
DBI::dbClearResult(rs)

rs <- DBI::dbSendStatement(conn = con, statement = '
  CREATE INDEX idx_fieldings_playerid 
  ON fieldings(playerID);'
)
DBI::dbClearResult(rs)

# Ingest the downloaded data into the DB

players <- data.table::fread(input = "./downloads/baseballdatabank-master/core/People.csv")
players <- data.table::setnames(players, tolower(colnames(players)))
DBI::dbAppendTable(conn = con, 
                   name = "players",
                   value = unique(players, by = "playerid"))

salaries <- data.table::fread(input = "./downloads/baseballdatabank-master/core/Salaries.csv")
salaries <- data.table::setnames(salaries, tolower(colnames(salaries)))
DBI::dbAppendTable(conn = con, 
                   name = "salaries",
                   value = salaries)


fieldings <- data.table::fread(input = "./downloads/baseballdatabank-master/core/Fielding.csv")
fieldings <- data.table::setnames(fieldings, tolower(colnames(fieldings)))
DBI::dbAppendTable(conn = con, 
                   name = "fieldings",
                   value = fieldings)
