function main( directory )
% File name: main.m
% Purpose: read in .tif videow files of fluorescence images of cells in microscope
% parameters: directory - flag for whether to search for directory or not
% target file: .tif video file 
% Date: 9-10-19
% Author: Ryan Ashbaugh

% check if a directory was given as input
if nargin < 1;	directory = false; end

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
	[ file, meta_struct.dname ] = uigetfile('../*.avi','Select File');
	files_struct = dir(strcat(meta_struct.dname, file));

end

%% Go through each file and analyze it

for file_index = 1:length(files_struct)

	%meta_struct = setFileMetaData( meta_struct, files_struct( file_index ) );
	meta_struct.fname = files_struct(file_index).name;
	meta_struct.fpath = [ meta_struct.dname filesep files_struct(file_index).name ];
	backslashes = strfind(meta_struct.dname,'\');
	meta_struct.experiment_name = ...
		meta_struct.dname( backslashes( end - 2 ) + 1: backslashes( end - 1 ) - 1 );
	meta_struct.results_folder = strcat( '../Results/fluorescence-video-analysis/',...
		meta_struct.experiment_name,'/',meta_struct.fname(1:end-4),'/');

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
end
