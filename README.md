# NOAA_weather_data_wrangling
Taking some NOAA weather data and making it usable for machine learning.

[NOAA has some nice open-access weather data](https://www.ncdc.noaa.gov/cdo-web/datatools).  In this case, I'm taking the Central Park and La Guardia weather stations, and making it usable for some machine learning.  This means getting data where there aren't a lot of missing values, filling in missing values, and saving that dataset for later use.  To get more recent data, you could re-download it from NOAA and re-run this code.  You could also use their [API](https://www.ncdc.noaa.gov/cdo-web/webservices/v2) to get the data in a more streaming matter (or get lots more data).
