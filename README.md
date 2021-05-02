Cell ROI image sequence analyzer

To analyze a stack of .tif files for cell ROI pixel values over time, start
by running findAndSaveROICentroids.m from the matlab terminal.

Be sure you are in the folder where the analysis files are located.

>> cd 'C:\Name\of\analysis\folder\location'

>> findAndSaveROICentroids

Next, run the file loadROIAndAnalyzeSequence.m. This will show the traces of 
each ROI across all images and allow you to input the desired baseline and 
stimulus frame numbers for analyzing the change in brightness.

>> loadROIAndAnalyzeSequence.m

If you want to analyze the ROIs based on a set of already save ROI centroids,
i.e. to use the same centroids for multiple image sequences or if matlab is
closed and reopened, then running loadROIAndAnalyzeSequence.m will prompt you
to open the saved cell roi centroid file. This will be located at
'C:\name\of\corresponding\image\sequence\folder\cell_roi_centroids.mat', the 
same folder where the corresponding .tifs are that generated the rois.

We clear the variables first so that you will be prompted to select the file
you want.

>> clear all;
>> loadROIAndAnalyzeSequence.m

The result is a display of the mean and median difference between all the
normalized ROI traces at the specified frames, reported in percent change.

To create a video which overlays a small circle on the ROI for all the images
in the trace, use the overlayVideo.m script.

>> overlayVideo

This will save the overlay video as an MP4 in the same location as the images
used to create it.
