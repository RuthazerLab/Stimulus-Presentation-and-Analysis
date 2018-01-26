load('Sampled.mat');

Significance_Level = 0.99;

% RoiMin x # Fish matrix of 1s and 0s. 1 indicates index was higher than significance level
Significant_Indicies = LM.RSquared > Significance_Level;

% for each fish
for i = 1:size(Significant_Indicies,2)
	Significant_ROIs{i} = RoiNumbers(find(Significant_Indicies(:,i)),i);
end


