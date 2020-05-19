video_fname = 'C:\Users\rashb\Documents\NDEL\Data\Microscope\9-11-19_epg+gcamp_fluoro\HEK_epg+gcamp_10mt_2_1_2\20190911115021_HEK_epg+gcamp_10mt_2_1_2_roi1.avi';

video = VideoReader(video_fname);
green_channel = 2;

%processed_video_fname = [ pwd '\20190911115021_HEK_epg+gcamp_10mt_2_1_2_roi1_processed.avi' ];
processed_video_fname = [ 'C:\Users\rashb\Videos\20190911115021_HEK_epg+gcamp_10mt_2_1_2_roi1_processed.avi' ];

processed_video = VideoWriter( processed_video_fname, 'Grayscale AVI');
processed_video.FrameRate = 5;
open( processed_video );

%imread();

for jj = 1:700
	

	%past_frame = read(video, jj-1);
	frame_delta = 2; % * 200 msec
	frame1 = read(video, jj);
	frame2 = read(video, jj + frame_delta);

	just_hist = histeq(frame1);
	%imwrite( frame1,[ pwd '\video_processing\frames\' num2str(jj) '.png' ]);

	difference_frame = ...
		abs( frame2(:,:,green_channel) - frame1(:,:,green_channel) );
	difference_frame = histeq(difference_frame);

	pixel_mean = mean(difference_frame,'all');
	pixel_sd = std(single(difference_frame));
	difference_frame( find(difference_frame < (pixel_mean + pixel_sd*2) ) ) = 0;

	median_filtered = medfilt2(difference_frame,[5,5]);

	% threshold_value = graythresh( difference_frame );
	% difference_frame( find(difference_frame < 255*threshold_value) ) = 0;

	% average multiple frames to get rid of nois
	%stacked_image = cat(2,past_frame,frame2);
	%averaged_image = mean(stacked_image,3);

	%writeVideo( processed_video, median_filtered );
	writeVideo( processed_video, just_hist(:,:,green_channel) );


end

%% normalize tag to max change of whole video

disp([ 'Closing video: ' processed_video_fname ]);
close(processed_video);

