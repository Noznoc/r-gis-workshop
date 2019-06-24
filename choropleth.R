# This is a R workshop on leveraging geospatial data and packages!

# June 25, 2019

# By Julia Conzon
# CDO's Data Science Team

# Set work directory.
setwd("U:/SP-PS/DMD/Data Science/02-OtherAnalyticsProjects/2019-Geo/3-Disseminate/Seminars/Session 2/r-choropleth")

# If you don't not have the following packages, then install them.
# install.packages("tidyverse","tmap", "sf")

# Load the dependencies (packages)
library(tidyverse) # for data piping
library(tmap) # for quick static and interactive maps
library(ggplot2)
library(sf) # for geospatial data reading and writing

# To learn more about the libraries, run this command in the console.
??rgdal 

# Load the data.
gb <- st_read("./data", "lcsd000b16a_simplified") # read census subdivisions, a Statistics Canada geographic boundary
census <- read_csv("./data/census_variables.csv") # read census variables/attributes
shelters <- read_csv("./data/shelters.csv") # vancouver shelters, retrieved here: http://hsa-bc.ca/shelters/shelter-directory/

#Prepare data.
shelters_sf <- st_as_sf(shelters, coords = c("longitude", "latitude"), crs = 4326) # cast shelter coordinate locations into a simple feature

# Under your Environment tab, you should now have three data files visible within a table view.
# These files are stored in your RAM, so don't forgot to manage your data usage to avoid exceeding your RAM!

# Review and explore your data.
View(census) # see the census csv as a R data frame in a new tab
View(gb) # see the census subdivisions (CSDs) attribute table as a data frame in a new tab
st_geometry(gb) # see the summary CSDs geometry data
View(st_geometry(gb)) # see all geometry
View(shelters_sf) # see the Vancouver shelters as a data frame in a new tab
st_geometry(shelters_sf) # see the summary shelter geometry
View(st_geometry(shelters_sf)) # see all shelters

# Notice how the projection for db is different than the shelters?
# You can transform your data to a different projection.
# Since the data are simple features, we use the sf package.
shelters_sf <- st_transform(shelters_sf, "+proj=lcc +datum=NAD83") # transform to the longlat

# Let's plot the geospatial data on a map. 
# 1) This plot shows all CSDs and colours by province
gb %>% 
  select(PRUID) %>% 
  plot(key.pos = NULL, graticule = TRUE, main = "Census Subdivisions (CSDs)")

# 2) This plot shows all the Vancouver shelters and colours by type of shelter
shelters_sf %>% 
  select(type) %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84") %>% 
  plot(key.pos = NULL, graticule = TRUE, main = "Vancouver Shelters")

# 3) This plot filters the data to British Columbia, and then shows the following:
# Economic Regions (ER) and Census Metropolitan Areas (CMA) 
gb %>% 
  select(ERNAME, CMANAME) %>% 
  filter(gb$PRUID == 59) %>% 
  plot(key.pos = NULL, graticule = TRUE, main = "Census Subdivisions (CSDs)")

# Yes, the maps are not the prettiest, but the point here is to familiarize yourself with the data!
# Sometimes your Viewer will lag or crash R if the geometry of the data is too complex.
# R packages have tools to simplify the geometry to reduce data size and allow for data rendering.
# For this workshop, gb was already simplified using the mapshaper.org. Since gb is public data, using an external tool wasn't an issue.
# Also, to save space in memory, it's best to remove the plot afterwards.

# Let's plot both variables together
# You can learn more about the projection of the data here: https://www150.statcan.gc.ca/n1/pub/92-195-x/2011001/other-autre/mapproj-projcarte/m-c-eng.htm

## TO DO SHOW HOW PLOTTING THEM TOGETHER DOESN'T WORK 
test <- ggplot(data = gb) +
  geom_sf() +
  geom_sf(data = shelters_sf, fill = "red")

