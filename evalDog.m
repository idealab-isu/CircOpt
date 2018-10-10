function [y] = evalDog(BiV,params,x,scaling,optIn)
% evalBiV   Evaluates CircAdapt for a given patient and set of parameters
%   EvalBiV(BiV,x) evaluates patient "BiV" with parameters "x"
%   EvalBiV(BiV,x,1) does not check for repeats. Use this to manually
%   test certain configuration
%   
%   Dependencies:
%     Need to put CircAdapt files in ../worker# folder for each thread
%     Need DataBiV#.m file for each patient

%% Parse input

if nargin < 3
    error('Not enough inputs')
elseif nargin > 5
    error('Too many inputs')
end

if nargin < 5, optIn = struct([]);
    if nargin < 4, scaling = ones(length(x));
    end
end

if ~iscolumn(x)
    x = x';
end

%% Prepare options

options = struct( ... % Defaults
    'CheckRepeat', 'true', ...
    'NumSteps', 3, ...
    'AutoScale', 'true', ...
    'NormalizeVWallScaling', 'false', ...
    'DtSimulation',30, ...
    'PVObjective', 'default', ...
    'MitralRegurgePenalty', 'default', ...
    'EDPPenalty', 'default', ...
    'MinPressurePenalty', 'default');

if isfield('avail',optIn) % Display list of available option names (optional)
    fieldnames(options)
    return
end

optInF = fieldnames(optIn); % Get list of option input fields
for i = 1:length(optInF)
    options.(optInF{i}) = optIn.(optInF{i});
end

%ObjWeights = [2, 2/3, 1/3, 0.01, 0.01, 0.015]; % PositiveErr multiplier, Perr, Verr, Pmin, EDP, Regurge
%ObjWeights = [2, 4/5, 1/5, 0.1, 0.1, 0.15];
ObjWeights = [2, 4/5, 1/5, 0.75, 0.75, 0.15];

%% Get worker info

t = getCurrentTask(); % Get info on current worker
if isempty(t) % Note: first evaluation is performed in serial, don't know why
    pID = 1;
else
    pID = t.ID; % Get pID
end

homeDir = cd; % Save original folder location
addpath(homeDir);

cd([homeDir,'/worker',num2str(pID)]);  % Change to new folder "/worker#"

%try % DEBUG check if the folder was accessed
%    csvwrite('accessCheck.dat',1);
%catch
%end

%% Other initializations

global Par;
load('ParDog.mat')

BiVstruct = eval(['dataD',num2str(BiV),'()']); % Get data for patient

%% Check for repeat

switch options.CheckRepeat
    case 'false'
        output = [];
    otherwise
        output = repeat(x);
end

%% Process case

tic

