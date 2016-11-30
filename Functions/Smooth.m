function V_Smoothed = Smooth(V, Range);

	Low = Range(1); High = Range(2);

	V_Smoothed = zeros(1,length(V));

	for i = 1:length(V)
		V_Smoothed(i) = mean(V(max(1,i+Low):min(end,i+High)));
	end

