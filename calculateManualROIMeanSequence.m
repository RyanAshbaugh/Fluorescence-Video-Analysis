function sequence_roi_means = ...
		calculateManualROIMeanSequence( image_sequence, roi_mask )

	num_rois = size( roi_mask, 3 );
	num_frames = size( image_sequence, 3 );
	sequence_roi_means = zeros( num_rois, num_frames );
	
	for ii = 1:num_rois

		sequence_roi_mean = uint16( roi_mask( :,:,ii ) ) .* image_sequence;

		sequence_roi_means( ii, : ) = squeeze(mean(mean( sequence_roi_mean )));

	end
end
