close all; clear all;

% Set variables
moving_avg_width = 9;
delta_r_end_time = 150;
lap_filter = [ - 1, -1, -1; -1, 8, -1; -1, -1, -1 ];
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

% take Laplacian of best frame
lap_thresh_image = thresholdedAbsoluteLaplacian( brightest_frame, lap_percent);

% get product of thresholded laplacian and original
masked_by_laplacian = brightest_frame .* uint16( lap_thresh_image );

% binarize based on new masked image
figure()
binarized = imbinarize( masked_by_laplacian, 'adaptive' );

final_image = medfilt2( binarized, [3 3] );
imshow( final_image );

% erode and regrow image
se = strel( 'square', 3 );
eroded_image = imerode( final_image, se );

figure('name', 'eroded');
imshow( eroded_image );

% filter and dilate
median_image = medfilt2( eroded_image, [ 5 5 ] );

dilate_image = imdilate( median_image, se );

figure( 'name', 'dilated image' );
imshow( dilate_image );

% compare with overlay
overlay_image = overlayFullROIs( brightest_frame, dilate_image );
figure('name', 'overlay image' );
imshow( overlay_image );

% process whole video
roi_stats = regionprops( dilate_image, 'Centroid' );
bright_centroids = cat(1, roi_stats.Centroid );

createCentroidOverlayVideo( directory_name, output_video_frame_rate, ...
	image_sequence, bright_centroids, overlay_video_circle_radii )

% calculate roi mean pixel value for every frame
sequence_roi_means = calculateROIPixelMeansSequence( image_sequence, ...
	bright_centroids );

smoothed_roi_means = movmean( sequence_roi_means, moving_avg_width, 2 );
normalized_roi_means = normalizeTraces( smoothed_roi_means );

delta_r = calculateDeltaBright( normalized_roi_means, delta_r_end_time );

conditon_mean_delta_r = mean( delta_r );
conditon_median_delta_r = median( delta_r );

figure()
plot( 1:num_images, normalized_roi_means' );


