function delta_bright = calculateDeltaBright( traces, end_index )

	delta_bright = traces( :, end_index ) - traces(:,1 );

end
