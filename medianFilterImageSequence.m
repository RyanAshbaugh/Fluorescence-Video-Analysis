function median_filtered_sequence = medianFilterImageSequence( ...
		image_sequence, median_kernel_size )

	median_filtered_sequence = zeros( size( image_sequence ), ...
		class( image_sequence ) );
	median_kernel = [ median_kernel_size, median_kernel_size ];
	
	num_images = size( image_sequence, 3 );
	for ii = 1:num_images
		median_filtered_sequence( :,:, ii ) = ...
			medfilt2( image_sequence(:,:,ii), median_kernel );
	end
end
