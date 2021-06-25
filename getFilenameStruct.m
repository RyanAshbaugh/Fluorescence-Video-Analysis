function filename_struct = getFilenameStruct( directory_name, file_type )
	
	filename_struct = dir(strcat(directory_name, ['/**/*' file_type]));

end
