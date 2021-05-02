function dname = selectFolderOfTiffs();
	
	disp([ newline 'Select a folder containing the .tifs to be analyzed...' ]);
	dname = strcat(uigetdir('Select Folder'),'\');
	disp([ 'Selected folder: ', dname newline ] );

end
