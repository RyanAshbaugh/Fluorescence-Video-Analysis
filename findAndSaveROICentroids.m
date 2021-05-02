close all; clear all;

% Set variables
moving_avg_width = 9;
delta_r_end_time = 150;
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

% process whole video
cell_roi_centroids = calculateROICentroids( roi_image );

save( fullfile( directory_name, 'cell_roi_centroids.mat'),'cell_roi_centroids');

