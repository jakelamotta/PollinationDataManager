classdef Organizer < handle
    %ORGANIZER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        sources;
        target;
    end
    
    methods (Access = public)
    
        function this = Organizer()
            this.sources = struct;
            this.target = '';
        end
        
        function path = getPath(this,type)
            path = this.paths.(type);
        end
        
        function this = launchGUI(this)
            out_ = loaddata(this.sources);
            if isstruct(out_)
                out2 = loaddatastep2(this.sources,out_.target);
                
                if isstruct(out2)
                    if isstruct(out_)
                        this.sources = out2.sources;
                        this.target = out2.target;
                    end
                end
            end
        end
        
    end
    
end