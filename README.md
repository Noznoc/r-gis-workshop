# Leveraging Geospatial Data in R: Choropleth Census Maps

A repo for a R workshop.

# Installation

If you are familiar with git, clone the repo using GitBash.

If you are not familiar with git, you can download the code and unzip it to access the files.

It is recommended for the workshop to store the downloaded/cloned session2-r-choropleth folder in your C drive.

# Files

- **`choropleth-notebook.Rmd` is the file for the workshop**
  - `choropleth-notebook.html` is a HTML output of `choropleth-notebook.Rmd`
- `/data` has all data necessary for the workshop, including the raw data that was manipulated for the workshop
  - `census_variables.csv` is the file with extracted Census variables from the Census 2016 Profile and from the the `98-400-X2016004_ENG_CSV` data table
  - `lcsd000b16a_simplified.dbf`, `lcsd000b16a_simplified.prj`, `lcsd000b16a_simplified.shp` and `lcsd000b16a_simplified.shx` are the files for the Census Subdivision (CSD) shapefile
  - `lcsd000b16a_simplified.json` is the same as the shapefile, but in a different geospatial data format
  - `shelters.csv` has all shelters from Vancouver (January 2018)
  - `vancouver_shelters_2018.pdf` is the original file the shelters were extracted from
- `census.R` is an example of a R script for manipulating the 98-400-X2016004_ENG_CSV Census 2016 data table

# Author
Julia Conzon (julia.conzon@hsdc-hrdcc.gc.ca)
