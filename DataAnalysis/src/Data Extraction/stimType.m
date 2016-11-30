function S = stimType(L)

% Converts stimulus type into name

typ = L(1,3);

stims = {'Calibrate Setup'; 'Random Squares'; 'Intensity Circles'; 'Moving Bars'; 'Brightness Levels'; 'Balanced Squares';'Mutli Balanced Squares';'Balanced Circles';'Varying Radii'};

S = stims(typ);



