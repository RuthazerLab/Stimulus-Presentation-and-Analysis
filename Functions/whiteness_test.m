function R = whiteness_test(x,m)
	N = length(x);
	x = (x-repmat(mean(x),[1 N]))/std(x);
	rsq = 0;
	for i = 1:m
		rsq = rsq + rhat(i,x)^2;
	end

	R = N/rhat(0,x)^2*rsq;

function r = rhat(tau,x)
	N = length(x);
	r = 0;
	for t = 1:N-tau
		r = r + x(t+tau)*x(t);
	end
	r = r/N;