# Next, let's link the census data to the CSDs with the tidyverse package
# We won't need to link via spatial join because both the gb and census data have  CSD unique identifiers variable (gd's CSDUID and census' GEO_CODE (POR)) that can be matched.
# Sometimes you will have to convert your data to different types to compute the linkage.
# Using the as.___ function is how you cast your data variables to different types.
census$`GEO_CODE (POR)` <- as.factor(census$`GEO_CODE (POR)`) # in this case, we are casting the census GC_CODE (POR) variable to a factor to match the CSDUID variable type in gb
gb <- left_join(gb, census, by = c("CSDUID" = "GEO_CODE (POR)")) # join the data frames together by the linking variables

# The join links the gb attribute data's CSDUIDs to the CSDUIDs in the census data frame.
# "Left" returns all records from the left table (i.e., gb) and only those that match on the right table (i.e., census) 

# As mentioned above, working with geospatial data is memory intensive.
# For this workshop we will filter our data to a provincial level to avoid software crashes!
# Different geospatial data types (e.g., geojson, geopackages, shapefiles) compress the data differently.
# Depending on the size of your data, decide what data file type (or spatial database) is best to use.
# You can also simplify the geometry, which many R spatial packages support, or you can use external tools.
gb_filtered <- gb[gb$PRUID == 59,] # 59 is British Columbia's province code

# You could also do:
gb_filtered <- gb %>% filter(gb$PRUID == 59)

# Point here is that there are different ways to accomplish the same task, it depends on what R packages you are using.
# Certain R packages are recommended, like tidyverse, because they are computationally more efficient than others (e.g., base R).

# Let's now create the variables we want to be visualized.
# We establish the data variable and name as their own R variable to generalize the script.
# You will see how this is useful as you play around with visualizing different data variables.
variable <- gb_filtered$'Median Age' # the ratio/normalized value that will be visible on the map
variable_name <- "Median Age" # the title that will be printed/visualized on the map output

# Review the distribution of the data to determine the classification method and number of bins.
hist(variable, main=paste("Distribution of", variable_name), xlab=variable_name)

# Finally, let's use tmap to create the choropleth visualization!
# The tmap package utilizes various popular R spatial packages like sp, sf and leaflet.
# It is easy to use for classifying your data and selecting a colour palette to link to the classification scheme.
# The classification methods are defined by the classInterval package: https://www.rdocumentation.org/packages/classInt/versions/0.3-3/topics/classIntervals.
# The function calling is similar to ggplot. Each function you call adds a visual funtionality or layer to the map

# You have to define whether to set tmap in plot (static) or view (interactive) map mode.
tmap_mode("plot") 

tm_shape(gb_filtered) + # the geographic data to be added as it's own map layer
  # tm_bubbles(variable_name) +
  tm_fill(variable_name, palette="BuPu", style="quantile", n=6, title=variable_name, id="name") +
  tm_borders(col="grey25", alpha=.5) +
  tm_scale_bar(position = c("right", "top"))

# You just created your first choropleth map!
# Now let's add the shelter layer, but let's first filter our data to Greater Vancouver.
gb_vancouver <- gb[gb$CDUID == 5915,]

tm_shape(gb_vancouver) +
  tm_fill(variable_name, palette="BuPu", style="cont", n=6, title=variable_name, id="name")+
  tm_borders(col="grey25", alpha=.5) +
tm_shape(shelters_sf) +
  tm_dots("type") +
tm_scale_bar(position = c("right", "top"))

# So far we have worked with predefined variables, but if you want to normalize your code in R, you can use the following method.
gb$youthPro <- (gb$`Total Youth (0-25)` / gb$`Population Count`) * 100

variable <- gb$youthPro
variable_name <- "youthPro"

# Now update the variable and variable_name to gb$youthPro

# If you want to save your data outputs, you can write them within your working directory.
st_write(gb_filtered, "bc.shp")