function overlay_image = overlayFullROIs( image, roi_overlay )

	color_frame = uint8( image/ (2^8) );

	rgb_image = cat( 3, color_frame, color_frame, color_frame );

	overlay_image = imoverlay( histeq( rgb_image ), roi_overlay, 'r' );

end
