%function main( directory )
% File name: main.m
% Purpose: read in .tif videow files of fluorescence images of cells in microscope
% parameters: directory - flag for whether to search for directory or not
% target file: .tif video file 
% Date: 9-10-19
% Author: Ryan Ashbaugh

% check if a directory was given as input
close all; clear all;


lap_filter = [ - 1, -1, -1; -1, 8, -1; -1, -1, -1 ];

% Set variables

meta_struct = struct;

% select file with window
disp([ newline 'Select a folder containing the .tifs to be analyzed...' ]);
meta_struct.dname = strcat(uigetdir('Select Folder'),'\');
disp([ 'Folder: ', meta_struct.dname newline ] );

files_struct = dir(strcat(meta_struct.dname, '/**/*.tif'));

disp([ 'Analyzing each file in ' meta_struct.dname '...' newline ] );

% Go through each file and analyze it
meta_struct.fpath = [ meta_struct.dname filesep files_struct(1).name ];
image_1 = imread( meta_struct.fpath );
num_images = length( files_struct );

[ height, width ] = size( image_1 );
integrated_image_64 = zeros( height, width, 1, 'int64' );
image_sequence = zeros( height, width, num_images, 'uint16' );

for file_index = 1:num_images

	%meta_struct.fname = files_struct(file_index).name;
	meta_struct.fpath = [ meta_struct.dname filesep files_struct(file_index).name ];

	A = imread( meta_struct.fpath );
	image_sequence( :,:, file_index ) = A;

	%{
	%histeq_image = histeq(A);
	median_filtered = medfilt2( A, [3 3] );
	histeq_image = histeq( median_filtered );
	median_filtered = medfilt2( histeq_image, [3 3] );

	%gamma_corrected = imadjust( A, [],[], 0.5 );
	%imshow( gamma_corrected );
	imshow( median_filtered );
	drawnow;
	%}

	%integrated_image_64 = integrated_image_64 + int64( A );

end

R_naught = mean( image_sequence(:,:,1), 'all' );

mean_R = squeeze( mean( mean( image_sequence ) ) );

figure;
plot( 1:num_images, mean_R ./ R_naught );
xlabel( 'Frame' );
ylabel( 'Normalized average image intensity' )

[ ~, brightest_index ] = max( mean_R );
brightest_frame = squeeze(image_sequence(:,:,brightest_index));

% take Laplacian of best frame
figure()
lap_filtered = abs( conv2( brightest_frame, lap_filter, 'same' ) );
lap_hist = histogram( lap_filtered );

% use histogram of laplacian to get 99% image of laplacian edges
lap_percent = 0.80;
cdf = cumsum( lap_hist.Values )/ sum( lap_hist.Values );
[ ~, lap_threshold_index ] = min( abs( cdf - lap_percent ) );
lap_threshold = lap_hist.BinEdges( lap_threshold_index );

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
output_video_fname = strcat( meta_struct.dname, 'cell_overlay.mp4' );
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

disp( [ 'Closing video: ', output_video_fname ] );
close( output_video );

	%{
integrated_image = uint8( integrated_image_64 ./ num_images );
median_filtered = medfilt2( integrated_image, [ 3 3 ] );
histeq_image = histeq(median_filtered);
heq_thresh = histeq_image;

imshow( heq_thresh );
drawnow;

	%backslashes = strfind(meta_struct.dname,'\');
	%meta_struct.experiment_name = ...
	%	meta_struct.dname( backslashes( end - 2 ) + 1: backslashes( end - 1 ) - 1 );
	%meta_struct.results_folder = strcat( '../Results/fluorescence-video-analysis/',...
	%	meta_struct.experiment_name,'/',meta_struct.fname(1:end-4),'/');

	% make results folder if it is not there
	if ~exist( meta_struct.results_folder, 'dir' );
		mkdir( meta_struct.results_folder );
	end
	disp('meta_struct.results_folder');
	meta_struct.results_folder

	%% Load in the video

	disp([ 'Directory: ' meta_struct.dname ]);
	disp([ 'File: ' meta_struct.fname newline ]);

	disp([ 'Reading in video data...' newline ]);
	meta_struct.fpath

	t = Tiff( meta_struct.fpath, 'r' )
	imageData = read(t);

	video = VideoReader(meta_struct.fpath);

	green_channel = 2;
	integrated_image_64 = zeros( video.Height, video.Width, 1, 'int64' );
	for jj = 1:video.NumberofFrames
		temp_frame = read(video, jj);
		integrated_image_64 = integrated_image_64 + int64( temp_frame(:,:,green_channel) );
	end
	integrated_image = uint8( integrated_image_64 ./ video.NumberofFrames );
	median_filtered = medfilt2( integrated_image, [ 3 3 ] );
	histeq_image = histeq(median_filtered);
	heq_thresh = histeq_image;
	heq_thresh( heq_thresh < 220 ) = 0;

	binarized_image = imbinarize( integrated_image, 'adaptive',...
	   'Sensitivity', 0.55 );
   	binarized_medfilt = medfilt2( binarized_image, [ 7 7 ] );


   	montage_array = [ integrated_image histeq_image heq_thresh; ...
		(binarized_image*255) (binarized_medfilt*255) zeros(size(binarized_image))];
	fig2 = figure;
	montage( montage_array );

	integrated_image_name = ...
		strrep(meta_struct.fname,'.avi','_integrated_image.png');
	integrated_image_fpath = ...
		strcat(meta_struct.results_folder,integrated_image_name);
	imwrite( integrated_image, integrated_image_fpath );

	binarized_image_name = ...
		strrep(meta_struct.fname, '.avi','_binarized_image.png');
	binarized_image_fpath = ...
		strcat(meta_struct.results_folder,binarized_image_name);
	imwrite( binarized_medfilt, binarized_image_fpath );

	clear all
	%}
%end


