close all;

% Set variables
moving_avg_width = 9;
image_data_type = 'uint16';
median_kernel_size = 3;

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
median_filtered_sequence = medianFilterImageSequence( image_sequence, ...
	median_kernel_size );
sequence_roi_means = calculateROIPixelMeansSequence( ...
	median_filtered_sequence, cell_roi_centroids );

smoothed_roi_means = movmean( sequence_roi_means, moving_avg_width, 2 );

plotROITraces( smoothed_roi_means );
[ baseline_index, post_stim_index ] = getUserFrameNumberInput();

normalized_roi_means = normalizeTraces( smoothed_roi_means, baseline_index );
delta_r = calculateDeltaBright( normalized_roi_means, post_stim_index );

conditon_mean_delta_r = mean( delta_r ) * 100;
conditon_median_delta_r = median( delta_r ) * 100;

disp( [ newline 'Analysis for .tifs in folder' ] )
disp( [ directory_name, newline ]);
disp( [ 'Condition mean delta_R:   ' ...
	num2str( conditon_mean_delta_r ) ' %' ] );
disp( [ 'Condition median delta_R: ' ...
	num2str( conditon_median_delta_r ) ' %' newline ] );

% ask user to select file for saving normalized traces and summary
[ roi_mean_filename, roi_mean_filepath ] = ...
	uiputfile( '*.csv', 'Normalized ROI mean csv file' );
num_frames = size( image_sequence, 3 );
num_ROIs = size( sequence_roi_means, 1 );
summary_row_names = { 'Number of frames'; 'Number of ROIs'; 'Baseline frame';...
	'Post stim frame'; 'Mean delta R (%)'; 'Median delta R (%)' };
summary_data = [ num_frames; num_ROIs; baseline_index; post_stim_index; ...
	conditon_mean_delta_r; conditon_median_delta_r ];
summary_table = table( summary_row_names, summary_data );

% save the normalized means and summary file
summary_table_filename = strrep( roi_mean_filename, '.csv', '_summary.csv' );
writematrix( normalized_roi_means', ...
	fullfile( roi_mean_filepath, roi_mean_filename ) );
writetable( summary_table, ...
	fullfile( roi_mean_filepath, summary_table_filename ), ...
	'WriteVariableNames', false );
