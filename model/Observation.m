classdef Observation < handle
    %Observation - This class encapsulates the information of an
    %observation, the xlsMatrix is implemented as an cell array as all
    %cells do not contain numbers. This matrix is what is going to be
    %written to the final excel-file.
    
    properties (Access = private)
        %The xlsMatrix is what hold all data when it has been loaded in to
        %the program. 
        xlsMatrix;
        numOfStandardVariables;
        interpMap;
    end
    
    methods (Access = public)
        
        %%Constructor. Initializes the object
        function this = Observation(varargin)
            global matrixColumns;
            this.interpMap = containers.Map();
            this.interpMap('Spectro') = false;
            this.interpMap('SpectroJaz') = false;
            this.interpMap('Olfactory') = false;
            
            if isempty(varargin)
                this.xlsMatrix = [matrixColumns,{'lux_flower','lux_up','SpectroX','SpectroY','SpectroXUp','SpectroYUp','OlfX','OlfY'}];
                this.numOfStandardVariables = uint32(Constants.StandardVarsPos);
            else
                this.xlsMatrix = varargin{1};
                this.numOfStandardVariables = varargin{2};
            end
        end
        
        %%Adding an observation to another, it doesnt consider copies or
        %ids but simply appends the rows from the input observation to the
        %to the current
        function this = appendObservation(this,obj)
            matrix = obj.getMatrix();
            [this.xlsMatrix,matrix] = Utilities.padMatrix(this.xlsMatrix,matrix);
            this.setMatrix([this.xlsMatrix;matrix(2:end,:)]);
        end
        
        %%Function for removing NaN from cells in the cell containing all
        %%the data
        function this = removeNaN(this)
           for h=2:this.getNumRows()
               for w=1:this.getWidth()
                   if isnan(this.get(h,w))
                       this.set(h,w,[]);
                   end
               end
           end
        end
        
        %%Adds zeroes to any empty cell in the Observation cell array
        function this = fillWithZeros(this)
            for i=4:this.getWidth()
                for j=2:this.getNumRows()
                    if isemtpy(this.xlsMatrix{j,i})
                        this.xlsMatrix{j,i} = 0;
                    end
                end
            end
        end
        
        %%Boolean function that checks if there are multiples of any id in
        %%the observation matrix
        function hasMultiples = hasMultiples(this)
            this.sortById();
            hasMultiples = false;
            
            for i=3:this.getNumRows()
                if strcmp(this.xlsMatrix{i,2},this.xlsMatrix{i-1,2})
                    hasMultiples = true;
                    break;
                end
            end
        end
        
        %%Sorts the observation matrix by ID
        function this = sortById(this)
            matrix = this.getMatrix();
            
            data = matrix(2:end,:);
            topRow = matrix(1,:);
            
            data = sortrows(data,2);
            
            matrix = [topRow;data];
            this.setMatrix(matrix);
        end
        
        %%Calculates average for each observation.
        function this = doAverage(this,colStart)
            %First sort by id so that each obs is gathered within a span of
            %rows
            this.sortById();
            
            matrix = this.getMatrix();
            
            %Just remove the row with column names
            firstRow = matrix(1,:);
            
            %A temporary matrix without column names
            matrix = matrix(2:end,:);
            
            height = this.getNumRows()-1;
            
            indices = [1,0];
            temp = matrix{1,2};
            
            %For each row compare id with the previous, this way the rows
            %where a new observation starts can be found. They are placed
            %in "indices"
            for k=1:height
                if ~strcmp(temp,matrix{k,2})
                    indices(end) = k-1;
                    indices = [indices;[k,0]];
                    temp = matrix{k,2};
                end
            end
            
            indices(end,end) = height;
            
            [h,w] = size(indices);
            
            averaged = cell(h,this.getWidth());
            
            for i=1:h
                start = indices(i,1);
                end_ = indices(i,2);
                
                tempRows = matrix(start:end_,:);
                avgRow = this.average(colStart,tempRows);
                averaged(i,:) = avgRow;
            end
            
            averaged = [firstRow;averaged];
            
            this.setMatrix(averaged);
        end
        
        %%Initially the data for Olfactory and the spectrum points of Spectrophotometerdata
        %%are stored in arrays in the cell. These arrays need to be removed
        %%before the Observation can be displayed in a table
        function this = removeArrays(this)
            matrix = this.getMatrix();
            matrix = [matrix(:,1:uint32(Constants.SpectroXPos)-1),matrix(:,uint32(Constants.OlfYPos)+1:end)];
            this.setMatrix(matrix);
        end
        
        %%Calculate average for the input rows starting from column
        %%"colStart
        function row = average(this,colStart,rows)
            
            [h,w] = size(rows);
            row = cell(1,w);
            
            %Add the values that are not going to be averaged
            for i=1:this.numOfStandardVariables
                row{i} = rows{1,i};
            end
            
            for i=colStart:w
                temp = 0;
                counter = 0;
                
                for j=1:h                    
                    if isnumeric(rows{j,i})
                        if ~isempty(rows{j,i})
                                temp = temp+rows{j,i};
                                counter = counter+1;
                        end                        
                    else
                        if ~isnan(str2double(rows{j,i}))
                            v = str2double(rows{j,i});
                            if ~isempty(v) && v ~= 0
                                temp = temp+v;
                                counter = counter+1;
                            end
                        end
                    end
                end
                
                if isnumeric(temp)
                    if ~isempty(temp)
                        if temp ~= 0
                            avg = temp/counter;
                            row{i} = avg;
                        end
                    else
                        row{i} = temp;
                    end
                else
                    row{i} = temp;
                end
            end            
        end
        
        %%Interpolating spectrophotometer or olfactory data
        function this = downSample(this,dsrate,type)
            y1pos = uint32(Constants.SpectroYPos);
            y2pos = uint32(Constants.SpectroYUpPos);
            x1newpos = uint32(Constants.SpectroXPos);
            x2newpos = uint32(Constants.SpectroXUpPos);
            
            matrix = this.getMatrix();
            height = this.getNumRows();
            
            if ischar(dsrate)
                dsrate = str2double(dsrate);
            end
            
            %Use a different interpolation method for different data types
            if strcmp(type,'Spectro')
                for i=2:height
                    y1 = matrix{i,y1pos};
                    x1 = matrix{i,x1newpos};
                    y2 = matrix{i,y2pos};
                    x2 = matrix{i,x2newpos};
                    
                    x1new = round(linspace(380,600,dsrate));
                    x2new = round(linspace(380,600,dsrate));
                    
                    y1 = interp1(x1,y1,x1new);
                    y2 = interp1(x2,y2,x2new);
                    
                    matrix{i,y1pos} = y1;
                    matrix{i,y2pos} = y2;
                    matrix{i,x1newpos} = x1new;
                    matrix{i,x2newpos} = x2new;
                end
                
            elseif strcmp(type,'SpectroJaz')
                for i=2:height
                    y1 = matrix{i,y1pos};
                    x1 = matrix{i,x1newpos};
                    
                    x1new = round(linspace(380,600,dsrate));
                    
                    y1 = interp1(x1,y1,x1new);
                    
                    matrix{i,y1pos} = y1;
                    matrix{i,x1newpos} = x1new;
                end
                
            elseif strcmp(type,'Olfactory')
                y1pos = uint32(Constants.OlfYPos);
                x1newpos = uint32(Constants.OlfXPos);
                
                for i=2:height
                    
                    
                    y1 = matrix{i,y1pos};
                    x1 = matrix{i,x1newpos};
                    
                    if this.getInterp('id')                    
                        x1new = linspace(min(x1),max(x1),dsrate);
                    
                        y1 = interp1(x1,y1,x1new);
                    
                        matrix{i,y1pos} = y1;
                        matrix{i,x1newpos} = x1new;
                    else
                       matrix{i,y1pos} = y1(1:dsrate);
                       matrix{i,x1newpos} = x1(1:dsrate);
                       a = 1;
                    end
                end
            end
            this.setMatrix(matrix);
        end
        
        %%Function for 
        function this = inflateSpectrumPoints(this,type)
            matrix = this.getMatrix();
            height = this.getNumRows();
            
            if strcmpi(type,'Spectro')
                spectroXpos = uint32(Constants.SpectroXPos);
                spectroXuppos = uint32(Constants.SpectroXUpPos);
                
                y1 = matrix{2,spectroXpos};
                y2 = matrix{2,spectroXuppos};
                
                appendee = cell(height,2*length(y1));
                
                for j=2:height
                    row = matrix(j,:);
                    
                    x1 = row{uint32(Constants.SpectroYPos)};
                    x2 = row{uint32(Constants.SpectroYUpPos)};
                    
                    for k=1:length(x1)
                        
                        if j==2
                            appendee{1,k} = [num2str(y1(k)),'_f'];
                            appendee{1,k+length(x1)} = [num2str(y2(k)),'_u'];
                        end
                        
                        appendee{j,k} = x1(k);
                        appendee{j,k+length(x1)} = x2(k);
                    end
                end
                
            elseif strcmpi(type,'SpectroJaz')
                spectroXpos = uint32(Constants.SpectroXPos);
                
                y1 = matrix{2,spectroXpos};
                
                appendee = cell(height,length(y1));
                
                for j=2:height
                    row = matrix(j,:);
                    x1 = row{uint32(Constants.SpectroYPos)};
                    
                    for k=1:length(x1)                        
                        appendee{j,k} = x1(k);
                    end
                end
                
            elseif strcmpi(type,'Olfactory')
                y1 = matrix{2,uint32(Constants.OlfXPos)};                
                appendee = cell(height,length(y1));
                
                for j=2:height
                    row = matrix(j,:);
                    
                    x1 = row{uint32(Constants.OlfYPos)};
                    
                    for k=1:length(x1)
                        if j==2
                            appendee{1,k} = y1(k);
                        end
                        appendee{j,k} = x1(k);
                    end
                end
            end
            
            matrix = [matrix,appendee];
            this.setMatrix(matrix);
        end
        
        %%Sorts the observations by date
        function this = sortByDate(this)
            matrix = this.getMatrix();
            data = matrix(2:end,:);
            topRow = matrix(1,:);
            data = sortrows(data,3);
            matrix = [topRow;data];
            this.setMatrix(matrix);
        end
                
        %%Function for merging a row
        function this = combine(this,id)
            mergeObj = Observation();
            matrix = this.getMatrix();
            
            row = [matrix(1,:);cell(1,this.getWidth())];
            
            for j=2:this.getNumRows()
                if strcmp(id,matrix{j,2})
                    for i=1:this.getWidth()
                        if isempty(row{2,i})
                            if ischar(matrix{j,i})
                                row{2,i} = matrix{j,i};
                            else
                                if ~isnan(matrix{j,i})
                                    row{2,i} = matrix{j,i};
                                end
                            end
                        end
                    end
                end
            end
            
            while (this.isObservation(id))
                this.deleteRowFromID(id);
            end
            
            mergeObj.setMatrix(row);
            this.appendObservation(mergeObj);
        end
        
        %%Boolean function that checks if the input ID already exists as an
        %%observation
        function isObs = isObservation(this,id)
            isObs = false;
            for i=2:this.getNumRows()
                isObs = strcmp(id,this.xlsMatrix{i,2});
                if isObs
                    break;
                end
            end
        end
                
        %%Function that deletes a single row corresponding to the input ID
        function this = deleteRowFromID(this,id)
            mat = this.getMatrix();
            height = this.getNumRows();
            rowNr = -1;
            for i=2:height
                if strcmp(strrep(id,'.',''),strrep(mat{i,2},'.',''))
                    rowNr = i;
                end
            end
            
            if rowNr ~= -1
                mat = [mat(1:rowNr-1,:);mat(rowNr+1:end,:)];
            end
            this.setMatrix(mat);
        end
        
        %%Function that takes a cell array and an ID as input, the elements
        %%of the cell array are indvidually mapped to columns in the
        %%observation matrix. All are set to the same row with ID id.
        function this = setObservation(this,matrix,id)
            s = size(matrix);
            
            appendCell = cell(s(1),this.getWidth());
            
            start = 1;
            
            counter = 0;
            
            for i=1:s(2)
                for j=start:this.getWidth()
                    
                    if strcmp(this.xlsMatrix{1,j},matrix{1,i})
                        for k=2:s(1);
                            counter = counter +1;
                            appendCell{k,uint32(Constants.IdPos)} = id;
                            appendCell{k,j} = matrix{k,i};
                        end
                        break;
                    end
                    counter = counter+1;
                end
            end
            
            [this.xlsMatrix,appendCell] = Utilities.padMatrix(this.xlsMatrix,appendCell);
            this.xlsMatrix = [this.xlsMatrix;appendCell(2:end,:)];
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%GETTERS AND SETTERS%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function spectroTime = getSpectroTime(this,id)
            spectroTime = '';
            for i=4:this.getWidth()
                if strcmp(this.xlsMatrix{1,i},'/SpectroTime')
                    for j=2:this.getNumRows()
                        if strcmp(id,this.xlsMatrix{j,2})
                            spectroTime = this.xlsMatrix{j,i};
                        end
                    end
                end
            end
        end
        
        function abioticTime = getAbioticTime(this,id)
            abioticTime = '';
            for i=4:this.getWidth()
                if strcmp(this.xlsMatrix{1,i},'/AbioTime')
                    for j=2:this.getNumRows()
                        if strcmp(id,this.xlsMatrix{j,2})
                            abioticTime = this.xlsMatrix{j,i};
                        end
                    end
                end
            end
        end
        
        function width = getWidth(this)
            [h,width] = size(this.xlsMatrix);
        end
        
        %%Returns number of rows
        function height = getNumRows(this)
            [height,w] = size(this.xlsMatrix);
        end
        
        function id = getObjectID(this)
            id = cell(1,1);
            
            for i=1:this.getWidth()
                if strcmp('ID',this.xlsMatrix{1,i})
                    id{1,1} = this.xlsMatrix{2,i};
                end
            end
            
            for i=3:this.getNumRows()
                for j=1:this.getWidth()
                    if strcmp('ID',this.xlsMatrix{1,j})
                        id{1,i-1} = this.xlsMatrix{i,j};
                    end
                end
            end
        end
        
        function element = get(this,h,w)
            element = this.xlsMatrix{h,w};
        end
        
        function this = set(this,h,w,value)
            this.xlsMatrix{h,w} = value;
        end
        
        function section = getSection(this,varargin)
           if length(varargin) == 4
               h1 = varargin{1};
               h2= varargin{2};
               w1= varargin{3};
               w2 = varargin{4};
               section = this.xlsMatrix(h1:h2,w1:w2);
           end
        end
        
        function row = getRowFromID(this,id)
            height = this.getNumRows();
            width = this.getWidth();
            row = [];
            
            for i=2:height
                for j=1:width
                    if strcmp(this.xlsMatrix{1,j},'ID')
                        if strcmp(strrep(this.xlsMatrix{i,j},'.',''),strrep(id,'.',''))
                            row = [this.xlsMatrix(1,:);this.xlsMatrix(i,:)];
                            break;
                        end
                    end
                end
            end
        end
        
        function matrix = getMatrix(this)
            matrix = this.xlsMatrix;
        end
        
        function this = setMatrix(this,m)
            this.xlsMatrix = m;
        end
        
        function id = getIdAtRow(this,r)
           id = this.xlsMatrix{r,2};
        end
        
        function this = setID(this,id)
            height = this.getNumRows();
            this.xlsMatrix{height+1,2} = id;
        end
        
        function comment = getCommentFromId(this,id)
           row = this.getRowFromID(id);
           comment = row{2,4};
        end
        
        function interp = getInterp(this,id)
            interp = false;
            if isKey(this.interpMap,id)
                interp = this.interpMap(id);                    
            end
        end
        
        function setInterp(this,id,bool)
           this.interpMap(id) = bool; 
        end
    end
end