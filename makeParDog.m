%function y = makeParDog(x)

load ParRef.mat
%load ParDog.mat

ScaleAtria = 0.6;  % Atria
ScaleTimeAct = 1.75; % TimeAct

%% From dogRef.cont6 (In Cont: biomech>edit>circ) via DisplayLastBeat.m

Par.General.TimeFac = 1.33;

Par.General.tCycle = 0.6;
Par.General.tCycleRest = 0.6;
Par.General.rhob = 1050;
Par.General.p0 = 11.8e3;
Par.General.pRest = 11.8e3;
Par.General.q0 = 28e-6;
Par.General.qRest = 28e-6;
%(Par.La.Sarc.ActivationDelay(end)-Par.Rv.Sarc.ActivationDelay(end)) = -0.12;
Par.Rv.Sarc.ActivationDelay = Par.Rv.Sarc.ActivationDelay *0.6/0.85;
Par.La.Sarc.ActivationDelay = Par.La.Sarc.ActivationDelay - (Par.La.Sarc.ActivationDelay(end) - (Par.Rv.Sarc.ActivationDelay(end) - 0.12));
%mean(Par.ValveLVen.AOpen) = 3.6e-4;
Par.ValveLVen.AOpen = 3.6e-4;
Par.ValveLVen.Len = 1.26e-2;
Par.La.AmRef = 46.5e-4 *ScaleAtria;
Par.La.AmDead = 8e-4;
Par.La.VWall = 7.4493e-6 *ScaleAtria;
Par.La.Sarc.LenSeriesElement = 0.04;
Par.La.Sarc.TR = 0.5;
Par.La.Sarc.TD = 0.5;
Par.La.Sarc.TimeAct = 0.2*ScaleTimeAct;
Par.La.Sarc.Lsi0Act = 1.51;
Par.La.Sarc.Ls0Pas = 1.8;
Par.La.Sarc.dLsPas = 0.8;
Par.La.Sarc.SfPas = 23.743e3;
Par.La.Sarc.CRest = 0.02;
Par.La.Sarc.LsRef = 2;
Par.La.Sarc.SfAct = 84e3;
Par.La.Sarc.vMax = 10;

Par.Lv.A = Par.Lv.A * 6.5e-4/mean(Par.Lv.A);
Par.ValveLAv.AOpen = 4.7622e-4;
Par.ValveLAv.ALeak = Par.ValveLAv.ALeak * 5e-2/mean(Par.ValveLAv.ALeak);
Par.ValveLAv.Len = 0.7937e-2;
Par.ValveLArt.AOpen = 2.5e-4;
Par.ValveLArt.ALeak = 2e-10;
Par.ValveLArt.Len = 0.7182e-2;
Par.TubeLArt.AWall = 0.99e-4;
Par.TubeLArt.A0 = 2.5e-4;
Par.TubeLArt.Len = 25.2e-2;
Par.TubeLArt.p0 = 12.287e3;
Par.TubeLArt.k = 8;
Par.LRp.R = Par.LRp.R * 350e6/mean(Par.LRp.R);
Par.TubeRVen.AWall = 0.1274e-4;
Par.TubeRVen.A0 = 2.5e-4;
Par.TubeRVen.Len = 25.1984e-2;
Par.TubeRVen.p0 = 0.341e3;
Par.TubeRVen.k = 10;

%(Par.Ra.Sarc.ActivationDelay(end-1)-Par.Rv.Sarc.ActivationDelay(end)) = -0.12;
Par.Ra.Sarc.ActivationDelay = Par.Ra.Sarc.ActivationDelay - (Par.Ra.Sarc.ActivationDelay(end-1) - (Par.Rv.Sarc.ActivationDelay(end) - 0.12));
Par.ValveRVen.AOpen = Par.ValveRVen.AOpen * 3.6e-4/mean(Par.ValveRVen.AOpen);
Par.ValveRVen.Len = 1.26e-2;
Par.Ra.AmRef = 46.5e-4 *ScaleAtria;
Par.Ra.AmDead = 8e-4;
Par.Ra.VWall = 1.8712e-6 *ScaleAtria;
Par.Ra.Sarc.LenSeriesElement = 0.04;
Par.Ra.Sarc.TR = 0.5;
Par.Ra.Sarc.TD = 0.5;
Par.Ra.Sarc.TimeAct = 0.2*ScaleTimeAct;
Par.Ra.Sarc.Lsi0Act = 1.51;
Par.Ra.Sarc.Ls0Pas = 1.8;
Par.Ra.Sarc.dLsPas = 0.8;
Par.Ra.Sarc.SfPas = 23.743e3;
Par.Ra.Sarc.CRest = 0.02;
Par.Ra.Sarc.LsRef = 2;
Par.Ra.Sarc.SfAct = 84e3;
Par.Ra.Sarc.vMax = 10;

