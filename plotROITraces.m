function plotROITraces( normalized_roi_means )

	num_images = size( normalized_roi_means, 2 );

	figure()
	plot( 1:num_images, normalized_roi_means' );
	grid ON; grid MINOR;

end
