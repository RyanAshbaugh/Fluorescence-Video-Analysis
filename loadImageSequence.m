function image_sequence = loadImageSequence( filenames_struct,image_data_type )

	frame_filepath = fullfile( filenames_struct(1).folder, ...
		filenames_struct(1).name );
	frame_1 = imread( frame_filepath );
	[ height, width ] = size( frame_1 );
	num_images = length( filenames_struct );
	image_sequence = zeros( height, width, num_images, image_data_type );

	for file_index = 1:num_images

		frame_filepath = fullfile( filenames_struct(file_index).folder, ...
			filenames_struct(file_index).name );
		image_sequence( :,:, file_index ) = imread( frame_filepath );

	end
end
