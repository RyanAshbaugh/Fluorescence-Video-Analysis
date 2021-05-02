function roi_centroids = calculateROICentroids( roi_image )

	roi_stats = regionprops( roi_image, 'Centroid' );
	roi_centroids = cat(1, roi_stats.Centroid );

end
