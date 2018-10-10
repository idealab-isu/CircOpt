function stepDog(BiV,params,x,scaling,step,options)
% stepBiV updates Par for the current step
%   stepBiV(BiV,params,x,scaling,step,options)

% Disabled LAv.ALeak

global Par

%% Parse input

if nargin < 5
    error('Not enough inputs')
end

%% Get data

BiVstruct = eval(['dataD',num2str(BiV),'()']); % Get data for patient

ParRef = load('ParDog.mat');
ParRef = ParRef.Par;

%% General
Par.General.tCycleRest = xStepCalc(BiVstruct.tCycleRest, ParRef.General.tCycleRest, step,options.NumSteps);
Par.General.tCycle     = xStepCalc(BiVstruct.tCycle,     ParRef.General.tCycle,     step,options.NumSteps);
Par.General.q0         = xStepCalc(BiVstruct.q0,         ParRef.General.q0,         step,options.NumSteps);
Par.General.qRest      = xStepCalc(BiVstruct.qRest,      ParRef.General.qRest,      step,options.NumSteps);

if isempty(paramI(params,'scalep0'))
    Par.General.p0    = xStepCalc(BiVstruct.p0,    ParRef.General.p0,    step, options.NumSteps);
    Par.General.pRest = xStepCalc(BiVstruct.pRest, ParRef.General.pRest, step, options.NumSteps);
else
    Scale.p0 = xStepCalc(x,1,options.NumSteps,options.NumSteps,scaling,params,'scalep0');
    Par.General.p0    = xStepCalc(BiVstruct.p0*Scale.p0,    ParRef.General.p0,    step, options.NumSteps);
    Par.General.pRest = xStepCalc(BiVstruct.pRest*Scale.p0, ParRef.General.pRest, step, options.NumSteps);
end

%Par.General.p0         = xStepCalc(BiVstruct.p0,         ParRef.General.p0,         step,options.NumSteps);
%Par.General.pRest      = xStepCalc(BiVstruct.pRest,      ParRef.General.pRest,      step,options.NumSteps);

%ParRef.General.QRS = 0;
%Par.General.QRS        = xStepCalc(BiVstruct.QRS,        ParRef.General.QRS,        step,options.NumSteps);

Par.General.pDropPulm  = xStepCalc(x,ParRef.General.pDropPulm,step,options.NumSteps,scaling,params,'pDropPulm');

%% Sarcomere
SfAct  = xStepCalc(x, mean([ParRef.Lv.Sarc.SfAct,ParRef.Rv.Sarc.SfAct,ParRef.Sv.Sarc.SfAct]),  step,options.NumSteps,scaling,params,'SfAct');
SfPas  = xStepCalc(x, mean([ParRef.Lv.Sarc.SfPas,ParRef.Rv.Sarc.SfPas,ParRef.Sv.Sarc.SfPas]),  step,options.NumSteps,scaling,params,'SfPas');
dLsPas = xStepCalc(x, mean([ParRef.Lv.Sarc.dLsPas,ParRef.Rv.Sarc.dLsPas,ParRef.Sv.Sarc.dLsPas]), step,options.NumSteps,scaling,params,'dLsPas');

if isempty(paramI(params,'SfPas')) && isfield(BiVstruct,'SfPas') && ~isempty(BiVstruct.SfPas)
    SfPas  = xStepCalc(BiVstruct.SfPas, mean([ParRef.Lv.Sarc.SfPas,ParRef.Rv.Sarc.SfPas,ParRef.Sv.Sarc.SfPas]),  step,options.NumSteps);
end

Par.Lv.Sarc.SfAct = SfAct;
Par.Lv.Sarc.SfPas = SfPas;
Par.Lv.Sarc.dLsPas = dLsPas;

Par.Rv.Sarc.SfAct = SfAct;
Par.Rv.Sarc.SfPas = SfPas;
Par.Rv.Sarc.dLsPas = dLsPas;

Par.Sv.Sarc.SfAct = SfAct;
Par.Sv.Sarc.SfPas = SfPas;
Par.Sv.Sarc.dLsPas = dLsPas;

%% Scaling

