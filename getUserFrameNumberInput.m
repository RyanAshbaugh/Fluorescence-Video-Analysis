function [ baseline_index, post_stim_index ] = getUserFrameNumberInput()

	prompt = {'Enter baseline frame number:', 'Enter post stim frame number:'};
	dialog_title = 'Frame numbers for analysis';
	frame_input = inputdlg(prompt,dialog_title,[1,50] );

	baseline_index = str2num( frame_input{1} );
	post_stim_index = str2num( frame_input{2} );

end
