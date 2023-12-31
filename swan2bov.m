
% Base URL for the NetCDF file
% ncFile = 'http://52.55.122.42/thredds/dodsC/swan/SWAN_Aggregation_best.ncd';
ncFile = 'http://dm1.caricoos.org/thredds/dodsC/swan/SWAN_Aggregation_best.ncd'

% Read the entire latitude and longitude arrays
latitudes = ncread(ncFile, 'lat');
longitudes = ncread(ncFile, 'lon');

%% 

% will eventually loop through each site in site master, 

% for now only doing one 
site = 'Grammanik Tiger FSA';
depth = 38; %depth in m 
lat = 18.188848;
lon = -64.95659; 

% Find the index of the latitude and longitude closest to the target values
[~, latIndex] = min(abs(latitudes - round(lat,2)));
[~, lonIndex] = min(abs(longitudes - round(lon,2)));

% grid latitude and longitude. may manually change this for some nearshore sites
% eg import array with sites with manually chosen lat/lon indices with an ifelse statement
gridLat = latitudes(latIndex);
gridLon = longitudes(lonIndex);

%% 

% Initialize the table with specified column names
columnNames = {'site', 'time', 'depth', 'lat', 'lon', 'gridlat', 'gridlon', 'bov_average', 'bov_5percentile', 'bov_50percentile', 'bov_95percentile', 'bov_max', 'bov_min'};
bov_site = table('Size', [0, length(columnNames)], 'VariableTypes', repmat({'double'}, 1, length(columnNames)), 'VariableNames', columnNames);

% Set non-numeric columns
bov_site.site = string(bov_site.site);
bov_site.time = string(bov_site.time);


%%

% Loop through each interval

% i = 1; % for loop testing
for i = 1:length(hoursIndex) - 1
    
    timeStart = hoursIndex(i);
    timeCount = hoursIndex(i + 1) - hoursIndex(i);

% dayindex = 1; % for loop testing
% for dayindex = 1:1906 % There are 1,906 days between October 13, 2012, at 12:00:00 UTC and January 1, 2018, at 12:00:00 UTC. ​​
    % starting time index (iterate on this)
    % timeStart = ((dayindex - 1) * timeCount) + 1;

    bov = calcbov(timeStart, timeCount, ncFile, depth, latIndex, lonIndex);

    % bov_average = mean(bov);
    % bov_5percentile = prctile(bov,5);
    % bov_50percentile = prctile(bov,50);
    % bov_95percentile = prctile(bov, 95);
    % bov_max = max(bov);
    % bov_min = min(bov);

    % Create a new row for the table
    newRow = { ...
        site, ...
        endDates{i}, ...
        depth, ...
        lat, ...
        lon, ...
        gridLat, ...
        gridLon, ...
        mean(bov), ...
        prctile(bov,5), ...
        prctile(bov,50), ...
        prctile(bov, 95), ...
        max(bov), ...
        min(bov)};

    % Add the new row to the table
    bov_site = [bov_site; newRow];

end


