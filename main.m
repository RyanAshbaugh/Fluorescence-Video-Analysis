function main( directory )
% File name: main.m
% Purpose: read in .tif videow files of fluorescence images of cells in microscope
% parameters: directory - flag for whether to search for directory or not
% target file: .tif video file 
% Date: 9-10-19
% Author: Ryan Ashbaugh

if nargin < 1
	directory = false;
end

%% Set variables

meta_struct = struct;

if directory == true
	% select folder with window

	disp([ newline 'Select a folder to open in the window...' ]);
	meta_struct.dname = strcat(uigetdir('Select Folder'),'\');
	disp([ 'Folder: ' meta_struct.dname newline ]);

	% put all files in folder into a list
	files_struct = dir(strcat(meta_struct.dname, '/**/*.avi'));

	% for each file
	disp([ 'Analyzing each file in ' meta_struct.dname '...' newline ]);

elseif directory == false
	% select file with window
	disp([ newline 'Select a file to open in the window...' ]);
	[ file, meta_struct.dname ] = uigetfile('*.avi','Select File');
	files_struct = dir(strcat(meta_struct.dname, file));

end

%% Go through each file and analyze it

for file_index = 1:length(files_struct)

	meta_struct = setFileMetaData( meta_struct, files_struct( file_index ) );

	%% Load in the video

	disp([ 'Directory: ' meta_struct.dname ]);
	disp([ 'File: ' meta_struct.fname newline ]);

	disp([ 'Reading in video data...' newline ]);
	video = VideoReader(meta_struct.fpath);

	%movie = read(video);
	disp('number of frames');
	
	green_channel = 2;
	video_frames = read(video);
	video_grayscale = int64(video_frames(:,:,green_channel,:));
	integrated_image = uint8( sum( video_grayscale, 4 ) ./ video.NumberofFrames );
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

	fig3 = figure;
	histogram( histeq_image );
	%imshowpair( integrated_image, binarized_image, 'montage' );

	% general variables for given file
	num_frames = 100;
	frames_per_second = 5;

	%% Create new video to store threshold absolute gradient

	% threshold absolute gradient, or tag, video file setup
	disp([ 'Creating new video for calculating threshold absolute gradient...' ]);
	tag_video_name = ...
		strrep(meta_struct.fname,'.avi','_tag_video.avi');
	tag_video_fpath = ...
		strcat(meta_struct.results_folder,tag_video_name);
	disp([ 'Threshold absolute gradient video: ' tag_video_name newline ]);

	tag_video = VideoWriter(tag_video_fpath,'Grayscale AVI');
	tag_video.FrameRate = frames_per_second;

	dual_img_vid = strrep(tag_video_fpath,'tag_video.avi','dual_img.avi');
	dual_img_vid = VideoWriter(dual_img_vid);
	dual_img_vid.FrameRate = frames_per_second * 5;	% speed up by 5

	% open the new tag video
	open(tag_video);
	open(dual_img_vid);





	tic;

	for ii = 1:1000

		frame1 = read(video,ii);

		temp_frame = frame1;

	end

	toc;

	% store then access
	tic;

	for ii = 1:1000

		frame1 = read(video,ii);

		temp_frame = frame1;

	end

	toc;

	close(tag_video);
	close(dual_img_vid);
	%% Go through frames of original video and calculate tag 

	% for all but last frame, get frame and the next frame

	%{
	sum_image = zeros( size(read(video,1)), 'uint64' );
	delta = 20;
	
	frame_list = 1500;
	fig = figure('visible','off');
	disp([ 'Processing video to calculate temporal threshold absolute gradient...']);
	for jj = 1:(frame_list-delta)
		

		try
			frame1 = read(video, jj);
		catch ME
			break
		end
		frame_green = frame1(:,:,green_channel);

		sum_image = sum_image + uint64( frame_green );

		delta_frame = read(video,jj+delta);
		delta_frame = delta_frame(:,:,green_channel);
		diff_frame = abs( frame_green - delta_frame );
		histeq_frame = histeq( diff_frame );

		pixel_mean = mean( histeq_frame );
		pixel_sd = std( single(histeq_frame) );

		thresh_frame = histeq_frame;
		thresh_frame( find(histeq_frame < (pixel_mean + pixel_sd*1.5) )) = 0;

		median_filtered_frame = medfilt2( thresh_frame, [5 5]);

		subplot(2,2,1);
		main_title_text = sprintf('Raw and Filtered. Time: %2.1f sec',( jj / tag_video.FrameRate ));
		sgtitle(main_title_text);

		imshow( frame1 );
		title_text = sprintf('Avg+/-Std[min,max]= %2.1f+/-%2.1f [%2.1f, %2.1f]',...
			mean(double(frame_green),'all'),std(double(frame_green(:))),...
			min(double(frame_green(:))),max(double(frame_green(:))));
		title( title_text );

		subplot(2,2,3);
		imshow( median_filtered_frame );
		title_text2 = sprintf('Avg +/- Std [min,max] = %2.1f +/- %2.1f [%2.1f, %2.1f]',...
			mean(double(histeq_frame),'all'),std(double(histeq_frame(:))),...
			min(double(histeq_frame(:))),max(double(histeq_frame(:))));
		title( title_text2 );

		mag_disp = subplot(2,2,2);
		if ( jj > 600 ) & ( jj < 900 )
			t1 = text(0.25,0.25,['Magnet' newline 'on']); axis off;
			t1.Color = 'red';
		else
			t1 = text(0.25,0.25,['Magnet' newline 'off']); axis off;
		end
		t1.FontSize = 30;

		writeVideo( tag_video, frame_green );
		writeVideo( dual_img_vid, getframe(gcf) );


	end
	%% normalize tag to max change of whole video

	disp([ 'Closing video: ' tag_video_name ]);
	close(tag_video);
	close(dual_img_vid);

%{	
	% load in whole video
	frame_temp = read(video,1);
	[ num_rows, num_cols ] = size( frame_temp(:,1:2) );
	vid_length = 1500;
	time_downsampled = zeros( num_rows, num_cols, vid_length/5);
	size(time_downsampled)

	full_vid = zeros( num_rows, num_cols, vid_length );
	for kk = 1:vid_length
		temp_frame = read(video,kk);
		full_vid(:,kk) = temp_frame(:,:,green_channel);
	end

	% do temporal downsampling
	ds_rate = 5;
	for kk = 1:size(time_downsampled,3)
		bin_start = (kk-1)*ds_rate + 1;
		bin_end = (kk-1)*ds_rate + 1 + 5;
		time_downsampled(:,kk) = mean( full_vid(:,:,bin_start:bin_end), 3);
	end
%}
	sum_image = sum_image ./ jj;
	sum_image = uint8(sum_image);
	


	end
	%}
end
