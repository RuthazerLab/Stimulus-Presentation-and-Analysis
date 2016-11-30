function c = propThresh(A)

% This function thresholds at 1.5 x interquartile range

[a b] = size(A);

for j = 1:a

	B = A(j,:);

	ThirdQ = quantile(B,0.75);

	T = ThirdQ + 1.5 * (ThirdQ - quantile(B,0.25));

	B(B<T) = 0;

	c(j,:) = B;

end