% Tubes
Scale.f.TubeLArt = []; % Aorta
if ~isempty(BiVstruct.diamTubeLArt)
    Scale.f.TubeLArt = BiVstruct.diamTubeLArt/(sqrt(ParRef.TubeLArt.A0*4.0/pi())*1.0023);
end
Scale.TubeLArtLen = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleTubeLArtLen');

Scale.f.TubeRArt = []; % Pulmonary Artery
if ~isempty(BiVstruct.diamTubeRArt)
    Scale.f.TubeLArt = BiVstruct.diamTubeRArt/(sqrt(ParRef.TubeRArt.A0*4.0/pi())*1.1079);
end
Scale.TubeRArtLen = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleTubeRArtLen');

% Valves
Scale.f.ValveLArt = []; % Aortic Valve
if ~isempty(BiVstruct.diamValveLArt)
    Scale.f.ValveLArt = BiVstruct.diamValveLArt/(sqrt(ParRef.ValveLArt.AOpen*4.0/pi()));
end

Scale.f.ValveRArt = []; % Pulmonary Valve
if ~isempty(BiVstruct.diamValveRArt)
    Scale.f.ValveRArt = BiVstruct.diamValveRArt/(sqrt(ParRef.ValveRArt.AOpen*4.0/pi()));
end

Scale.f.ValveLAv = []; % Mitral Valve
if ~isempty(BiVstruct.diamValveLAv)
    Scale.f.ValveLAv = BiVstruct.diamValveLAv/(sqrt(ParRef.ValveLAv.AOpen*4.0/pi()));
end

Scale.f.ValveRAv = []; % Tricuspid Valve
if ~isempty(BiVstruct.diamValveRAv)
    Scale.f.ValveRAv = BiVstruct.diamValveRAv/(sqrt(ParRef.ValveRAv.AOpen*4.0/pi()));
end

Scale.Mean = mean([Scale.f.TubeLArt,Scale.f.TubeRArt,Scale.f.ValveLArt,Scale.f.ValveRArt,Scale.f.ValveLAv,Scale.f.ValveRAv]);
if isnan(Scale.Mean)
    Scale.Mean = 1;
end

% Chambers
Scale.Lv = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleLv');

if isempty(paramI(params,'scaleRv'))
    Scale.Rv = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleRvRel')*Scale.Lv;
else
    Scale.Rv = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleRv');
end

if isempty(paramI(params,'scaleSv'))
    Scale.Sv = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleSvRel')*Scale.Lv;
else
    Scale.Sv = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleSv');
end

if isempty(paramI(params,'scaleLa'))
    if isempty(paramI(params,'scaleLaRel'))
        Scale.La = (Scale.Lv+1)/2;
    else
        Scale.La = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleLaRel')*Scale.Lv;
    end
else
    Scale.La = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleLa');
end

if isempty(paramI(params,'scaleRa'))
    if isempty(paramI(params,'scaleLaRel'))
        Scale.Ra = (Scale.Rv+1)/2;
    else
        Scale.Ra = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleRaRel')*Scale.Rv;
    end
else
    Scale.Ra = xStepCalc(x,1,step,options.NumSteps,scaling,params,'scaleRa');
end

