% Base URL for the NetCDF file
% ncFile = 'http://52.55.122.42/thredds/dodsC/swan/SWAN_Aggregation_best.ncd';
ncFile = 'http://dm1.caricoos.org/thredds/dodsC/swan/SWAN_Aggregation_best.ncd'

% Read the entire time array
time = ncread(ncFile,'time'); 

% Define the start date and time
startDate = datetime('2012-10-13 12:00:00', 'InputFormat', 'yyyy-MM-dd HH:mm:ss');

% Define the end dates
endDates = {
    '2013-01-01 00:00:00';
    '2013-07-01 00:00:00';
    '2014-01-01 00:00:00';
    '2014-07-01 00:00:00';
    '2015-01-01 00:00:00';
    '2015-07-01 00:00:00';
    '2016-01-01 00:00:00';
    '2016-07-01 00:00:00';
    '2017-01-01 00:00:00';
    '2017-07-01 00:00:00';
    '2018-01-01 00:00:00'
};

% Initialize the vector to store the number of hours
hoursDifferences = zeros(length(endDates), 1);

% Calculate the number of hours between the start date and each end date
for i = 1:length(endDates)
    hoursDifferences(i) = hours(datetime(endDates{i}, 'InputFormat', 'yyyy-MM-dd HH:mm:ss') - startDate);
end

% Find the index of each of hoursdiffernces 

% Initialize the hoursIndex vector
hoursIndex = zeros(length(hoursDifferences), 1);

% Loop over each value in hoursDifferences
for i = 1:length(hoursDifferences)
    % Find the index in 'time' that is closest to the current value in hoursDifferences
    [~, closestIndex] = min(abs(time - hoursDifferences(i)));
    
    % Store the index
    hoursIndex(i) = closestIndex;
end