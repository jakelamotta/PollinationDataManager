classdef AdapterFactory
    %ADAPTERFACTORY If new file types are added they should be added under
    %the constructor. Otherwise this class should never need to change.
    
    properties
        adapters
    end
    
    methods (Access = public)
        
        function this = AdapterFactory()
            this.adapters = containers.Map;
            this.adapters('Abiotic') = @() AbioticDataAdapter();
            this.adapters('Spectro') = @() SpectroDataAdapter();
            this.adapters('Weather') = @() WeatherDataAdapter();
            this.adapters('Image') = @() ImageDataAdapter();
            this.adapters('Behavior') = @() BehaviorDataAdapter();
            this.adapters('Olfactory') = @() OlfactoryDataAdapter();
            this.adapters('SpectroJaz') = @() SpectroJazDataAdapter();
        end
        
        %%Create 
        function adapter = createAdapter(this,id)
            if this.adapters.isKey(id)
                adapter = this.adapters(id);
                adapter = adapter();
            else
                adapter = '';
            end
        end
    end    
end