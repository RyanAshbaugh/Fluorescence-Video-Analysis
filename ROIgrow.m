function [ROIlayers]=ROIgrow (Data,ROIcount,Tol,mode)

%Uses a simple region growing method to generate an ROI from a dataset.
%Data is the dataset to be used. Must be a 2D matrix
%ROI count is the number of ROIs that you want it to identify, a scalar
%integer
%Tol is the tolerance, the ROI will grow based off of whether the
%neighboring pixels are within the tolerance*value of center pixel
%mode determines what kind of output. if mode=='logical', the program will
%make the masks a 1 and the rest a 0. Elsewise they are going to be
%numbered by their time of generation.
if ndims(Data)>2
    error('Data must be 2D')
end

ROImap=zeros(size(Data,1),size(Data,2));

% matrix size of input image and depth ch for each ROI
ROIlayers=zeros(size(Data,1),size(Data,2),ROIcount);

% for every ROI in number of ROI's specified
for I=1:ROIcount

	% get location (left->right, top->down search) of highest pixel in matrix
    Highpoint=find(Data==max(max(Data)));

	% if it equals zero, set to the ROI number
    if ROImap(Highpoint(1))==0
        ROImap(Highpoint(1))=I;
    end

	%
    Oldsum=0;
    Newsum=1;

    while Newsum>Oldsum
        Oldsum=sum(sum(ROImap));
        [row,col]=find(ROImap==I);

		% for every row
        for index=1:length(row)
            x=row(index);
            y=col(index);
            for xdif=[-1,1]
                for ydif=[-1,1]
                    xcheck=x+xdif;
                    ycheck=y+ydif;
                    if ycheck>0 && ycheck<=size(Data,2)
                        if Data(x,ycheck)>=(Tol*max(max(Data)))
                            ROImap(x,ycheck)=I;
                        end
                    end
                    if xcheck>0 && xcheck<=size(Data,1) 
                        if Data(xcheck,y)>=(Tol*max(max(Data)))
                            ROImap(xcheck,y)=I;
                        end
                    end
                end
            end
        end
        Newsum=sum(sum(ROImap));
    end
    
    for x=1:size(Data,1)
        for y=1:size(Data,2)
            if ROImap(x,y)==I
                ROIlayers(x,y,I)=1;
                Data(x,y)=0;
            end
        end
    end
end

% if mode is set to logical, set output to 0s and 1s,
% 1s in location of the detected rois
if strcmp(mode, 'logical')==1
    ROIlayers=cast(ROIlayers,'logical');

% else if mode is set to numbered, output is map with numbers coding
% for unique ROIs
elseif strcmp(mode, 'numbered')==1
    ROIlayers=ROImap;
end
