classdef CellInterface < handle
    %CELLINTERFACE Class for simplyfying cell usage. Feel free to use it.
    
    properties
        mCell; %A cell
    end
    
    methods (Static)
        function obj = createRowCell(w)
            obj = CellInterface(1,w);
        end
        
        function obj = createColCell(h)
            obj = CellInterface(h,1);
        end
        
        function obj = createEmptyCell()
           obj = CellInterface(); 
        end
        
        function obj = create2DCell(h,w)
            obj = CellInterface(h,w);
        end    
    end
  
    methods (Access = public)        
        function cell_ = getCell(this)
            cell_ = this.mCell;
        end
        
        function row = getRow(this,index)
            row = this.mCell(index,:);
        end
        
        function this = setRow(this,index,row)
            this.mCell(index,:) = row;
        end
        
        function this = setCol(this,index,col)
            this.mCell(:,index) = col;
        end
                
        function col = getCol(this,index)
           col = this.mCell(:,index); 
        end
        
        function this = set(this,value,varargin)
            if size(varargin) ~= 2
               this.mCell{varargin{1}} = value;
           else
               h = varargin{1};
               w = varargin{2};
               this.mCell{h,w} = value;
           end
        end
        
        function element = get(this,varargin)
           if size(varargin) ~= 2
               element = this.mCell{varargin{1}};
           else
               h = varargin{1};
               w = varargin{2};
               element = this.mCell{h,w};
           end
           element = element{1};           
        end
        
        function section = getSection(this,h1,h2,w1,w2)
            section = this.mCell(h1:h2,w1:w2);
        end
        
        function [h,w] = getSize(this)
           [h,w] = size(this.mCell); 
        end
        
        function h = getHeight(this)
           [h,w] = size(this.mCell); 
        end
        
        function w = getWidth(this)
           [h,w] = size(this.mCell); 
        end
    end
    
    methods (Access = private)
        function this = CellInterface(varargin)
           if isempty(varargin)
               this.mCell = {};
           else
               h = varargin{1};
               w = varargin{2};
               this.mCell = cell(h,w); 
           end
        end
    end
end

