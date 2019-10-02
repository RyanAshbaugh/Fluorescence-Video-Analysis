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

	% open the new tag video
	open(tag_video);

	%% Go through frames of original video and calculate tag 

	% for all but last frame, get frame and the next frame

	disp([ 'Processing video to calculate temporal threshold absolute gradient...']);
	for jj = 1:1400
		

		frame1 = read(video, jj);
		frame_green = frame1(:,:,green_channel);

		ROIlayers = ROIgrow( frame_green, 3, 4, 'logical');
		size(ROIlayers);

		writeVideo( tag_video, frame_green );

	end

	%% normalize tag to max change of whole video

	disp([ 'Closing video: ' tag_video_name ]);
	close(tag_video);

	end
end
