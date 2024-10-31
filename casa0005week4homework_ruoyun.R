#load the package
library(sf)
library(here)
library(readr)
library(dplyr)
library(tidyr)
library(janitor)
library(tmap)
library(tmaptools)

print('hello')
#read data and check it
#read the csv data
GIIData <- read.csv(here::here("GISS_ruoyun", "gii_GLOBAL.csv"), header = TRUE, sep = ",", encoding = "latin1")
GIIData <- read_csv(here::here("GISS_ruoyun", "gii_GLOBAL.csv"), locale = locale(encoding = "latin1"),na = "na")
#read the geojson data
GlobalData <- st_read(here::here("GISS_ruoyun", "World_Countries_(Generalized)_9029012925078512962.geojson"))
#check the csv data 
class(GIIData)
head(GIIData)
#make all the numbers are read in as numeric
GIIData <- GIIData %>%
  mutate(
    year_2010 = as.numeric(year_2010),
    year_2011 = as.numeric(year_2011),
    year_2012 = as.numeric(year_2012),
    year_2013 = as.numeric(year_2013),
    year_2014 = as.numeric(year_2014),
    year_2015 = as.numeric(year_2015),
    year_2016 = as.numeric(year_2016),
    year_2017 = as.numeric(year_2017),
    year_2018 = as.numeric(year_2018),
    year_2019 = as.numeric(year_2019)
  )
#make sure numeric data haven’t been read in as text or other variables
Datatypelist <- GIIData %>% 
  summarise_all(class) %>%
  pivot_longer(everything(), 
               names_to="All_variables", 
               values_to="Variable_class")
Datatypelist
#check the geojson data
head(GlobalData)


#caluculate new data
#new column with the difference in inequality between 2010 and 2019
GIIData <- GIIData %>%
mutate(difference_10_19=(year_2019 - year_2010))
head(GIIData)

#merge the attribute data
#clean up all of names
GIIData <- clean_names(GIIData)
GlobalData <- clean_names(GlobalData)
#check the column name of GlobalData
colnames(GlobalData)
#merge data
merged_data <- left_join(GlobalData,GIIData,by=c("country"="country"))
print(st_geometry_type(merged_data))


#plot the map
tmap_mode("plot")
tm_shape(merged_data) +
  tm_polygons("difference_10_19", 
              title = "difference_10_19", 
              style = "quantile", 
              palette = "Blues") +
  tm_layout(main.title = "GII between 2010 and 2019", 
            legend.outside = TRUE)

