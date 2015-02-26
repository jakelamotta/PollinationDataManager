classdef ImageDataAdapter < DataAdapter
    %IMAGEDATAADAPTER Class for adapting images to an Observation object.
    %Image must be in the format of a squared pixel matrix in grayscale
    
    properties
        init;
    end
    
    methods (Access = public)
        
        %%Constructor
        function this = ImageDataAdapter()
            this.init = {'Im_Contrast','Im_Correlation','Im_Energy','Im_Homogenity','Im_Entropy','Im_rms_contr','Im_Alpha'};
            this.tempMatrix = this.init;
        	this.dobj = Observation();
        end
        
        %%See DataAdapter for implementation
        function this = addValues(this,p)
            this.tempMatrix = addValues@DataAdapter(this,p,this.tempMatrix);
        end
        
        %%Function for retrieving a Observation object with
        %%Image data
        %%Input - Cell of paths
        %%Output - Observation object
        function obj = getObservation(this,paths,varargin)
            tic;
            
            [h,w] = size(paths);
            this.nrOfPaths = w;
            inputManager = varargin{2};
            handler = inputManager.getDataManager().getHandler();
            
            images = struct;
            folders = {};
            
            for i=1:w
                this.updateProgress(i);
                idx = strfind(paths{1,i},'\');
                
                [pathstr,name,ext] = fileparts(paths{1,i});
                
                try
                    id_ = paths{1,i}(idx(end-2)+1:idx(end-1)-1);
                    
                    if ~isfield(images,strrep(id_,'.','__'))
                        images.(strrep(id_,'.','__')) = {[];[];[]};
                        folders{end+1} = pathstr;
                    end
                    
                catch e
                    errordlg(['Incorrect path was passed to the file reader. Matlab error: ',e.message()]);
                end
                
                rawData = this.fileReader(paths{1,i});
                
                images.(strrep(id_,'.','__')) = [images.(strrep(id_,'.','__')),{rawData;paths{1,i}(idx(end)+1:end);false}];
            end
            
            fnames = fieldnames(images);
            nrOfFnames = length(fnames);
            close(this.mWaitbar);
            
            for i=1:nrOfFnames
                
                fname = images.(fnames{i});
                [ims,mcontinue] = handler.getCroppedImage(fname,fnames{i});
                
                if ~mcontinue
                    break;
                end
                
                s = size(ims);
                
                for h_=1:s(2)
                    im = ims{1,h_};
                    keepImage = ims{3,h_};
                    
                    if keepImage
                        if ndims(im) == 3
                            im = rgb2gray(im);
                        end
                        
                        [h,w] = size(im);
                        
                        if h < w
                            d = (w-h)/2;
                            im = im(:,d:end-d-1);
                        elseif w < h
                            d = (h-w)/2;
                            im = im(d:end-d-1,:);
                        end
                        
                        %Waitbar for letting the user know calculation is
                        %progressing
                        imWaitbar = waitbar(0,'Please wait while image parameters are calculated...',...
                            'Name',this.toString());
                        
                        nrOfSteps = 4;
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Olga script below%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        im=double(im)/255;
                        im_mean=mean2(im);
                        under_sum=(im-im_mean).^2;
                        im_sum=sum(sum(under_sum));
                        rms_contr=sqrt((1/(h^2))*(im_sum));
                        
                        % calculate parameters
                        k=graycomatrix(im, 'offset', [0 1; -1 1; -1 0; -1 -1],'NumLevels',256);
                        stats = graycoprops(k,{'contrast','homogeneity','Correlation','Energy'});
                        ent = entropy(im);
                        
                        waitbar(1/nrOfSteps); %Display progress for user
                        
                        [M N] = size(im);
                        imfft = fftshift(fft2(im));
                        imabs = abs(imfft);
                        
                        abs_av=rotavg(imabs);
                        waitbar(2/nrOfSteps);%Display progress for user
                        
                        freq2=0:N/2;
                        
                        if length(freq2) < 10^2
                            xx=log(freq2(10:length(freq2)));
                            yy=log(abs_av(freq2(10:length(freq2))));
                        else
                            xx=log(freq2(10:10^2));
                            yy=log(abs_av(freq2(10:10^2)));
                        end
                        waitbar(3/nrOfSteps);%Display progress for user
                        p=polyfit(xx',yy,1);
                        alpha=(-1)*p(1);
                        
                        % get a result of 6 parameters for 1 image
                        parameters = {mean(stats.Contrast),mean(stats.Correlation),...
                            mean(stats.Energy),mean(stats.Homogeneity),ent,rms_contr,alpha};
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Olga script above%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%here%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        waitbar(4/nrOfSteps);%Display progress for user
                        close(imWaitbar);
                        
                        this.tempMatrix = [this.tempMatrix;parameters];
                        
                        this = this.addValues([folders{1,i},'\t']);
                        
                        this.dobj.setObservation(this.tempMatrix,strrep(fnames{i},'__','.'));
                        this.tempMatrix = this.init;
                        imwrite(im,fullfile(folders{i},['cropped_',ims{2,h_}]));
                    end
                end
            end
            
            obj = this.dobj;
            toc
        end
        
        %%See DataAdapter for fileReader implementation
        function rawData = fileReader(this,path)
            rawData = imread(path); % load image
        end
    end
end

