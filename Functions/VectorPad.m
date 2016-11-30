function Padded_Vector = VectorPad(Vector,Length,Direction)

	% FUNCTION Padded_Vector = VectorPad(Vector,Length,Direction)
	% 	Vector: vector which you wish to pad with zeros
	% 	Length: length of final vector
	% 	Direction:
	% 		-1 Left Side
	% 		 1 Right Side
	% 		 0 Symmetric

	Padded_Vector = [];

	if(nargin ~= 3 || sum(Direction == [-1 0 1]) ~= 1)
		help VectorPad;
		return;
	end

	if(length(Vector) > Length)
		Padded_Vector = Vector;
		return;
	end

	Length = Length - length(Vector);

	if(Direction == 0 && mod(Length,2) ~= 0)
		disp('Padded Vector cannot be symmetric.');
		return;
	end

	switch Direction

	case -1
		Padded_Vector = [zeros(1,Length) Vector];
	case 0
		Padded_Vector = [zeros(1,Length/2) Vector zeros(1,Length/2)];
	case 1
		Padded_Vector = [Vector zeros(1,Length)];
	end

end


