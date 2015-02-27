classdef Utilities
    %UTILITIES Utility class contaning som static methods for generic tasks
    %that are useful for many different classes
    
    methods (Static)
        

        function [first,second] = padMatrix(first, second)
            [h1,w1] = size(first);
            [h2,w2] = size(second);
            
            diff = abs(w1-w2);
            
            if w1 < w2
                newMat = cell(h1,diff);
                first = [first,newMat];
                first(1,:) = second(1,:);
            elseif w1 > w2
                newMat = cell(h2,diff);
                second = [second,newMat];
                second(1,:) = first(1,:);
            end
        end
                
        %%
        function [path] = getpath(file)
            %Returns correct path for given file and type, only the relative paths are
            %hardcoded because they are not subjects of change
            tmp = mfilename('fullpath'); %Returns path of current m-file
            
            prefixpy = [tmp(1:end-length(mfilename)),'data'];
            %path = [prefixpy,file];
            path = fullfile(prefixpy,file);
        end
        
        %%Pad a string with the input string padWidth so that the input is
        %%of length len
        function outStr = padString(inVal,padWith,len)
            outStr = inVal;
            while length(outStr) < len
                outStr = [padWith,outStr];
            end
        end
        
        %%Function for returning
        function monthNr = getMonthFromString(month)
           months = containers.Map({'jan','feb','mar','apr','may','jun','jul',...
               'aug','sep','oct','nov','dec'},{'1','2','3','4','5','6',...
               '7','8','9','10','11','12'});
           
           monthNr = months(month);
        end
    end
end

