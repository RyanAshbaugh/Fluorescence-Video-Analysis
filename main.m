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
	green_channel = 2;

	%disp([ 'Video has ' video.NumFrames ' frames and resolution ' ...
	%	video.Width ',' video.Height]);


	%% Create new video to store threshold absolute gradient

	% threshold absolute gradient, or tag, video file setup
	disp([ 'Creating new video for calculating threshold absolute gradient...' ]);
	tag_video_name = ...
		strrep(meta_struct.fname,'.avi','_tag_video.avi');
	tag_video_fpath = ...
		strcat(meta_struct.results_folder,tag_video_name);
	disp([ 'Threshold absolute gradient video: ' tag_video_name newline ]);

	tag_video = VideoWriter(tag_video_fpath,'Grayscale AVI');
	tag_video.FrameRate = 5;

	dual_img_vid = strrep(tag_video_fpath,'tag_video.avi','dual_img.avi');
	dual_img_vid = VideoWriter(dual_img_vid);
	dual_img_vid.FrameRate = 5;

	% open the new tag video
	open(tag_video);
	open(dual_img_vid);

	%% Go through frames of original video and calculate tag 

	% for all but last frame, get frame and the next frame

	sum_image = zeros( size(read(video,1)), 'uint64' );
	delta = 5;
	
	frame_list = 1500;
	fig = figure('visible','off');
	disp([ 'Processing video to calculate temporal threshold absolute gradient...']);
	for jj = 1:(300-delta)
		

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
		%threshold_frame = 

		subplot(2,1,1);
		
		imshow( frame1 );
		title_text = sprintf('Avg+/-Std[min,max]= %2.1f+/-%2.1f [%2.1f, %2.1f]',...
			mean(double(frame_green),'all'),std(double(frame_green(:))),...
			min(double(frame_green(:))),max(double(frame_green(:))));
		title( title_text );
		subplot(2,1,2);
		imshow( histeq_frame );
		title_text2 = sprintf('Avg +/- Std [min,max] = %2.1f +/- %2.1f [%2.1f, %2.1f]',...
			mean(double(histeq_frame),'all'),std(double(histeq_frame(:))),min(double(histeq_frame(:))),max(double(histeq_frame(:))));
		title( title_text2 );
		%frame_list(jj) = getframe(gcf);

		%{
		ROIlayers = ROIgrow( frame_green, 4, 10, 'numbered');
		size(ROIlayers)
		figure;
		imagesc(ROIlayers);
		input('wait');
		masked_green = uint8( frame_green .* uint8(ROIlayers) );
		%}

		writeVideo( tag_video, frame_green );
		writeVideo( dual_img_vid, getframe(gcf) );


	end

	sum_image = sum_image ./ jj;
	sum_image = uint8(sum_image);
	
	fig2 = figure;
	imshow( sum_image );

	%% normalize tag to max change of whole video

	disp([ 'Closing video: ' tag_video_name ]);
	close(tag_video);
	close(dual_img_vid);

	end
end
