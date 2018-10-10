function [BiVstruct] = dataD912()

%% General
BiVstruct.tCycle     = 0.6;
BiVstruct.tCycleRest = 0.6;

% Blood flow
EDV = 30.32; % mL
ESV = 14.25; % mL

BiVstruct.q0    = (EDV-ESV)/BiVstruct.tCycle * 1e-6; % m^3
BiVstruct.qRest = (EDV-ESV)/BiVstruct.tCycle * 1e-6; % m^3
%BiVstruct.q0         = 28e-6;
%BiVstruct.qRest      = 28e-6;

% Blood pressure
mmHg2kPa = 0.13332239;
pSys = 13.64; % kPa
pDia = 0; % kPa
pMean = 0.72*pSys * 1e3;% (pDia + (pSys - pDia)/3) * 1e3;

BiVstruct.p0    = pMean;
BiVstruct.pRest = pMean;
%BiVstruct.p0         = 11.8e3;
%BiVstruct.pRest      = 11.8e3;

BiVstruct.QRS        = 0.15 *0.3; % (s) Totally random guess

BiVstruct.SfPas = 2.8765 * 1e4;

%% Geometry
% Aorta Data - TubeLArt
BiVstruct.diamTubeLArt = []; %mat

% Pulmonary Artery Data - TubeRArt
BiVstruct.diamTubeRArt = [];

% Aortic Valve Data - ValveLArt
BiVstruct.diamValveLArt = []; %mat
BiVstruct.LArtLeak = [];

% Pulmonary Valve Data - ValveRArt
BiVstruct.diamValveRArt = [];
BiVstruct.RArtLeak = [];

% Mitral Valve Data - ValveLAv
BiVstruct.diamValveLAv = []; %mat
BiVstruct.Mregurge = [];

% Tricuspid Valve Data - ValveRAv
BiVstruct.diamValveRAv = [];
BiVstruct.RAvLeak = [];

BiVstruct.VWall = []; %comV24+	% Total Wall Volume from Model

%% Objectives
%mmHg2kPa = 0.13332239;
%BiVstruct.refP = 13.64 *1000;% *mmHg2kPa; %comV24+ %LV Peak P
BiVstruct.refP = pSys *1e3; %comV24+ %LV Peak P
BiVstruct.EDV = 30.32; %270; %comV24+ %Model ED or Echo ED (E)