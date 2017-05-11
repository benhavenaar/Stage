classdef App < handle
    properties
        window;
        graphX;
        
        mark;
        markCounter = 1;
        graph;
        panel;
        menu;
        panMode;
        
        lat;
        slope;
        amplitude;
        
        reader;
        opened = false;
    end
    
    methods 
        function closeApp(self,~,~)
            delete(self.window);
        end
        
        function fileOpenerCallback(self, ~, ~)
            [filename, PathName] = uigetfile('.E01', 'Select E01 File');
            
            if PathName
                self.reader = FILE.Reader([PathName filename]);
                
                if exist([PathName filename '.m'], 'file')
                    L = load([PathName filename '.m'], '-mat');
                    self.graph.points = L.p;
                end
                
                if ~self.opened
                    self.graph.plot(self.reader.all);
                    self.opened = true;
                else
                    self.closeApp
                    self.run;
                    self.graph.plot(self.reader.all);
                end
                self.window.Name = ['ECG: ', filename];
                
            end
        end
        
        function run(self)
            self.create;
            
            self.panel.setCallback(@self.selectableCallback);
            
            self.menu.setOpen(@self.fileOpenerCallback);
            self.menu.setCallbacks(@self.menuCallback);
            
            self.graph.setCallback(@self.infoCallback);
            
            self.show;
            self.markingCallback;
        end
    end
    
    methods (Access = private)
        function create(self)
            self.window = figure('MenuBar', 'none','ToolBar', 'figure',...
                'NumberTitle', 'off', 'Name', 'ECG Test',...
                'units', 'normalized', 'outerposition', [.1 .15 .80 .75],...
                'KeyPressFcn', @self.keyCallback);
            self.graphX = axes(self.window, 'Position', [.05, 0, .95, .5]);

            self.graph = UI.Plot(self.graphX);
            self.panel = UI.Panel(self.window);
            self.menu = UI.Menu;
        end
        
        function show(self)
            self.graph.show;
            self.panel.show;
        end
        
        function keyCallback(self, ~, event)
            switch event.Key
                case 'leftarrow'
                    self.graph.scrollRightCallback; 
                case 'rightarrow'
                    self.graph.scrollLeftCallback;
                case 'uparrow'
                    self.markCounter = 1;
                    self.graph.nextChannel;
                    self.graph.updateMarkers(self.mark);
                    self.panel.channelNumber.String = num2str(self.graph.channel);
                case 'downarrow'
                    self.markCounter = 1;
                    self.graph.previousChannel;
                    self.graph.updateMarkers(self.mark);
                    self.panel.channelNumber.String = num2str(self.graph.channel);
            end
        end
        
        function selectableCallback(self, x)
            switch x
                case 'next'
%                     self.markCounter = 1;
                    self.graph.nextChannel;
                    self.graph.updateMarkers(self.mark);
                    self.panel.channelNumber.String = num2str(self.graph.channel);
                case 'previous'
%                     self.markCounter = 1;
                    self.graph.previousChannel;
                    self.graph.updateMarkers(self.mark);
                    self.panel.channelNumber.String = num2str(self.graph.channel);
                case 'update'
%                     self.markCounter = 1;
                    self.markingCallback;
                    self.graph.updateMarkers(self.mark);
                case 'channel'
                    self.graph.channel = self.panel.channel;
                    self.graph.updateChannel;
                    self.graph.updateMarkers(self.mark);
                case 'nextMark'
                    self.markCounter = self.markCounter + 1;
                    if self.markCounter <= length(self.graph.slope)
                        self.markingCallback;
                        self.graph.updateMarkers(self.mark);
                        self.panel.update(self.lat(self.markCounter), self.slope(self.markCounter), self.amplitude);
                        while self.lat(self.markCounter) > self.graph.scroll+500;
                            self.graph.scrollLeftCallback;
                        end
                        while self.lat(self.markCounter) < self.graph.scroll+500;
                            self.graph.scrollRightCallback;
                        end
                    else
                        self.markCounter = 1;
                        self.markingCallback;
                        self.graph.updateMarkers(self.mark);
                        self.panel.update(self.lat(self.markCounter), self.slope(self.markCounter), self.amplitude);
                    end
                case 'previousMark'
                    self.markCounter = self.markCounter - 1;
                    if self.markCounter < 1
                        self.markCounter = max(length(self.graph.slope));
                        self.markingCallback;
                        self.graph.updateMarkers(self.mark);
                        self.panel.update(self.lat(self.markCounter), self.slope(self.markCounter), self.amplitude);
                    else
                        self.markingCallback;
                        self.graph.updateMarkers(self.mark);
                        self.panel.update(self.lat(self.markCounter), self.slope(self.markCounter), self.amplitude);
                    end
            end
        end
        
        function menuCallback(self, x)
            switch x
                case 'qrs'
                    %qrs toggle hier
                    self.graph.toggleQRS;
                case 'marks'
                    %marks toggle hier
                    self.graph.toggleMarks;
                case 'derivative'
                    self.graph.toggleDerivative;
            end
        end
        
        function infoCallback(self, name, lat, slope, amp)
            switch name
                case 'update'
                    self.slope = slope;
                    self.lat = lat;
                    self.amplitude = amp;
                    self.panel.update(self.lat(self.markCounter), self.slope(self.markCounter), self.amplitude);
            end
        end
        
        function markingCallback(self)
            self.mark = struct;
            self.mark.peakProminence = self.panel.val_peakProminence;
            self.mark.peakDuration = self.panel.val_peakDuration;
            self.mark.valleyProminence = self.panel.val_valleyProminence;
            self.mark.valleyDuration = self.panel.val_valleyDuration;
            self.mark.slopeHeight = self.panel.val_slopeHeight;
            self.mark.slopeDuration = self.panel.val_slopeDuration;
            self.mark.range = self.panel.val_range;
            self.mark.markCounter = self.markCounter;
        end
    end
end