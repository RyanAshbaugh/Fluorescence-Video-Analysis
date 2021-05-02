function filtered_image = laplacianFilterImage( frame )

	lap_filter = [ - 1, -1, -1; -1, 8, -1; -1, -1, -1 ];
	filtered_image = abs( conv2( frame, lap_filter, 'same' ) );

end
