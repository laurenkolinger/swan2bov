# swan2bov

Non-working matlab code to download slices of wave Hsig and Periods from [SWAN_Aggregation_best.ncd](http://dm1.caricoos.org/thredds/dodsC/swan/SWAN_Aggregation_best.ncd.html) at predefined lat and lon indices and time intervals, calculates raw benthic orbital velocities (bov) for each time interval, calculates bov summary statistics, and stores in table for use in the [VIRRS analysis](https://laurenkolinger.github.io/VIRRScore/). 

# issues 

Ongoing issues with accessing raw data using either `readnc()` or direct download from the [website](http://dm1.caricoos.org/thredds/dodsC/swan/SWAN_Aggregation_best.ncd.html). I am not able to troubleshoot without knowing the full extent of the data or how to index it. There seem to be incosnsitencies, gaps in the data, and limits to number of requests that are causing errors in download commands. Tried to reverse engineer with little success. 

Also tried [ERDDAP](http://dm3.caricoos.org:8002/erddap/griddap/caricoos_dm2_8d01_be9b_9010.html) but all links broken.  

What do these three dimensions mean for each of the grid variables? :

<img width="593" alt="image" src="https://github.com/laurenkolinger/swan2bov/assets/125384069/7ea576fd-ff00-4634-88dc-8aba577d22bb">

# contents 

## hoursdifference.m 

Maps specific time intervals (from a fixed start date to various end dates) to the corresponding indices in the time dimension of the SWAN model's dataset. Will be used to download half-yearly slices of the data from the nc file for each site. 

1. sets the base URL for accessing the SWAN Aggregation NetCDF file using the OPeNDAP protocol. 

2. Reads entire `time` array representing the number of hours since October 13, 2012, 12:00:00. 

3. A start date (`startDate`) is defined as October 13, 2012, 12:00:00.
   
5. A series of end dates (`endDates`) are defined at half yearly intervals ranging from January 1, 2013, to January 1, 2018

6. computes the number of hours between the `startDate` and each `endDate`. The results are stored in the `hoursDifferences` vector.

7. For each calculated time difference (in hours), the script finds the closest corresponding index in the `time` array from the NetCDF dataset. This is achieved by finding the minimum absolute difference between each value in `hoursDifferences` and the values in the `time` array. These indices are stored in the `hoursIndex` vector and represent the positions in the `time` array that are closest to the specified time intervals.

## calcbov.m 

Downloads the ncd slice of Hsig and Per for calculation of bov. 

```matlab
bov = calcbov(timeStart, timeCount, ncFile, depth, latIndex, lonIndex)
```

*inputs*

- `timeStart`: Starting time index for data extraction.
- `timeCount`: Number of time elements to read.
- `ncFile`: Path or URL to the NetCDF file containing wave data.
- `depth`: Depth at the specific site (in meters).
- `latIndex`, `lonIndex`: Indices for the latitude and longitude in the dataset.

*functionality*

1. Reads slices of significant wave height (`Hsig`) and wave period (`Per`) data.
  
2. calculates `bov` using following equations
   
   - **Wavelength $L$ (`L_wavelength`):**
     
     $$L = \frac{g \times (T^2)}{2\pi}$$
   
     where $g$ is the acceleration due to gravity (approx. 9.8 m/s²) and $T$ is the wave period (`Per`) . 

   - **Wavenumber $k$ (`k_wavenumber`):** 

     $$k = \frac{2\pi}{L}$$
     
   - **benthic/bottom orbital velocity $u_b$ (`bov`):**
     
     $$u_b = \frac{H \times \pi}{T \times \sinh(k \times h)}$$
     
     where $H$ is the significant wave height (`Hsig`), and $h$ is `depth`. Note hyperbolic sine function $sinh$.   

*outputs*

- `bov`

*equation references*

[Wiberg, P. L., and Sherwood, C. R. (2008). Calculating wave-generated bottom orbital velocities from surface-wave parameters. Computers & Geosciences 34, 1243–1262. doi: 10.1016/j.cageo.2008.02.010. 
](https://www.sciencedirect.com/science/article/abs/pii/S009830040800054X?via%3Dihub)

## swan2bov.m

process and analyze Benthic Orbital Velocity (BOV) data from from the SWAN (Simulating Waves Nearshore) model. The script executes a series of operations to extract, compute, and store BOV metrics for specific geographic locations over various time intervals.

1. Sets the base URL to access the SWAN Aggregation NetCDF file via the OPeNDAP protocol.

2. Reads the entire arrays of latitude (`lat`) and longitude (`lon`) from the NetCDF file, representing geographic coordinates in the dataset.

3. For now, processes data for a single site, 'Grammanik Tiger FSA' but eventually will iterate over each site in the VIRRS dataset.
   
4. Determines the closest indices in the dataset to the specified site's geographical coordinates. For nearshore sites, manual adjustments to grid latitude and longitude may be incorporated.

6. Initializes an empty table `bov_site` with specified column names for storing calculated BOV metrics and associated data. The table includes columns for site, time, depth, actual and grid coordinates, and various BOV metrics (average, 5th percentile, 50th percentile, 95th percentile, maximum, minimum).

7. Loops through a set of time intervals, each represented by an index in the `hoursIndex` array.
   
9. For each interval:

- calculates the start and count for time slices to be used in BOV calculations.
- Invokes the `calcbov` function to compute BOV 
- Computes BOV metrics (average, percentiles, max, min)
- Adds a new row to `bov_site` table for each interval with the site info, time interval, depth, coordinates, and summary BOV metrics.


