close all; clear all;

% Set variables
moving_avg_width = 9;
delta_r_end_time = 150;
baseline_index = 1;
image_data_type = 'uint16';
lap_percent = 0.80;
output_video_frame_rate = 10;
overlay_video_circle_radii = 1;

% select file with window
directory_name = selectFolderOfTiffs();
filenames_struct = getFilenameStruct( directory_name, '.tif' );
image_sequence = loadImageSequence( filenames_struct, image_data_type );

num_images = size( image_sequence, 3 );

% get the mean of each frame
mean_frame_trace = calculateMeanFrameSequenceTrace( image_sequence );

brightest_frame = getBrightestFrame( mean_frame_trace, image_sequence );

roi_image = detectROIs( brightest_frame, lap_percent );

% compare with overlay
overlay_image = overlayFullROIs( brightest_frame, roi_image );
%figure('name', 'overlay image' );
%imshow( overlay_image );

% process whole video
cell_roi_centroids = calculateROICentroids( roi_image );

createCentroidOverlayVideo( directory_name, output_video_frame_rate, ...
	image_sequence, cell_roi_centroids, overlay_video_circle_radii );

% calculate roi mean pixel value for every frame
sequence_roi_means = calculateROIPixelMeansSequence( image_sequence, ...
	cell_roi_centroids );

smoothed_roi_means = movmean( sequence_roi_means, moving_avg_width, 2 );
normalized_roi_means = normalizeTraces( smoothed_roi_means, baseline_index );

delta_r = calculateDeltaBright( normalized_roi_means, delta_r_end_time );

conditon_mean_delta_r = mean( delta_r );
conditon_median_delta_r = median( delta_r );

figure()
plot( 1:num_images, normalized_roi_means' );


