classdef Menu < handle
    properties
        f;
        e;
        v;
        h;
        
        callback;
    end

    methods
        function self = Menu
            self.f = uimenu('Label', '&File');
            uimenu(self.f, 'Label', '&Open');
            uimenu(self.f, 'Label', '&Save');
            uimenu(self.f, 'Label', '&Close');
        end
        
        function setOpen(self, x)
            set(self.f.Children(3), 'Callback', x);
        end            
    end
    
end