function ROI_masks = createROIMasks( centroids, image_height, image_width )

	num_rois = size( centroids, 1 );
	ROI_masks = zeros( image_height, image_width, num_rois,'logical' );

	for ii = 1:num_rois

		x_center = round( centroids(ii, 1 ) );
		y_center = round( centroids(ii, 2 ) );
	
		ROI_masks( y_center-1:y_center+1, x_center, ii) = 1;
		ROI_masks( y_center, x_center-1:x_center+1, ii) = 1;

	end
end
