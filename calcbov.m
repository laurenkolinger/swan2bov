function bov = calcbov(timeStart, timeCount, ncFile, depth, latIndex, lonIndex)
    % ncFile: Path or URL to the NetCDF file
    % depth: Depth data for the 'siti'
    % latIndex, lonIndex: Indices for the fixed latitude and longitude
    % timeStart: starting time index
    % timeCount: number of time elements to download

    % Read slices of Hsig and Per data
    hsig_data = ncread(ncFile, 'Hsig', [lonIndex, latIndex, timeStart], [1, 1, timeCount]);
    per_data = ncread(ncFile, 'Per', [lonIndex, latIndex, timeStart], [1, 1, timeCount]);

    % Calculate the variables
    L_wavelength = (9.8 * (per_data .^ 2)) / (2 * pi);
    k_wavenumber = (2 * pi) ./ L_wavelength;
    denom = per_data .* sinh(k_wavenumber * depth);
    num = hsig_data * pi;
    bov = num ./ denom;

    return
end
