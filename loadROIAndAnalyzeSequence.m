close all;

% Set variables
moving_avg_width = 9;
image_data_type = 'uint16';

if ~exist( 'cell_roi_centroids' ); 
	[centroid_fname, centroid_dname] = ...
		uigetfile( '.mat', 'Selecte the .mat file for the ROI centroids' );
	load( fullfile( centroid_dname, centroid_fname ) );
end
if ~exist( 'image_sequence' ); 
	directory_name = selectFolderOfTiffs();
	filenames_struct = getFilenameStruct( directory_name, '.tif' );
	image_sequence = loadImageSequence( filenames_struct, image_data_type );
end

% calculate roi mean pixel value for every frame
sequence_roi_means = calculateROIPixelMeansSequence( image_sequence, ...
	cell_roi_centroids );

smoothed_roi_means = movmean( sequence_roi_means, moving_avg_width, 2 );

plotROITraces( smoothed_roi_means );
[ baseline_index, post_stim_index ] = getUserFrameNumberInput();

normalized_roi_means = normalizeTraces( smoothed_roi_means, baseline_index );
delta_r = calculateDeltaBright( normalized_roi_means, post_stim_index );

conditon_mean_delta_r = mean( delta_r );
conditon_median_delta_r = median( delta_r );

disp( [ newline 'Analysis for .tifs in folder' ] )
disp( [ directory_name, newline ]);
disp( [ 'Condition mean delta_R:   ' num2str( conditon_mean_delta_r ) ] );
disp( [ 'Condition median delta_R: ' ...
	num2str( conditon_median_delta_r ) newline ] );
