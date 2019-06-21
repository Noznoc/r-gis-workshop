age <- read_csv("./data/age.csv") # https://www12.statcan.gc.ca/census-recensement/2016/dp-pd/dt-td/Lp-eng.cfm?LANG=E&APATH=3&DETAIL=0&DIM=0&FL=A&FREE=0&GC=0&GID=0&GK=0&GRP=1&PID=0&PRID=10&PTYPE=109445&S=0&SHOWALL=0&SUB=0&Temporal=2016&THEME=115&VID=0&VNAMEE=&VNAMEF=
youth <- c("0 to 14 years","15 to 19 years","20 to 24 years")
filter_youth <- filter(age, `DIM: Age (in single years) and average age (127)` %in% youth)
adult <- c("25 to 29 years","30 to 34 years","35 to 39 years","40 to 44 years","45 to 49 years","50 to 54 years", "55 to 59 years", "60 to 64 years", "65 years and over")
filter_adult <- filter(age, `DIM: Age (in single years) and average age (127)` %in% adult)

youth_final <- filter_youth %>%
  group_by(`GEO_CODE (POR)`) %>%
  summarise(total_youth=sum(`Dim: Sex (3): Member ID: [1]: Total - Sex`),total_y_male=sum(`Dim: Sex (3): Member ID: [2]: Male`), total_y_female=sum(`Dim: Sex (3): Member ID: [3]: Female`))

adult_final <- filter_adult %>%
  group_by(`GEO_CODE (POR)`) %>%
  summarise(total_adult=sum(`Dim: Sex (3): Member ID: [1]: Total - Sex`),total_a_male=sum(`Dim: Sex (3): Member ID: [2]: Male`), total_a_female=sum(`Dim: Sex (3): Member ID: [3]: Female`))

test <- left_join(youth_final, adult_final, by = c("GEO_CODE (POR)","GEO_CODE (POR)"))
test_census <- left_join(census, test, by = c("GEO_CODE (POR)","GEO_CODE (POR)"))

write_csv(test_census, "./data/census_variables_2.csv")