if isempty(output) % Unique parameters
    %% Evaluate

    disp(['worker',num2str(pID),' evaluating'])
    
    for step = 1:options.NumSteps % Parameter steps
        %% Update Par
        
        stepDog(BiV,params,x,scaling,step,options)
        
        %% Run simulation
        
        % Default initialization
        G=Par.General;
        G.DtSimulation=options.DtSimulation*G.tCycle; % standard duration of simulation
        
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
        
        Par.Failure = 0;
        
        % === Solves SVar for problem defined in parameter structure 'Par'
        CircAdapt; %generate solution
        
        if Par.Failure == 0
            Par.Adapt.FunctionName='AdaptRest'; % Rest adaptation
            Par.Adapt.In=[]; Par.Adapt.Out=[]; % storing input/output per beat
        else
            disp(['worker',num2str(pID),' failed, step=',num2str(step),'a'])
        end
        
        % === Solves SVar for problem defined in parameter structure 'Par'
        if Par.Failure == 0
            CircAdapt; %generate solution
            
            Par.Adapt.FunctionName='Adapt0'; % No adaptation
            Par.Adapt.In=[]; Par.Adapt.Out=[]; % storing input/output per beat
        else
            disp(['worker',num2str(pID),' failed, step=',num2str(step),'b'])
        end
        
        % === Solves SVar for problem defined in parameter structure 'Par'
        if Par.Failure == 0
            CircAdapt; %generate solution
        else
            disp(['worker',num2str(pID),' failed, step=',num2str(step),'c'])
        end
    end
    
    %% Save result
    
    if Par.Failure == 0
        save('Par.mat','Par'); %save Par in file 'Par'
        
        disp('Differential equation has been solved');
    end
    
    %% Organize data
    
    if Par.Failure == 0
        SVar = Par.SVar;
        numPoints = floor(Par.General.tCycle*1000);
        Par.SVar = SVar(end-numPoints/2:end,:);
        
        [SVarDot] = CircSVarDot(0,transpose(Par.SVar),[]);
        
        CalP = 1;
        CalV = 1e6;
        
        Pmax = max(CalP*Par.Lv.p); %pIn (Aortic entry vs LV)
        Pmin = min(CalP*Par.Lv.p); %pIn (Aortic entry vs LV)
        Vmax = max(CalV*Par.Lv.V); %prctile(CalV*Par.Lv.V,87.5);
        Vmin = min(CalV*Par.Lv.V);
        
        Vder = diff(Par.Lv.V);
        [~,Ied1] = max(Vder(1:floor(length(Vder)/2))); % Find peak in first half of cycle
        Ied2 = find(Vder(Ied1:end)<0,1); % Find first zero point after the peak
        Ied = Ied1+Ied2-2; % Last Increasing volume point (lower range estimate of EDP)
        %[~,Ied] = max(Par.Lv.V);
        EDP = Par.Lv.p(Ied);
        
        LAvRegurge = Vmax-Vmin-CalV*Par.General.q0*Par.General.tCycle;
        
    else
        Pmax = Inf;
        Pmin = -Inf;
        Vmax = Inf;
        Vmin = -Inf;
        EDP  = Inf;
        LAvRegurge = Inf;
    end
    
else % Repeat parameters
    disp(['worker',num2str(pID),' repeat'])

    Pmax = output(end-6);
    Pmin = output(end-5);
    Vmax = output(end-4);
    Vmin = output(end-3);
    EDP  = output(end-2);
    LAvRegurge = output(end-1);
end

%% Calculate output

% +Err multiplier, Perr, Verr, Pmin,  EDP, Regurge
ObjWeights = [  2,  4/5,  1/5, 0.75, 0.75, 0.15];

% Reference values
Pminref =  500; % Pa
EDPmin =  2150; % Pa
EDPmax =  2850; % Pa
HealthyRegurge = 3; % mL (max)

% Calculated values
Perr = (Pmax-BiVstruct.refP)/BiVstruct.refP;
Verr = (Vmax-BiVstruct.EDV)/BiVstruct.EDV;

% Objective
y = 0;
obj = zeros(1,5);

if Perr >= 0
    y = y + ObjWeights(2)*ObjWeights(1)*Perr^2;
else
    y = y + ObjWeights(2)*Perr^2;
end

obj(1) = y;

if Verr >= 0
    y = y + ObjWeights(3)*ObjWeights(1)*Verr^2;
else
    y = y + ObjWeights(3)*Verr^2;
end

obj(2) = y - obj(1);

% Penalties

if Pmin >= Pminref % Minimum pressure penalty
    y = y + ObjWeights(4)*((Pmin-Pminref)/(BiVstruct.refP-Pminref))^2;
end

obj(3) = y - sum(obj(1:2));

if EDP <= EDPmin % LV EDP penalty
    y = y + ObjWeights(5)*((EDP-EDPmin)/(BiVstruct.refP-Pminref))^2;
elseif EDP >= EDPmax % LV EDP penalty
    y = y + ObjWeights(5)*((EDP-EDPmax)/(BiVstruct.refP-Pminref))^2;

end

obj(4) = y - sum(obj(1:3));

