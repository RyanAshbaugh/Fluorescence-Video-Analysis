close all; clear all;

% Set variables
moving_avg_width = 9;
delta_r_end_time = 150;
lap_filter = [ - 1, -1, -1; -1, 8, -1; -1, -1, -1 ];
image_data_type = 'uint16';

% select file with window
directory_name = selectFolderOfTiffs();
filenames_struct = getFilenameStruct( directory_name, '.tif' );
image_sequence = loadImageSequence( filenames_struct, image_data_type );

num_images = size( image_sequence, 3 );

% get the mean of each frame
mean_frame_trace = calculateMeanFrameSequenceTrace( image_sequence );

brightest_frame = getBrightestFrame( mean_frame_trace, image_sequence );

% take Laplacian of best frame
lap_filtered = laplacianFilterImage( brightest_frame );
[lap_hist,lap_hist_edges] = histcounts( lap_filtered );
%lap_hist = histogram( lap_filtered );

% use histogram of laplacian to get 99% image of laplacian edges
lap_percent = 0.80;
cdf = cumsum( lap_hist)/ sum( lap_hist);
%cdf = cumsum( lap_hist.Values )/ sum( lap_hist.Values );
[ ~, lap_threshold_index ] = min( abs( cdf - lap_percent ) );
lap_threshold = lap_hist_edges( lap_threshold_index );

lap_thresh_image = lap_filtered;
lap_thresh_image( find( lap_thresh_image < lap_threshold ) ) = 0;

figure();
imshow( lap_thresh_image );

% get product of thresholded laplacian and original
masked_by_laplacian = brightest_frame .* uint16( lap_thresh_image );

figure()
histogram( masked_by_laplacian( find( masked_by_laplacian>0 ) ) );

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
color_frame = uint8( brightest_frame/ (2^8) );

color_brightest = cat( 3, color_frame, color_frame, color_frame );

dilate_overlay = imoverlay( histeq( color_brightest ), dilate_image, 'r' );

figure('name', 'overlay image' );
imshow( dilate_overlay );

% process whole video
roi_stats = regionprops( dilate_image, 'Centroid' );


bright_centroids = cat(1, roi_stats.Centroid );
circle_radii = 1;

% setup video
output_video_fname = strcat( directory_name, 'cell_overlay.mp4' );
output_video = VideoWriter( output_video_fname, 'MPEG-4' );
output_video.FrameRate = 10;
open( output_video );


figure('name', 'Centroid overlay')
for ii = 1:size( image_sequence, 3 )

	temp_img = image_sequence(:,:,ii);
	temp_color = uint8( temp_img / (2^8) );
	
	hold on;
	imshow( histeq(temp_color) );
	viscircles( bright_centroids, repmat( circle_radii, ...
		size( bright_centroids,1 ), 1 ) );
	hold off;
	drawnow();

	writeVideo( output_video, getframe );


end


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

disp( [ 'Closing video: ', output_video_fname ] );
close( output_video );


