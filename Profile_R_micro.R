#Use microbenchmark
require(microbenchmark)

saveSubset <- function(txtFile, propSave){
  txt <- readLines(paste0("C:/coursera/DataScientist/10-Project/app/texts/", txtFile), 
                   skipNul=TRUE, encoding = "UTF-8")
  txt <- sapply(txt,function(row) iconv(row, "latin1", "ASCII", sub=""))
  set.seed(1952)
  txt <- txt[rbinom(length(txt)*propSave, length(txt), .5)]
  write.csv(txt, file = paste0("C:/coursera/DataScientist/10-Project/app/subset/", 
                               paste0(txtFile, ".csv")), row.names = FALSE)
}

saveSubsetRODBC <- function(tblName, propSave){
  require(RODBC)
  #Get connection
  con <- odbcDriverConnect("driver={SQL Server Native Client 11.0}; 
                           server=WBC201-2\\SQLEXPRESS; database=TextDB; 
                           trusted_connection=yes;")
  #Create query and get number of rec
  txt.query <- paste0("SELECT COUNT(*) FROM ", tblName, ";")
  txt.count <- as.integer(sqlQuery(con, txt.query))
  txt.ToGet <- as.data.frame(rbinom(txt.count * propSave, txt.count, 0.5))
  colnames(txt.ToGet) <- c("Id")
  #Truncate table that has Ids to join with
  tbl.ToTrunc = paste0(tblName, "_Ids")
  txt.query = paste0("TRUNCATE TABLE ", tbl.ToTrunc, ";")
  txt.query.out <- sqlQuery(con, txt.query)
  #Save Ids to trunc
  #Note that the rownames parameter below is necessary to keep from saving row names in the data frame
  sqlSave(con, as.data.frame(txt.ToGet), table = tbl.ToTrunc, append = TRUE, rownames = FALSE)
  #Get the lines from MS SQL to save to folder
  txt.query = paste0("SELECT TextData FROM ", tblName, " INNER JOIN ", 
                     tbl.ToTrunc, " ON ", tblName, ".Id = ", tbl.ToTrunc, ".Id;")
  txt.ToSave <- sqlQuery(con, txt.query)
  txt.ToSave <- sapply(txt.ToSave,function(row) iconv(row, "latin1", "ASCII", sub=""))
  #Write file out
  if (tblName=="Blogs") txt.FileName = "en_US.blogs.txt"
  if (tblName=="News") txt.FileName = "en_US.news.txt"
  if (tblName=="Twitter") txt.FileName = "en_US.twitter.txt"
  write.csv(txt.ToSave, file = paste0("C:/coursera/DataScientist/10-Project/app/subset/", 
                                      paste0(txt.FileName, ".csv")), row.names = FALSE)
  close(con)
}

microbenchmark(
  saveSubset("en_US.blogs.txt", 0.01),
  saveSubsetRODBC("Blogs", 0.01)
)
# Unit: seconds
# expr                                min       lq        mean     median   uq       max        neval cld
# saveSubset("en_US.blogs.txt", 0.01) 44.314638 44.686058 45.20307 45.11347 45.39922 51.25667   100   b
# saveSubsetRODBC("Blogs", 0.01)      3.575395  3.850396  15.41914 25.05276 25.51052 28.28583   100   a 
# > 


