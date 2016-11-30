function I = suint16(I)

r = (2^16-1) / double(max(max(max(I)))); 

I = uint16(I * r);