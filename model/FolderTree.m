classdef FolderTree < handle
    %FolderTree. Simple data structure that is organized as a hierarchy
    %tree. Only used for keepin track of metadata for writing to word.
    %Should never need to be changed.
    
    properties (Access = private)
        parent; %FolderTree - parent of current object, if null current is root
        children; %Cellarray of FolderTrees - list of children
        issource; %Boolean - True if root, false if has parent
        source;
        name; %String
    end
    
    methods (Access = public)
       
        
        %%Constructor. Called with a name and an option for passing a
        %%FolderTree object as parent. The root tree is the only one that
        %%does not have a parent.
        function this = FolderTree(n,varargin)            
           this.name = n;
           this.children = {};
           
           if isempty(varargin)
               this.issource = true;
           else
               p = varargin{1};
               this.parent = p;
               p.addChild(this);                    
           end           
        end
        
        %%
        function toString(this)
            disp(this.name);
        end
        
        %%Pops a child from the children list
        function child = popChild(this)
            child = this.children{1};            
            
            if length(this.children) >= 2            
                this.children = this.children(2:end);
            else
                this.children = {};
            end
        end
        
        %%Boolean function, returns true if the Tree has at least one child
        %%and false otherwise
        function haschildren = hasChildren(this)
           haschildren = ~isempty(this.children); 
        end
        
        %%Boolean function, returns true if the tree is a parent. It is only
        %% the root tree that does not have a parent.
        function isparent = isParent(this)
            isparent = true;
            
            if isempty(this.children)
               isparent = false; 
            end
        end
        
        %%Function for adding a child to a tree.
        function this = addChild(this,child)
           this.children = [this.children,{child}]; 
        end        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%GETTERS AND SETTERS%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        function p = getParent(this)
            p = this.parent;
        end
        
        function depth = getDepth(this)            
            node = this;            
            depth = 0;
            while node.hasChildren()
                depth = depth + 1;
                node = node.popChild();
            end
        end
        
        function n = getName(this)
            n= this.name;
        end
        
        function child = getChildAtIndex(this,index)
           child = this.children{index}; 
        end
        
        function childrenList = getChildren(this)
            childrenList = this.children;
        end
    end    
end

