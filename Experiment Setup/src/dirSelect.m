function I = dirSelect(theta,L,W)

a1 = abs(cos(theta*pi/180));
a2 = abs(cos(pi/2-theta*pi/180));

L1 = L*a1;
L2 = L*a2;
H = abs(ceil(L1*L2/L));
BigL = abs(ceil(L1+L2));

J = zeros(BigL,BigL+W);
I = [];
K = [];

% for i = 1:round((BigL)/W)+1
% 	for j = 1:W
% 		J(:,W*(i-1)+j) = j/W;
% 	end
% end

j = 1:BigL+W+1;
J(:,j) = repmat(0.5+0.5*sin(j*2*pi/W),[BigL 1]);

for i = 1:W
	temp = imrotate(J(:,i:i+BigL),theta);
	K(:,:,i) = temp(H+1:end-H+1,H:end-H+1);
end

% I = 0.5*ones(L,L,W);

[a b] = size(K(:,:,1));
I = K;



% if(a < L)
% 	if(b < L)
% 		I(1:a,1:b,:) = K;
% 	else
% 		I(1:a,:,:) = K(:,1:L,:);
% 	end
% else
% 	if(b < L)
% 		I(:,1:b,:) = K(1:L,:,:);
% 	else
% 		I = K(1:L,1:L,:);
% 	end
% end