Par.Rv.A = Par.Rv.A * 6.5e-4/mean(Par.Rv.A);
Par.ValveRAv.AOpen = 4.7622e-4;
%Par.ValveRAv.ALeak(end-edLoc) = 5e-10;
Par.ValveRAv.ALeak = 5e-10;
Par.ValveRAv.Len = 0.7937e-2;
Par.ValveRArt.AOpen = 2.0597e-4;
Par.ValveRArt.ALeak = 2e-10;
Par.ValveRArt.Len = 0.7182e-2;
Par.TubeRArt.AWall = 0.2254e-4;
Par.TubeRArt.A0 = 2.02e-4;
Par.TubeRArt.Len = 12.6e-2;
Par.TubeRArt.p0 = 2.388e3;
Par.TubeRArt.k = 8;
Par.General.pDropPulm = 1500;
Par.TubeLVen.AWall = 0.1978e-4;
Par.TubeLVen.A0 = 2.0023e-4;
Par.TubeLVen.Len = 12.6e-2;
Par.TubeLVen.p0 = 0.939e3;
Par.TubeLVen.k = 10;

% Continuity Parameters/Output
Scale = 1/3;
Par.Lv.AmRef = Par.Lv.AmRef * Scale;
Par.Lv.VWall = Par.Lv.VWall * Scale;
Par.Lv.Sarc.TD = 0.45;
Par.Lv.Sarc.TR = 0.25;
Par.Lv.Sarc.TimeAct = 0.2925*ScaleTimeAct;
Par.Lv.Sarc.SfAct = 58400;
%Par.Lv.Sarc.SfPas = ;

Par.Rv.AmRef = Par.Rv.AmRef * Scale;
Par.Rv.VWall = Par.Rv.VWall * Scale;
Par.Rv.Sarc.TD = 0.45;
Par.Rv.Sarc.TR = 0.25;
Par.Rv.Sarc.TimeAct = 0.2925*ScaleTimeAct;
Par.Rv.Sarc.SfAct = 58400;
%Par.Rv.Sarc.SfPas = ;

Par.Sv.AmRef = Par.Sv.AmRef * Scale;
Par.Sv.VWall = Par.Sv.VWall * Scale;
Par.Sv.Sarc.TD = 0.45;
Par.Sv.Sarc.TR = 0.25;
Par.Sv.Sarc.TimeAct = 0.2925*ScaleTimeAct;
Par.Sv.Sarc.SfAct = 58400;
%Par.Sv.Sarc.SfPas = ;

%% Converge

% Default initialization
G=Par.General;
G.DtSimulation=60*G.tCycle; % standard duration of simulation

Par.Adapt.FunctionName='Adapt0'; % No adaptation
Par.Adapt.In=[]; Par.Adapt.Out=[]; % storing input/output per beat
Par.Adapt.Fast= false; % regular beat to beat sequence

% Display Paramters
disp(['Pressure                  (kPa): ',num2str(G.p0/1e3)]);
disp(['Flow                     (ml/s): ',num2str(G.q0*1e6)]);
disp(['Time of beat               (ms): ',num2str(G.tCycle*1e3)]);
disp(['Duration simulation         (s): ',num2str(G.DtSimulation)]);
disp(['Adaptation                     : ',Par.Adapt.FunctionName]);
Par.General=G;

% === Solves SVar for problem defined in parameter structure 'Par'
CircAdapt; %generate solution

Par.Adapt.FunctionName='AdaptRest'; % Rest adaptation
Par.Adapt.In=[]; Par.Adapt.Out=[]; % storing input/output per beat

% === Solves SVar for problem defined in parameter structure 'Par'
CircAdapt; %generate solution

Par.Adapt.FunctionName='Adapt0'; % No adaptation
Par.Adapt.In=[]; Par.Adapt.Out=[]; % storing input/output per beat

% === Solves SVar for problem defined in parameter structure 'Par'
CircAdapt; %generate solution

SVar = Par.SVar;
numPoints = floor(Par.General.tCycle*1000);
Par.SVar = SVar(end-numPoints/2:end,:);

[SVarDot] = CircSVarDot(0,transpose(Par.SVar),[]);

CalP = 1;
CalV = 1e6;
Vmax = max(CalV*Par.Lv.V)

%% Save ParDog
save('worker0/ParDog.mat','Par');
