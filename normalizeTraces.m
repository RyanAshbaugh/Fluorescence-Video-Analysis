function normalized_traces = normalizeTraces( input_traces )

	num_frames = size( input_traces, 2 );
	normalizing_matrix = repmat( input_traces(:,1), 1, num_frames );;
	normalized_traces = ( input_traces ./ normalizing_matrix ) - 1;

end
