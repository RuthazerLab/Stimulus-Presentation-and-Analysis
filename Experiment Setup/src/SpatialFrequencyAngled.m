function [I J] = SpatialFrequencyAngled(theta,height,width)

F = compFact(width);
F = F(1:end-2);
num = length(F);

a1 = abs(cos(theta*pi/180));
a2 = abs(cos(pi/2-theta*pi/180));

L1 = width*a1;
L2 = width*a2;
H = abs(ceil(L1*L2/width));
BigL = abs(ceil(L1+L2));

I = [];
K = [];

I = ones(BigL,BigL,num);
J = ones(BigL,BigL,num);
for i = 1:num
	for j = 1:BigL
	  I(:,j,i) = 0.5+0.5*sin(2*pi*j*F(i)/width);
	  J(:,j,i) = 0.5+0.5*sin(pi+2*pi*j*F(i)/width);
	end
end

for i = 1:num
	temp1 = imrotate(I(:,:,i),theta);
	temp2 = imrotate(J(:,:,i),theta);
	K1(:,:,i) = temp1(H+1:end-H,H+1:end-H);
	K2(:,:,i) = temp2(H+1:end-H,H+1:end-H);
end

I1 = ones(width,width,num);
J1 = ones(width,width,num);

[a1 b1] = size(K1(:,:,1));
[a2 b2] = size(K2(:,:,1));

L = width;

if(a1 < L)
	if(b1 < L)
		I1(1:a1,1:b1,:) = K1;
	else
		I1(1:a1,:,:) = K1(:,1:L,:);
	end
else
	if(b1 < L)
		I1(:,1:b1,:) = K1(1:L,:,:);
	else
		I1 = K1(1:L,1:L,:);
	end
end
if(a2 < L)
	if(b2 < L)
		J1(1:a2,1:b2,:) = K2;
	else
		J1(1:a2,:,:) = K2(:,1:L,:);
	end
else
	if(b2 < L)
		J1(:,1:b2,:) = K2(1:L,:,:);
	else
		J1 = K2(1:L,1:L,:);
	end
end

I = ones(height,width,num);
J = ones(height,width,num);

I = I1(1:height,1:width,:);
J = J1(1:height,1:width,:);


