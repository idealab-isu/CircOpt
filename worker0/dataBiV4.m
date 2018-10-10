function [BiVstruct] = dataBiV4()
% dataBiV#   Outputs the data structure for patient "#"
%

%% General
BiVstruct.tCycle     = 0.86; %mat+
BiVstruct.tCycleRest = 0.86; %mat+

% Blood flow
EDV = 289; % mL
ESV = 187; % mL
BiVstruct.Mregurge = 30; % mL

BiVstruct.q0    = (EDV-ESV-BiVstruct.Mregurge)/BiVstruct.tCycle * 1e-6; % m^3
BiVstruct.qRest = (EDV-ESV-BiVstruct.Mregurge)/BiVstruct.tCycle * 1e-6; % m^3
%BiVstruct.q0         = 84e-6; %mat+
%BiVstruct.qRest      = 84e-6; %mat+

% Blood pressure
mmHg2kPa = 0.13332239;
pSys = 118; % mmHg
pDia =  53; % mmHg
pMean = (pDia + (pSys - pDia)/3) * mmHg2kPa * 1e3;

BiVstruct.p0    = pMean;
BiVstruct.pRest = pMean;
%BiVstruct.p0         = 17e3; %mat+
%BiVstruct.pRest      = 17e3; %mat+

BiVstruct.QRS        = 0.130 *0.3; %comV24, affects timing.m %0.156s is the time from the start of the pulse to full decay

%% Geometry
% Aorta Data - TubeLArt
BiVstruct.diamTubeLArt = []; %mat

% Pulmonary Artery Data - TubeRArt
BiVstruct.diamTubeRArt = 15.4e-3;

% Aortic Valve Data - ValveLArt
BiVstruct.diamValveLArt = 23.8e-3; %mat
BiVstruct.LArtLeak = [];

% Pulmonary Valve Data - ValveRArt
BiVstruct.diamValveRArt = [];
BiVstruct.RArtLeak = [];

% Mitral Valve Data - ValveLAv
BiVstruct.diamValveLAv = 23.0e-3; %mat

% Tricuspid Valve Data - ValveRAv
BiVstruct.diamValveRAv = [];
BiVstruct.RAvLeak = [];

BiVstruct.VWall = 213e-6; %comV24+	% Total Wall Volume from Model

%% Objectives
%mmHg2kPa = 0.13332239;
%BiVstruct.refP = 151 *mmHg2kPa*1e3; %comV24+ %LV Peak P
BiVstruct.refP = pSys *mmHg2kPa*1e3; %comV24+ %LV Peak P
BiVstruct.refPd = pDia *mmHg2kPa*1e3; %comV24+ %LV Peak P
BiVstruct.EDV = 289; %307; %comV24+ %Model ED or Echo ED (E)