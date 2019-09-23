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

meta_data = struct;

if directory == true
	% select folder with window

	disp([ newline 'Select a folder to open in the window...' ]);
	meta_data.dname = uigetdir('Select Folder');
	meta_data.dname = strcat( meta_data.dname, '\');
	disp([ 'Folder: ' meta_data.dname newline ]);

	% put all files in folder into a list
	files = dir(strcat(meta_data.dname, '/**/*.avi'));

	% for each file
	disp([ 'Analyzing each file in ' meta_data.dname '...' newline ]);

elseif directory == false
	% select file with window
	disp([ newline 'Select a file to open in the window...' ]);
	[ file, meta_data.dname ] = uigetfile('*.avi','Select File');
	files = dir(strcat(meta_data.dname, file));

end

%% Go through each file and analyze it

for ii = 1:length(files)
	meta_data.fname = files(ii).name;
	meta_data.fpath = [ meta_data.dname filesep files(ii).name ];
	backslashes = strfind(meta_data.dname,'\');
	meta_data.experiment_name = ...
		meta_data.dname( backslashes( end-2 )+1:backslashes( end-1 )-1 );
	meta_data.results_folder = strcat('../Results/fluorescence-video-analysis/',...
		meta_data.experiment_name,'/',meta_data.fname,'/');
%end

	% create folders for output data

	if ~exist( meta_data.results_folder, 'dir' )
		disp([ 'Making directory: ' meta_data.results_folder ]);
		mkdir( meta_data.results_folder )
	end

	%% Load in the video

	disp([ 'Directory: ' meta_data.dname ]);
	disp([ 'File: ' meta_data.fname newline ]);

	disp([ 'Reading in video data...' newline ]);
	video = VideoReader(meta_data.fpath);
	green_channel = 2;

	%disp([ 'Video has ' video.NumFrames ' frames and resolution ' ...
	%	video.Width ',' video.Height]);


	%% Create new video to store threshold absolute gradient

	% threshold absolute gradient, or tag, video file setup
	disp([ 'Creating new video for calculating threshold absolute gradient...' ]);
	tag_video_name = ...
		strrep(meta_data.fname,'.avi','_tag_video.avi');
	tag_video_fpath = ...
		strcat(meta_data.results_folder,tag_video_name);
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
		frame2 = read(video, jj+10);
		difference_frame = ...
			abs( frame2(:,:,green_channel) - frame1(:,:,green_channel) );
		difference_frame = histeq(difference_frame);
		%difference_frame = rgb2gray( difference_frame );

		writeVideo( tag_video, difference_frame );
	end

	%% normalize tag to max change of whole video

	disp([ 'Closing video: ' tag_video_name ]);
	close(tag_video);

	end
end
