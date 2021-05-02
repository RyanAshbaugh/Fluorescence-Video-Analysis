function roi_image = detectROIs( image, laplacian_percent_threshold )

	se = strel( 'square', 3 );
	first_median_kernel = [ 3 3 ];
	second_median_kernel = [ 3 3 ];

	% take Laplacian of best frame
	lap_thresh_image = ...
		thresholdedAbsoluteLaplacian( image, laplacian_percent_threshold);

	% get product of thresholded laplacian and original
	masked_by_laplacian = image .* uint16( lap_thresh_image );

	% binarize based on new masked image
	binarized = imbinarize( masked_by_laplacian, 'adaptive' );

	medfiltered_image_1 = medfilt2( binarized, first_median_kernel );

	% erode and regrow image
	eroded_image = imerode( medfiltered_image_1, se );

	% filter and dilate
	medfiltered_image_2 = medfilt2( eroded_image, second_median_kernel );

	roi_image = imdilate( medfiltered_image_2, se );

end
