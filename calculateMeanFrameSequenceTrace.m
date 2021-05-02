function mean_frame_trace = calculateMeanFrameSequenceTrace( image_sequence )
	
	first_frame_mean = mean( image_sequence(:,:,1), 'all' );
	mean_frame_trace = ( squeeze( mean( mean( image_sequence ) ) ) ./ ...
		first_frame_mean ) - 1;

end
