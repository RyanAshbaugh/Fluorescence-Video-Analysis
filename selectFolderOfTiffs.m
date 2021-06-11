function dname = selectFolderOfTiffs();
	
	disp([ newline 'Select a folder containing the .tifs to be analyzed...' ]);
	dname = strcat( ...
		uigetdir('Select a folder containing the .tifs to be analyzed'),...
		filesep);
	disp([ 'Selected folder: ', dname newline ] );

end
