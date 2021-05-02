function normalized_traces = normalizeTraces( input_traces, base_index )

	num_frames = size( input_traces, 2 );
	normalizing_matrix = repmat( input_traces(:,base_index), 1, num_frames );
	normalized_traces = ( input_traces ./ normalizing_matrix ) - 1;

end
