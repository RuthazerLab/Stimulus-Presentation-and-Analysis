function I = threshold(I)

Thresh = kittler(I);

I(I < Thresh) = -1;

I(I>0) = 0;
I(I<0) = 1;