% Auto scaling
switch options.AutoScale
    case 'false'
        Scale.TubeLArt = [Scale.f.TubeLArt,1];
        Scale.TubeLArt = xStepCalc(Scale.TubeLArt(1),1,step,options.NumSteps);
        
        Scale.TubeRArt = [Scale.f.TubeRArt,1];
        Scale.TubeRArt = xStepCalc(Scale.TubeRArt(1),1,step,options.NumSteps);
        
        Scale.ValveLArt = [Scale.f.ValveLArt,1];
        Scale.ValveLArt = xStepCalc(Scale.ValveLArt(1),1,step,options.NumSteps);
        
        Scale.ValveRArt = [Scale.f.ValveRArt,1];
        Scale.ValveRArt = xStepCalc(Scale.ValveRArt(1),1,step,options.NumSteps);
        
        Scale.ValveLAv = [Scale.f.ValveLAv,1];
        Scale.ValveLAv = xStepCalc(Scale.ValveLAv(1),1,step,options.NumSteps);
        
        Scale.ValveRAv = [Scale.f.ValveRAv,1];
        Scale.ValveRAv = xStepCalc(Scale.ValveRAv(1),1,step,options.NumSteps);
        
    otherwise
        Scale.TubeLArt = [Scale.f.TubeLArt,Scale.f.ValveLArt,Scale.f.TubeRArt,Scale.f.ValveRArt,Scale.Lv,Scale.Mean];
        Scale.TubeLArt = xStepCalc(Scale.TubeLArt(1),1,step,options.NumSteps);
        
        Scale.TubeRArt = [Scale.f.TubeRArt,Scale.f.ValveRArt,Scale.f.TubeLArt,Scale.f.ValveLArt,Scale.Rv,Scale.Mean];
        Scale.TubeRArt = xStepCalc(Scale.TubeRArt(1),1,step,options.NumSteps);
        
        Scale.ValveLArt = [Scale.f.ValveLArt,Scale.f.TubeLArt,Scale.f.ValveRArt,Scale.f.TubeRArt,Scale.La,Scale.Mean];
        Scale.ValveLArt = xStepCalc(Scale.ValveLArt(1),1,step,options.NumSteps);
        
        Scale.ValveRArt = [Scale.f.ValveRArt,Scale.f.TubeRArt,Scale.f.ValveLArt,Scale.f.TubeLArt,Scale.Ra,Scale.Mean];
        Scale.ValveRArt = xStepCalc(Scale.ValveRArt(1),1,step,options.NumSteps);
        
        Scale.ValveLAv = [Scale.f.ValveLAv,Scale.f.TubeRArt,Scale.Lv,Scale.Mean];
        Scale.ValveLAv = xStepCalc(Scale.ValveLAv(1),1,step,options.NumSteps);
        
        Scale.ValveRAv = [Scale.f.ValveRAv,Scale.f.TubeLArt,Scale.Rv,Scale.Mean];
        Scale.ValveRAv = xStepCalc(Scale.ValveRAv(1),1,step,options.NumSteps);
end

%% Tubes

% Aorta
Par.TubeLArt.A0    = Scale.TubeLArt^2 *ParRef.TubeLArt.A0;
Par.TubeLArt.A     = Scale.TubeLArt^2 *ParRef.TubeLArt.A;
Par.TubeLArt.AWall = Scale.TubeLArt   *ParRef.TubeLArt.AWall;
Par.TubeLArt.Len   = Scale.TubeLArtLen*ParRef.TubeLArt.Len;

% Pulmonary Artery
Par.TubeRArt.A0    = Scale.TubeRArt^2 *ParRef.TubeRArt.A0;
Par.TubeRArt.A     = Scale.TubeRArt^2 *ParRef.TubeRArt.A;
Par.TubeRArt.AWall = Scale.TubeRArt   *ParRef.TubeRArt.AWall;
Par.TubeRArt.Len   = Scale.TubeRArtLen*ParRef.TubeRArt.Len;

%% Valves

% Aortic Valve
Par.ValveLArt.AOpen = Scale.ValveLArt^2*ParRef.ValveLArt.AOpen;
Par.ValveLArt.Len   = Scale.ValveLArt  *ParRef.ValveLArt.Len;

if isempty(BiVstruct.LArtLeak)
    Par.ValveLArt.ALeak = ParRef.ValveLArt.ALeak/ParRef.ValveLArt.AOpen*Par.ValveLArt.AOpen;
else
    Par.ValveLArt.ALeak = BiVstruct.LArtLeak*Par.ValveLArt.AOpen;
end

% Pulmonary Valve
Par.ValveRArt.AOpen = Scale.ValveRArt^2*ParRef.ValveRArt.AOpen;
Par.ValveRArt.Len   = Scale.ValveRArt  *ParRef.ValveRArt.Len;

if isempty(BiVstruct.RArtLeak)
    Par.ValveRArt.ALeak = ParRef.ValveRArt.ALeak/ParRef.ValveRArt.AOpen*Par.ValveRArt.AOpen;
else
    Par.ValveRArt.ALeak = BiVstruct.RArtLeak*Par.ValveRArt.AOpen;
