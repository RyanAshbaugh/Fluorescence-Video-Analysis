function roi_pixel_means = calculateROIPixelMeans( frame, roi_mask )

	roi_pixel_means = zeros( size( roi_mask, 3 ), 1 );
	for ii = 1:size( roi_mask, 3 )
	
		roi_pixel_means( ii ) = mean( frame( roi_mask(:,:,ii) ) );

	end
end
