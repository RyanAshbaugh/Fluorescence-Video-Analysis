function meta = setFileMetaData(meta,cur_file)
%setFileMetaData Get info to correctly label titles
%   Purpose: Find the date of experiment, type of experiment
%	Arguments: meta- struct with file info, like directory name
%		cur_file: string of files name
%	Returns: meta- updated meta data struct
    
    backslash = strfind(meta.dname,'\');         % find all '\' in name
	meta.experiment_name = ...
		meta.dname( backslash(end)+1:end )
    meta.date = meta.dname(backslash(end-1)+1:end-1); % go to last '\'
    
    % results folder and output filename
    meta.results_folder = strcat('../Results/fluorescence-video-analysis/',meta.date,...
		'/',meta.experiment_name,'/');
	meta.fname = cur_file.name;
    meta.fpath = [ meta.dname filesep meta.fname ];

	meta.log_fpath = strcat(meta.results_folder,strrep(cur_file.name,'.avi',''));

	% create results folder if it doesn't exist
	%full_results_folder = strcat(meta.results_folder,
	if ~exist(meta.results_folder, 'dir')
		disp([ 'Making directory: ' meta.results_folder ]);
		mkdir(meta.results_folder)
	end
end
