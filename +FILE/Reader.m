classdef Reader < handle
    properties
        channels;
        signals
    end
    
    methods
        function self = Reader(filename)
            
           fid = fopen(filename, 'r', 'l');
           
           head = fread(fid, 4608, 'unsigned char');
           body = fread(fid, [256 20000], 'int16');
           self.channels = str2double(char(head(1702:1704)'));
           disp(self.channels);
           try
               calibratie = max(gradient(body(self.channels, :)));
               self.signals = body(1:192, :)' ./ calibratie;
           catch
               self.signals = body(1:192,:)' ./ 2500;
           end
            
        end
        
        function ret = all(self)
            ret = self.signals;
        end
    end
    
    
end