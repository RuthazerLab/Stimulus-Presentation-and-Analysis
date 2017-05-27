function I = suint8(I)

r = (2^8-1) / double(max(max(max(I)))); 

I = uint8(I * r);

end