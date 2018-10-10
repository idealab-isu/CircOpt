function [x0, lb, ub, scaling] = paramsBiVRef(params,BiV)
% paramsBiVRef   Supplies initialized parameter data for optBiV using ParRef
%   [x0, lb, ub, scaling] = paramsBiVRef(params) accepts a cell list of parameter name strings. 'scaling' is multiplied with the other values in evalBiV
%   paramsBiVRef() returns a list of all available parameters

%% Build reference table

load('ParRef')
ParRef = Par;

%    string           , x0                                          , lb   , ub    , scaling
varRef = struct( ...
    'scalep0'         , [1                        ,  0.8 ,    1.2, 1  ], ... % (-) Scale mean arterial pressure from 33% rule
    'pDropPulm'       , [ParRef.General.pDropPulm ,   500,   1500, 1e3], ... % (Pa)
    'LAvLeak'         , [1e-6                     ,  1e-6,    0.2, 1  ], ... % (-) Ratio from valve open area
    'scaleTubeLArtLen', [1                        ,  0.5 ,    1.5, 1  ], ... % (-) Scale length as a ratio of diameter
    'scaleTubeRArtLen', [1                        ,  0.5 ,    1.5, 1  ], ... % (-) Scale length as a ratio of diameter
    'scaleLv'         , [1                        ,  0.5 ,    2  , 1  ], ... % (-) Scale ref midwall area
    'scaleRv'         , [1                        ,  0.66,    1.5, 1  ], ... % (-) Scale ref midwall area
    'scaleRvRel'      , [1                        ,  0.5 ,    2  , 1  ], ... % (-) Scale ref midwall area relative to scaleLv
    'scaleSv'         , [1                        ,  0.66,    1.5, 1  ], ... % (-) Scale ref midwall area
    'scaleSvRel'      , [1                        ,  0.66,    1.5, 1  ], ... % (-) Scale ref midwall area relative to scaleLv
    'scaleLa'         , [1                        ,  0.66,    1.5, 1  ], ... % (-) Scale ref midwall area
    'scaleLaRel'      , [1                        ,  0.66,    1.5, 1  ], ... % (-) Scale ref midwall area relative to scaleLv
    'scaleRa'         , [1                        ,  0.66,    1.5, 1  ], ... % (-) Scale ref midwall area
    'scaleRaRel'      , [1                        ,  0.66,    1.5, 1  ], ... % (-) Scale ref midwall area relative to scaleLv
    'SfAct'           , [Par.Lv.Sarc.SfAct        , 25000, 200000, 1e5], ... % (Pa) Active stiffness
    'SfPas'           , [Par.Lv.Sarc.SfPas        , 10000,  30000, 1e4], ... % (Pa) Passive stiffness
    'dLsPas'          , [Par.Lv.Sarc.dLsPas       ,  0.3 ,    1.2, 1  ]); % (-) Nonlinearity of stiffness

if nargin == 0 % Display list (optional)
    fieldnames(varRef)
    return
elseif nargin == 2
    BiVstruct = eval(['dataBiV',num2str(BiV),'()']); % Get data for patient
    scaleSfPas = 1; %%%%%%%%%%BiVstruct.EDV; ????????????????????
    
    tempSfPas = varRef.SfPas;
    tempSfPas(2:3) = tempSfPas(2:3)*scaleSfPas;
    varRef.SfPas = tempSfPas;
end

%% Generate output data

x0      = zeros(length(params),1);
lb      = zeros(length(params),1);
ub      = zeros(length(params),1);
scaling = zeros(length(params),1);

for i = 1:length(params)
    if isfield(varRef,params{i})
        x0(i)      = varRef.(params{i})(1);
        lb(i)      = varRef.(params{i})(2);
        ub(i)      = varRef.(params{i})(3);
        scaling(i) = varRef.(params{i})(4);
    else
        error(['No data match found for variable: ',params{i}])
    end
end

x0 = x0./scaling;
lb = lb./scaling;
ub = ub./scaling;