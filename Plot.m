classdef Plot < handle
    properties;
        filename = 'C:\Users\502896\Desktop\Documentatie Stagiaires\Ben Havenaar\src\test.xlsx';
        view;
        scroll;
        zoom;
        timeline;
        
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
        plotNegSlope;
        plotPosSlope;
        marks;
    end
    
    methods
        function self = Plot(view)
            self.view = view;
            self.scroll = 0;
            self.zoom = [-5 5];
            self.timeline = [0 1000];
        end
        
        function plot(self)
            [self.data,~,~] = xlsread(self.filename);
            % Automatic QRS Marker
            self.firstChannel = self.data(:,1);
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
            [~,locs2] = findpeaks(self.derY); %positive slope finding
            [~,idx2] = findpeaks(self.invDerY); %negative slope finding
            self.peak = max(self.y);
            self.valley = max(self.invY);
            self.plotPeaks = plot(self.view, locs, self.y(locs), 'rs');hold on; %peaks
            self.plotValleys = plot(self.view,idx, self.y(idx), 'gs');hold on; %valleys
            self.plotNegSlope = plot(self.view, idx2, self.y(idx2), 'cd');hold on; %neg slopes
            self.plotPosSlope = plot(self.view,locs2,self.y(locs2), 'md');hold on; %pos slopes
            self.plotPeaks.Visible = 'off';
            self.plotValleys.Visible = 'off';
            self.plotNegSlope.Visible = 'off';
            self.plotPosSlope.Visible = 'off';
%             plot(self.view,idx2, self.y(idx2), 'cd');hold on; 
            legend('ECG', 'Derivative', 'QRS','ECG Peaks', 'ECG Valleys',...
                'Neg Slopes', 'Pos Slopes');
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
            self.y = self.data(:,self.channel);
            self.invY = -self.y;
            self.derY = diff(self.y);
            self.invDerY = -diff(self.y);
            self.peak = max(self.y);
            self.valley = max(self.invY);
            [pks, locs] = findpeaks(self.y,'MinPeakProminence', t.amp, 'MinPeakDistance', t.dur);
            [invPks, invLocs] = findpeaks(self.invY,'MinPeakProminence', t.amp, 'MinPeakDistance', t.dur);
            [~,derLocs] = findpeaks(self.derY, 'MinPeakHeight', t.slope, 'MinPeakDistance', t.dur);
            [~,invDerLocs] = findpeaks(self.invDerY, 'MinPeakHeight', t.slope, 'MinPeakDistance', t.dur);
            self.plotPeaks.YData = pks;
            self.plotPeaks.XData = locs;
            self.plotPeaks.Visible = 'on';
            
            self.plotValleys.YData = -invPks;
            self.plotValleys.XData = invLocs;
            self.plotValleys.Visible = 'on';
            
            self.plotPosSlope.YData = self.y(derLocs);
            self.plotPosSlope.XData = derLocs;
            self.plotPosSlope.Visible = 'on';
            
            self.plotNegSlope.YData = self.y(invDerLocs);
            self.plotNegSlope.XData = invDerLocs;
            self.plotNegSlope.Visible = 'on';
            
            ylim(self.view, [-self.valley-.5 self.peak+.5]);
        end
        function clearMarkers(self)
            self.plotPeaks.Visible = 'off';
            self.plotNegSlope.Visible = 'off';
            self.plotValleys.Visible = 'off';
            self.plotPosSlope.Visible = 'off';
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
    end
end