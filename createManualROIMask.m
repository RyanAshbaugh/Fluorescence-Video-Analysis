function roi_mask = createManualROIMask( roi_image )


	unique_pixels = unique( roi_image );
	roi_labels = unique_pixels( unique_pixels ~= 0 );
	num_rois = length( roi_labels );

	roi_mask = zeros( [ size( roi_image ), num_rois ], 'logical' );

	for ii = 1:num_rois
		
		roi_num = roi_labels( ii );

		roi_pixel_indices = find( roi_image == roi_num );
		temp_mask = zeros( size( roi_image ) );
		temp_mask( roi_pixel_indices ) = 1;

		roi_mask( :,:, ii ) = temp_mask;

	end

end
