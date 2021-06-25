overlay_video_circle_radii = 1;
output_video_frame_rate = 10;
image_data_type = 'uint16';

if ~exist( 'cell_roi_centroids' ); 
	[centroid_fname, centroid_dname] = ...
		uigetfile( '.mat', 'Selecte the .mat file for the ROI centroids' );
	load( fullfile( centroid_dname, centroid_fname ) );
end
if ~exist( 'image_sequence' ); 
	directory_name = selectFolderOfTiffs();
	filenames_struct = getFilenameStruct( directory_name, '.tif' );
	image_sequence = loadImageSequence( filenames_struct, image_data_type );
end

median_filtered_sequence = medianFilterImageSequence( image_sequence, ...
	median_kernel_size );
createCentroidOverlayVideo( directory_name, output_video_frame_rate, ...
	median_filtered_sequence, cell_roi_centroids, overlay_video_circle_radii );

