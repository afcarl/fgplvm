% DEMROBOTWOLOOPS1 Wireless Robot data from University of Washington, without dynamics and without back constraints.

% Fix seeds
randn('seed', 1e5);
rand('seed', 1e5);

dataSetName = 'robotTwoLoops';
experimentNo = 1;

% load data
[Y, lbls] = lvmLoadData(dataSetName);

% Set up model
options = fgplvmOptions('pitc');
options.back = 'mlp';
options.backOptions = mlpOptions;

latentDim = 2;
d = size(Y, 2);

model = fgplvmCreate(latentDim, d, Y, options);

% Add dynamics model.
options = gpOptions('pitc');
options.kern = kernCreate(model.X, {'rbf', 'white'});
options.kern.comp{1}.inverseWidth = 0.2;
% This gives signal to noise of 0.1:1e-3 or 100:1.
options.kern.comp{1}.variance = 0.1^2;
options.kern.comp{2}.variance = 1e-3^2;
model = fgplvmAddDynamics(model, 'gp', options);

% Optimise the model.
iters = 1000;
display = 1;

model = fgplvmOptimise(model, display, iters);

% Save the results.
capName = dataSetName;
capName(1) = upper(capName(1));
save(['dem' capName num2str(experimentNo) '.mat'], 'model');



% Load the results and display dynamically.
fgplvmResultsDynamic(dataSetName, experimentNo, 'vector')

