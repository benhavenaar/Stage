classdef Plot < handle
    properties;
        view;
        scroll;
        zoom;
        timeline;
        points;
        callback;
        
        data;
        channel = 1;
        firstChannel;
        qrsX = 1:9999;
        qrsXLocations;
        qrsXLocationsMin;
        qrsXLocationsPlus;
        qrsXLocationsArray;
        y;
        derY;
        invY;
        invDerY;
        peak;
        valley;
        plotECG;
        plotDerivative;
        plotQRS;
        plotPeaks;
        plotValleys;
        plotSlope;
        marks;
        slope;
        lat;
        panelData;
    end
    
    methods
        function self = Plot(view)
            self.view = view;
            self.scroll = 0;
            self.zoom = [-5 5];
            self.timeline = [0 1000];
        end
        
        function plot(self, data)
            self.data = data;
            % Automatic QRS Marker
            self.firstChannel = sgolayfilt(self.data(:,1), 7, 23);
            [~, self.qrsXLocations] = findpeaks(self.firstChannel, 'MinPeakProminence', 0.2, 'MinPeakDistance', 300);
            for a = 1:length(self.qrsXLocations)
                self.qrsXLocationsMin(a) = self.qrsXLocations(a) - 40;
                self.qrsXLocationsPlus(a) = self.qrsXLocations(a) + 40;
                self.qrsXLocationsArray(a,:) = self.qrsXLocationsMin(a):self.qrsXLocationsPlus(a);
            end
            for a = 1:length(self.qrsX)
                if self.qrsX(a) ~= self.qrsXLocationsArray(:);
                    self.qrsX(a) = NaN;
                end
            end
            %Channel plotting
            self.y = self.data(:,self.channel);
            self.invY = -self.data(:,self.channel);
            self.derY = diff(self.y);
            self.invDerY = -diff(self.y);
            self.plotECG = plot(self.view,self.y, 'k');hold on;
            self.plotDerivative = plot(self.view, self.derY, 'r--');hold on;
            self.plotQRS = plot(self.qrsX, self.y, 'g');hold on;
            [~, locs] = findpeaks(self.y); %standard peak finding
            [~,idx] = findpeaks(self.invY); %initial valley setting
            [~,self.slope] = findpeaks(self.invDerY); %negative slope finding
            self.peak = max(self.y);
            self.valley = max(self.invY);
            self.plotPeaks = plot(self.view, locs, self.y(locs), 'rs');hold on; %peaks
            self.plotValleys = plot(self.view, idx, self.y(idx), 'gs');hold on; %valleys
            self.plotSlope = plot(self.view, self.slope, self.y(self.slope), 'cd');hold on; %neg slopes
            self.plotPeaks.Visible = 'off';
            self.plotValleys.Visible = 'off';
            self.plotSlope.Visible = 'off';
%             plot(self.view,idx2, self.y(idx2), 'cd');hold on; 
            legend('ECG', 'Derivative', 'QRS','ECG Peaks', 'ECG Valleys',...
                'Slopes');
            legend('boxoff');
            
            ylim(self.view, [-self.valley-.5 self.peak+.5]);
            xlim(self.view, self.timeline);
            
            set(self.view, 'box', 'off',...
                'XAxisLocation', 'top');
        end
        
        function show(self)
            ylim(self.view, self.zoom);
            xlim(self.view, [0 1000]);

            set(self.view, 'box', 'off',...
                'XAxisLocation', 'top');
        end
        
        function nextChannel(self)
            self.channel = self.channel + 1;
            if self.channel > 192;
                self.channel = 1;
            end
            self.plotECG.YData = self.data(:,self.channel);
            self.plotDerivative.YData = diff(self.data(:,self.channel));
            self.plotQRS.YData = self.plotECG.YData;
        end
        
        function previousChannel(self)
            self.channel = self.channel - 1;
            if self.channel < 1;
                self.channel = 192;
            end
            self.plotECG.YData = self.data(:,self.channel);
            self.plotDerivative.YData = diff(self.data(:,self.channel));
            self.plotQRS.YData = self.plotECG.YData;
        end
        
        function updateChannel(self)
            self.plotECG.YData = self.data(:,self.channel);
            self.plotDerivative.YData = diff(self.data(:,self.channel));
            self.plotQRS.YData = self.plotECG.YData;
        end
        
        function scrollLeftCallback(self, ~, ~)
            tmp = self.scroll + diff(self.timeline)/2;
            
            if tmp + 1500 <= 11000
                self.scroll = tmp;
                self.timeline = self.timeline + diff(self.timeline)/2;
            end
            
            xlim(self.view, self.timeline);
        end
        
        function scrollRightCallback(self, ~, ~)
            tmp = self.scroll - diff(self.timeline)/2;
            
            if tmp >= -diff(self.timeline)/2;
                self.scroll = tmp;
                self.timeline = self.timeline - diff(self.timeline)/2;
            end
            
            xlim(self.view, self.timeline);
        end
        function updateMarkers(self, t)
            self.panelData = t;
            self.y = self.data(:,self.channel);
            self.invY = -self.y;
            self.derY = diff(self.y);
            self.invDerY = -diff(self.y);
            self.peak = max(self.y);
            self.valley = max(self.invY);
            [pks, locs] = findpeaks(self.y,'MinPeakProminence', t.peakProminence, 'MinPeakDistance', t.peakDuration);
            [invPks, invLocs] = findpeaks(self.invY,'MinPeakProminence', t.valleyProminence, 'MinPeakDistance', t.valleyDuration);
            [self.slope,self.lat] = findpeaks(self.invDerY, 'MinPeakHeight', t.slopeHeight, 'MinPeakDistance', t.slopeDuration);
            self.plotPeaks.YData = pks;
            self.plotPeaks.XData = locs;
            self.plotPeaks.Visible = 'on';
            
            self.plotValleys.YData = -invPks;
            self.plotValleys.XData = invLocs;
            self.plotValleys.Visible = 'on';
            
            self.plotSlope.YData = self.y(self.lat);
            self.plotSlope.XData = self.lat;
            self.plotSlope.Visible = 'on';
            
            ylim(self.view, [-self.valley-.5 self.peak+.5]);
            
            self.updatePanel;
        end
        
        function clearMarkers(self)
            self.plotPeaks.Visible = 'off';
            self.plotSlope.Visible = 'off';
            self.plotValleys.Visible = 'off';
        end
        
        function setCallback(self, x)
            self.callback = x;
        end
%         function testCurrentPoint(self)
%             xtest = get(self.view, 'CurrentPoint');
%             ytest = get(self.view, 'Ylim');
%             disp(xtest);
%             
%             seeker = patch(self.view, [xtest(1)-45 xtest(1)+45 xtest(1)+45 xtest(1)-45],...
%                 [ytest(1) ytest(1) ytest(2) ytest(2)], [1 .6 1], 'EdgeColor', 'None');
%             uistack(seeker, 'bottom');
%         end
    end
    
    methods (Access = private)
        
        function updatePanel(self)
            %hier amplitude informatie e.d.
            try
                self.callback('update', self.lat, self.slope);
            catch
                errordlg('No slope found.');
            end
        end
    end
end