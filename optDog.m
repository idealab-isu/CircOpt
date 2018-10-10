function [Xmin,Smin] = optDog(BiV,params,nWorkers)
% optDog   Optimizes a set of parameters in CircAdapt for a given subject
%   [Xmin,Smin] = optDog(BiV,params) determines the optimal parameter
%   values "Xmin" and fit "Smin" for the selected subject "BiV" and
%   structure of parameters "params"
%
%   [Xmin,Smin] = optDog(BiV,params,nWorkers) is used to set the number of
%   parallel workers
%   

%% Prep files and parallel workers/folders

if nWorkers > 1
    poolobj = gcp('nocreate'); % Check for existing pool
    if nargin == 3
        if isempty(poolobj) % If there is none, create one
            parpool('local',nWorkers)
        end
    else
        if isempty(poolobj) % If there is none, create one
            parpool('local')
        end
    end
end

poolobj = gcp('nocreate'); % Check again for existing pool
if isempty(poolobj) % If there is none, run in serial
    poolsize = 1;
else % If there is one, get the size
    poolsize = poolobj.NumWorkers;
end

for i = 1:poolsize % Create CircAdapt folder for workers
    disp(['Creating folder for worker',num2str(i)])
    copyfile('worker0',['worker',num2str(i)])
end

if exist('results.txt','file') % Duplicate old results file for backup
    copyfile('results.txt','results2.txt')
end

dlmwrite('results.txt',zeros(1,length(params)+8),'delimiter',',','precision',9); % 

try % Clean old data
    delete(['D',num2str(BiV),'.mat']);
catch
end

%% Initialize

ManualSfPas = 0; % Use preset value of SfPas in dog data (from materialregression)

if ManualSfPas
    params{length(params)+1} = 'SfPas';
    BiVstruct = eval(['dataD',num2str(BiV),'()']); % Get data for patient
end

[x0, lb, ub, scaling] = paramsDogRef(params); % Get necessary data for given parameters

if ManualSfPas
    x0(end) = BiVstruct.SfPas;
    lb(end) = BiVstruct.SfPas;
    ub(end) = BiVstruct.SfPas;
end

BiVoptions = struct('CheckRepeat', true); %, 'NumSteps', 1);

%% Optimization

method = 'PSO'; %'PSO' or 'DS'

tic

if nWorkers > 1
    DSoptions = optimoptions('patternsearch','Display','iter','UseCompletePoll',true,'UseParallel',true,'FunctionTolerance',1e-1,'StepTolerance',0.25e-1);
    PSOoptions = optimoptions('particleswarm','Display','iter','UseParallel',true,'FunctionTolerance',1e-1,'HybridFcn',{@patternsearch,DSoptions});
else
    DSoptions = optimoptions('patternsearch','Display','iter','UseCompletePoll',true,'FunctionTolerance',1e-1,'StepTolerance',0.25e-1);
    PSOoptions = optimoptions('particleswarm','Display','iter','FunctionTolerance',1e-1,'HybridFcn',{@patternsearch,DSoptions});
end

switch method
    case 'DS'
        [Xmin,Smin] = patternsearch(@(x)evalDog(BiV,params,x,scaling,BiVoptions),x0,[],[],[],[],lb,ub,[],DSoptions);
    case 'PSO'
        [Xmin,Smin] = particleswarm(@(x)evalDog(BiV,params,x,scaling,BiVoptions),length(x0),lb,ub,PSOoptions);
end

totalTime = toc;

disp(['Total optimization time was: ',num2str(totalTime/3600,'%.1f'), ' hrs'])

%% Cleanup

save(['D',num2str(BiV),'.mat'])

delete(gcp('nocreate')) % Close worker pool
