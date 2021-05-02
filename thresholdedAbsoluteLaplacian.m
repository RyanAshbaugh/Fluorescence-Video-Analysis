function lap_thresh_image = ...
		thresholdedAbsoluteLaplacian( image, percent_threshold )

	% take Laplacian of best frame
	lap_filtered = laplacianFilterImage( image );
	[lap_hist,lap_hist_edges] = histcounts( lap_filtered );

	% use histogram of laplacian to get 99% (or thresh%) image of laplacian edges
	cdf = cumsum( lap_hist)/ sum( lap_hist);
	[ ~, lap_threshold_index ] = min( abs( cdf - percent_threshold ) );
	lap_intensity_threshold = lap_hist_edges( lap_threshold_index );

	lap_thresh_image = lap_filtered;
	lap_thresh_image( find( lap_thresh_image < lap_threshold ) ) = 0;

end
