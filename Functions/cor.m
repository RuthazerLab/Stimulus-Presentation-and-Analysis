function rho = cor(v1, v2)
	% rho = cor(v1,v2)
	% 	Returns the correlation between vectors v1 and v2

	v1 = reshape(v1,[1 260]); v2 = reshape(v2,[1 260]);
	covariance = cov(v1,v2);

	if(covariance(1,2) ~= covariance(2,1))
		rho = 0;
	else
		rho = (covariance(1,2)*covariance(2,1))/(covariance(1,1)*covariance(2,2));
	end
end