if ~isempty(paramI(params,'LAvLeak')) && ~isempty(BiVstruct.Mregurge) % Regurge Penalty
    y = y + ObjWeights(6)*((LAvRegurge-BiVstruct.Mregurge)/BiVstruct.Mregurge)^2;
elseif ~isempty(paramI(params,'LAvLeak'))
    if LAvRegurge > HealthyRegurge
        y = y + ObjWeights(6)*((LAvRegurge-HealthyRegurge)/HealthyRegurge)^2;
    end
end

obj(5) = y - sum(obj(1:4));

%obj

%toc

%% Log

LogResult([x',toc,Pmax,Pmin,Vmax,Vmin,EDP,LAvRegurge,y])

%% Cleanup

cd(homeDir)

if pID == 1
    disp('Combining results files')
    combineResults()
end


function Ind = paramI(params,str)
% paramI   Gives the index of 'param'
%   paramI(params,str) ouputs the location of string 'str' in cell array 'params'

Ind = [];

if any(strcmp(params,str))
    Ind = find(cellfun(@length,regexp(params,str)) == 1);
end


function Rout = repeat(x)
% repeat   checks for repeat inputs
%   repeat(x)

Rout = [];

results = [];

while exist('../writing.dat','file') % Wait until file is read-safe
end

while isempty(results) % Try until the file can be read
    try
        results = csvread('../results.txt'); % Read file
    catch
        pause(0.01);
    end
end

for i = 1:size(results,1) % Parse results
    if sqrt(sum( (results(i,1:length(x))-x').^2 )) < 1e-6
        Rout = results(i,(length(x)+1):end);
        break
    end
end


function LogResult(R)
% LogResult   concatenates the result to the worker-specific results file
%    LogResult(R) adds the vector R to the results file

LOG = [];

while exist('writing.dat','file') % Wait until file is read-safe
end

try % Tell master processor to wait if it is trying to read 
    csvwrite('writing.dat',1);
catch
end

if exist('MYresults.txt','file') % Try until the file can be read
    try
        LOG = csvread('MYresults.txt'); % Read file from that processor
    catch
    end
end

if isempty(LOG)
    LOG = R;
else
    try
        LOG = [LOG;R];
    catch
        disp(['LogResult failure: LOG=',num2str(size(LOG,2)),' R=',num2str(size(R,2))])
    end
end

try
    dlmwrite('MYresults.txt',LOG,'delimiter',',','precision',9);
catch
end

try
    delete('writing.dat');
catch
end


function combineResults()

LOG = [];

while isempty(LOG) % Try until the file can be read
    try
        LOG = csvread('results.txt'); % Read complete results file
    catch
    end
end

poolsize = 16;

R = []; % All new results

for i = 1:poolsize
    
    Ri = []; % Worker results
    
    while exist(['worker',num2str(i),'/writing.dat'],'file') % Wait until file is read-safe
    end
    
    try % Tell processor to wait if it is trying to read
        csvwrite(['worker',num2str(i),'/writing.dat'],1);
    catch
    end
    
    try
        Ri = csvread(['worker',num2str(i),'/MYresults.txt']); % Read worker's results file
        disp(['worker',num2str(i),'/MYresults.txt',' read'])
    catch
    end
    
    try
        R = [R;Ri];
    catch
        disp(['combineResults failure i=',num2str(i),': R=',num2str(size(R,2)),' Ri=',num2str(size(Ri,2))])
    end
    
    try
        delete(['worker',num2str(i),'/MYresults.txt']);
    catch
    end
    
    try
        delete(['worker',num2str(i),'/writing.dat']);
    catch
    end
end

try % Tell processors to wait if trying to read 
    csvwrite('writing.dat',1);
catch
end

if LOG(1,1) == 0
    LOG = R;
else
    try
        LOG = [LOG;R];
    catch
        disp(['combineResults: LOG=',num2str(size(LOG,2)),' R=',num2str(size(R,2))])
    end
end

try
    dlmwrite('results.txt',LOG,'delimiter',',','precision',9);
catch
end

try
    delete('writing.dat');
catch
end

