close all;

% Set variables
moving_avg_width = 9;
image_data_type = 'uint16';
median_kernel_size = 3;

% load the ROI pixel image and image sequence
[pixel_roi_image_fname, pixel_roi_image_dname] = ...
	uigetfile( '.png', 'Selecte the .png file with pixel ROIs' );
pixel_roi_image = ...
	imread( fullfile( pixel_roi_image_dname, pixel_roi_image_fname ) );
directory_name = selectFolderOfTiffs();
filenames_struct = getFilenameStruct( directory_name, '.tif' );
image_sequence = loadImageSequence( filenames_struct, image_data_type );


% calculate roi mean pixel value for every frame
median_filtered_sequence = medianFilterImageSequence( image_sequence, ...
	median_kernel_size );

% create a mask for pixels of each label, image_height x width x num labels 
ROI_mask = createManualROIMask( pixel_roi_image );

% calculate the ROI means using the mask of per label pixel ROIs
sequence_roi_means = calculateManualROIMeanSequence( ...
	median_filtered_sequence, ROI_mask );

smoothed_roi_means = movmean( sequence_roi_means, moving_avg_width, 2 );

plotROITraces( smoothed_roi_means );
[ baseline_index, post_stim_index ] = getUserFrameNumberInput();

% normalize the traces
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
num_ROIs = size( ROI_mask, 3 );
summary_row_names = { 'Number of frames', 'Number of ROIs', 'Baseline frame',...
	'Post stim frame', 'Mean delta R (%)', 'Median delta R (%)' };
summary_data = [ num_frames, num_ROIs, baseline_index, post_stim_index, ...
	conditon_mean_delta_r, conditon_median_delta_r ];
summary_table = table( summary_row_names, summary_data );

% save the normalized means and summary file
summary_table_filename = strrep( roi_mean_filename, '.csv', '_summary.csv' );
writematrix( normalized_roi_means', ...
	fullfile( roi_mean_filepath, roi_mean_filename ) );
writetable( summary_table, ...
	fullfile( roi_mean_filepath, summary_table_filename ), ...
	'WriteVariableNames', false );
