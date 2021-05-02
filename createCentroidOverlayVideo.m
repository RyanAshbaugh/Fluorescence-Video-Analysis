function createCentroidOverlayVideo( directory_name, frame_rate, ...
		image_sequence, roi_centroids, circle_radii )

	% setup video
	output_video_fname = strcat( directory_name, 'cell_overlay.mp4' );
	output_video = VideoWriter( output_video_fname, 'MPEG-4' );
	output_video.FrameRate = frame_rate;
	open( output_video );

	figure('name', 'Centroid overlay')
	for ii = 1:size( image_sequence, 3 )

		temp_img = image_sequence(:,:,ii);
		temp_color = uint8( temp_img / (2^8) );

		hold on;
		imshow( histeq(temp_color) );
		viscircles( roi_centroids, repmat( circle_radii, ...
			size( roi_centroids,1 ), 1 ) );
		hold off;
		drawnow();

		writeVideo( output_video, getframe );

	end

	close( output_video );
end
