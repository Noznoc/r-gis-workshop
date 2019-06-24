# This is an example of manipulating a Census data table for use in R.
# This Census data was retreived from: https://www12.statcan.gc.ca/census-recensement/2016/dp-pd/dt-td/Ap-eng.cfm?LANG=E&APATH=3&DETAIL=0&DIM=0&FL=A&FREE=0&GC=0&GID=0&GK=0&GRP=1&PID=109526&PRID=10&PTYPE=109445&S=0&SHOWALL=0&SUB=0&Temporal=2016&THEME=115&VID=0&VNAMEE=&VNAMEF=.

# The tidyverse package is needed to read and manipulate the data.
library("tidyverse")

# Read the census data into your R environment.
census <- read_csv("./data/98-400-X2016004_ENG_CSV/98-400-X2016004_English_CSV_data.csv")
census_variables <- read_csv("./data/census_variables.csv")

# For the workshop, we are defining youth as those 0-24.
youth <- c("0 to 14 years","15 to 19 years","20 to 24 years")
filter_youth <- filter(census, `DIM: Age (in single years) and average age (127)` %in% youth)

# The remainder are classified as adults.
adult <- c("25 to 29 years","30 to 34 years","35 to 39 years","40 to 44 years","45 to 49 years","50 to 54 years", "55 to 59 years", "60 to 64 years", "65 years and over")
filter_adult <- filter(census, `DIM: Age (in single years) and average age (127)` %in% adult)

# Sum up the counts of youth for each age range for each census geographic boundary (GEO_CODE (POR)).
youth_final <- filter_youth %>%
  group_by(`GEO_CODE (POR)`) %>%
  summarise(`Total Youth (0-24)`=sum(`Dim: Sex (3): Member ID: [1]: Total - Sex`))

# Do the same for the adults.
adult_final <- filter_adult %>%
  group_by(`GEO_CODE (POR)`) %>%
  summarise(`Total Adult (25+)`=sum(`Dim: Sex (3): Member ID: [1]: Total - Sex`),`Total Adult Males`=sum(`Dim: Sex (3): Member ID: [2]: Male`), `Total Adult Females`=sum(`Dim: Sex (3): Member ID: [3]: Female`))

# Now join the values together into the census_variable.csv.
joined <- left_join(youth_final, adult_final, by = c("GEO_CODE (POR)" = "GEO_CODE (POR)"))
census_variables$`GEO_CODE (POR)` <- as.character(census_variables$`GEO_CODE (POR)`)
census_final <- left_join(census_variables, joined, by = c("GEO_CODE (POR)" = "GEO_CODE (POR)"))

# Save the output as a csv for use in the workshop.
write_csv(census_final, "./data/census_variables.csv")