end

% Mitral Valve
Par.ValveLAv.AOpen = Scale.ValveLAv^2*ParRef.ValveLAv.AOpen;
Par.ValveLAv.Len   = Scale.ValveLAv  *ParRef.ValveLAv.Len;

%LAvLeak = xStepCalc(x,ParRef.ValveLAv.ALeak/ParRef.ValveLAv.AOpen,step,options.NumSteps,scaling,params,'LAvLeak');
LAvLeak = xStepCalc(x,1e-6,step,options.NumSteps,scaling,params,'LAvLeak');

%Par.ValveLAv.ALeak = LAvLeak*Par.ValveLAv.AOpen;
Par.ValveLAv.LeakRatio = LAvLeak;

% Tricuspid Valve
Par.ValveRAv.AOpen = Scale.ValveRAv^2*ParRef.ValveRAv.AOpen;
Par.ValveRAv.Len   = Scale.ValveRAv  *ParRef.ValveRAv.Len;

if isempty(BiVstruct.RAvLeak)
    Par.ValveRAv.ALeak = ParRef.ValveRAv.ALeak/ParRef.ValveRAv.AOpen*Par.ValveRAv.AOpen;
else
    Par.ValveRAv.ALeak = BiVstruct.RAvLeak*Par.ValveRAv.AOpen;
end

Par.Lv.AmDead = Par.ValveLAv.AOpen + Par.ValveLArt.AOpen;
Par.Rv.AmDead = Par.ValveRAv.AOpen + Par.ValveRArt.AOpen;

%% Chambers

Par.Lv.AmRef = ParRef.Lv.AmRef * Scale.Lv;
Par.Rv.AmRef = ParRef.Rv.AmRef * Scale.Rv;
Par.Sv.AmRef = ParRef.Sv.AmRef * Scale.Sv;
Par.La.AmRef = ParRef.La.AmRef * Scale.La;
Par.Ra.AmRef = ParRef.Ra.AmRef * Scale.Ra;

WallRatios = [ParRef.Lv.VWall,ParRef.Rv.VWall,ParRef.Sv.VWall] /(ParRef.Lv.VWall+ParRef.Rv.VWall+ParRef.Sv.VWall);

if ~isempty(BiVstruct.VWall)
    VWall = xStepCalc(BiVstruct.VWall,ParRef.Lv.VWall+ParRef.Rv.VWall+ParRef.Sv.VWall,step,options.NumSteps);
else
    VWall = ParRef.Lv.VWall+ParRef.Rv.VWall+ParRef.Sv.VWall;
end

switch options.NormalizeVWallScaling
    case 'false'
        Par.Lv.VWall = VWall*WallRatios(1);
        Par.Rv.VWall = VWall*WallRatios(2);
        Par.Sv.VWall = VWall*WallRatios(3);
    otherwise
        Par.Lv.VWall = VWall*WallRatios(1) * Scale.Lv /sum([Scale.Lv,Scale.Rv,Scale.Sv].*WallRatios);
        Par.Rv.VWall = VWall*WallRatios(2) * Scale.Rv /sum([Scale.Lv,Scale.Rv,Scale.Sv].*WallRatios);
        Par.Sv.VWall = VWall*WallRatios(3) * Scale.Sv /sum([Scale.Lv,Scale.Rv,Scale.Sv].*WallRatios);      
end


function xi = xStepCalc(x,x0,step,N,scaling,params,str)
% xStepCalc   Gives the appropriate parameter of a parameter for a given step
%   xStepCalc(params,str,x,x0,step,N)

if nargin == 7
    I = paramI(params,str);
    
    if isempty(I)
        xi = x0;
        return
    end
    
    xi = (step/N)*x(I)*scaling(I) + (1-step/N)*x0;
else
    xi = (step/N)*x + (1-step/N)*x0;
end


function Ind = paramI(params,str)
% paramI   Gives the index of 'param'
%   paramI(params,str) ouputs the location of string 'str' in cell array 'params'

Ind = [];

if any(strcmp(params,str))
    Ind = find(cellfun(@length,regexp(params,str)) == 1);
end