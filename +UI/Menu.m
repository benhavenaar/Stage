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
            
            self.v = uimenu('Label', '&View');
            uimenu(self.v, 'Label', '&Show QRS', 'Checked', 'on');
            uimenu(self.v, 'Label', '&Show Markings', 'Checked', 'off');
        end
        
        function setOpen(self, x)
            set(self.f.Children(3), 'Callback', x);
        end
        
        function setCallbacks(self, x)
            self.callback = x;
            
            set(self.v.Children(2), 'Callback', @self.qrsToggle);
            set(self.v.Children(1), 'Callback', @self.marksToggle);
        end
    end
    methods (Access = private)
        function qrsToggle(self, ~, ~)
            state = self.v.Children(2).Checked;
            
            if strcmp(state, 'on')
                self.v.Children(2).Checked = 'off';
            else
                self.v.Children(2).Checked = 'on';
            end
            
            self.callback('qrs');
        end
        
        function marksToggle(self, ~, ~)
            state = self.v.Children(1).Checked;
            
            if strcmp(state, 'on')
                self.v.Children(1).Checked = 'off';
            else
                self.v.Children(1).Checked = 'on';
            end
            
            self.callback('marks');
        end
    end
end