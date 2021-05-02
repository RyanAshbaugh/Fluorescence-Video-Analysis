function sequence_roi_means = ...
		calculateROIPixelMeansSequence( image_sequence, roi_mask )

	num_frames = size( image_sequence,3 );
	sequence_roi_means = zeros( size( roi_mask, 3 ), num_frames );
	
	for ii = 1:num_frames
	
		sequence_roi_means(:,ii) = ...
			calculateROIPixelMeans( image_sequence(:,:,ii), roi_mask );

	end
end
