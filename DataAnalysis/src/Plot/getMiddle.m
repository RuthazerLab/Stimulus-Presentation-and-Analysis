function mid = getMiddle(Responses,k,Config)

siz = Config.Number^0.5;
typ = Config.Type;

% Reshapes Responses variable (from XCor.m) into grid
if(typ == 1)
	RoiResponse = Responses(2:end,k) - Responses(1,k);
elseif(typ == 5)
	RoiResponse = Responses(siz^2+2:end,k) - Responses(siz^2,k);
elseif(typ == 6)
	siz = Config.Number/2;
	T = Responses(2:end,k);
	Q = zeros(siz,siz);
	for i = 1:siz
		Q(i,:) = Q(i,:) + repmat(T(i),[1 siz]);
		Q(:,i) = Q(:,i) + repmat(T(i+siz),[siz 1]);
	end
	RoiResponse = reshape(Q,[siz^2 1]);
else
	mid = [1 1];
	return;
end

% Interpret negative responses as natural variance
% and use as a threshold
minimum = min(RoiResponse);
if(minimum < 0)
	RoiResponse = max(RoiResponse + minimum,0);
end

% If there are no responses, return 0
if(sum(RoiResponse) == 0)
	mid = [0 0];
	return;
end

A = reshape(RoiResponse,[siz siz]);
if(typ == 6)
	A = Q;
end
S = zeros(siz,siz);

for i = 1:siz
	for j = 1:siz
		for m = 1:siz
			for n = 1:siz
				% Metric weights center by a power of three times euclidean distance
				S(i,j) = S(i,j) + A(m,n)^3*sqrt((m-i)^2 + (n-j)^2);
			end
		end
	end
end

% Finds minimum norm value
P = find(S == min(min(S)));
[h v] = getSquareCoords(P,siz);

mid = [v h];