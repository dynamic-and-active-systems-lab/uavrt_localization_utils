% BEARING_CODEGEN_SCRIPT   Generate executable bearing from
%  bearing.m
% 
% 
% See also CODER, CODER.CONFIG, CODER.TYPEOF, CODEGEN.

%% Create configuration object of class 'coder.EmbeddedCodeConfig'.
cfg = coder.config('exe','ecoder',true);
cfg.HardwareImplementation.ProdEqTarget = false;
cfg.TargetLang = 'C++';
cfg.GenCodeOnly = true;
cfg.GenerateExampleMain = 'DoNotGenerate';
cfg.GenerateMakefile = false;
cfg.GenerateReport = true;
cfg.MaxIdLength = 1024;
cfg.ReportPotentialDifferences = false;
cfg.TargetLangStandard = 'C++11 (ISO)';
cfg.RuntimeChecks = true;

%% Define argument types for entry-point 'airspy_channelize'.
ARGS = cell(1,1);
ARGS{1} = cell(1,1);
ARGS{1}{1} = coder.typeof('X',[1 Inf],[0 1]);

%% Invoke MATLAB Coder.
codegen -config cfg bearing -args ARGS{1}

