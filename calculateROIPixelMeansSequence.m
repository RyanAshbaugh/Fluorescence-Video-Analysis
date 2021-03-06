function sequence_roi_means = ...
		calculateROIPixelMeansSequence( image_sequence, centroids )

	num_rois = size( centroids, 1 );
	num_frames = size( image_sequence, 3 );
	sequence_roi_means = zeros( num_rois, num_frames );
	
	for ii = 1:num_rois

		x_center = round( centroids(ii, 1 ) );
		y_center = round( centroids(ii, 2 ) );
	
		sequence_roi_means( ii, : ) = squeeze( mean( mean( ...
			image_sequence(y_center-1:y_center+1,x_center-1:x_center+1,:))));

	end
end
