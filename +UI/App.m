classdef App < handle
    properties
        window;
        graphX;
        
        mark;
        graph;
        panel;
        menu;
        panMode;
        
        opened = false;
    end
    
    methods
        function closeApp(self,~,~)
            delete(self.window);
        end
        
        function fileOpenerCallback(self, ~, ~)
            [filename, PathName] = uigetfile('.E01', 'Select E01 File');
            
            if PathName
                disp(filename);
                disp(PathName);
            end
        end
        
        function run(self)
            self.create;
            
            self.panel.setCallback(@self.selectableCallback);
            
            self.menu.setOpen(@self.fileOpenerCallback);
            
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
            self.graph.plot;
            self.panel.show;
        end
        
        function keyCallback(self, ~, event)
            switch event.Key
                case 'leftarrow'
                    self.graph.scrollRightCallback; 
                case 'rightarrow'
                    self.graph.scrollLeftCallback;
                case 'uparrow'
                    self.graph.nextChannel;
                    self.graph.updateMarkers(self.mark);
                    self.panel.channelNumber.String = num2str(self.graph.channel);
                case 'downarrow'
                    self.graph.previousChannel;
                    self.graph.updateMarkers(self.mark);
                    self.panel.channelNumber.String = num2str(self.graph.channel);
                case 'c'
                    self.graph.clearMarkers;
            end
        end
        
        function selectableCallback(self, x)
            switch x
                case 'next'
                    self.graph.nextChannel;
                    self.graph.updateMarkers(self.mark);
                    self.panel.channelNumber.String = num2str(self.graph.channel);
                case 'previous'
                    self.graph.previousChannel;
                    self.graph.updateMarkers(self.mark);
                    self.panel.channelNumber.String = num2str(self.graph.channel);
                case 'update'
                    self.markingCallback;
                    self.graph.updateMarkers(self.mark);
                case 'channel'
                    self.graph.channel = self.panel.channel;
                    self.graph.updateChannel;
                    self.graph.updateMarkers(self.mark);
            end
        end
        
        function markingCallback(self)
            self.mark = struct;
            self.mark.amp = self.panel.val_amp;
            self.mark.slope = self.panel.val_slope;
            self.mark.dur = self.panel.val_dur;
            self.mark.defl = self.panel.val_defl;
        end
    end
end