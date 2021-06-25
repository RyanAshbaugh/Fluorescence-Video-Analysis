function brightest_frame = getBrightestFrame( mean_frame_sequence_trace, ...
		image_sequence )
	
	[~,brightest_index] = max( mean_frame_sequence_trace );
	brightest_frame = squeeze( image_sequence(:,:,brightest_index) );

end
