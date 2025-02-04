function [Y] = arbilpf(X, Mx, My, O)
	Y = zeros(size(X));
	% image dimensions, for easy reference
	M = size(Y, 1);
	N = size(Y, 2);
	C = size(Y, 3);
	% the ripple and stopband specifications were chosen pretty arbitrarily
	% these should be chosen so as to optimize the transition width
	Bx = firpm(O, [0 0.85/Mx 1.15/Mx 1], [1 1 0 0], [30 1]);
	Bx = normalize_fir(Bx);
	By = firpm(O, [0 0.85/My 1.15/My 1], [1 1 0 0], [30 1]);
	By = normalize_fir(By);

	% debugging statements
	[Hx, Wx] = freqz(Bx, [1]);

	% note: the filters should be designed such that the square of their magnitudes
	% meets the specified requirements
	% the filtering mechanism that will be implemented will be an FPGA version
	% of filtfilt
	for c=1:C
		% filter in the Y direction and then flip the result
		for j=1:N
			Y(:,j,c) = mirconv(X(:,j,c)', By)';
		end
		% repeat for X direction
		for i=1:M
			Y(i,:,c) = mirconv(Y(i,:,c), Bx);
		end
	end
end

function [Bo] = normalize_fir(B)
	[H,W] = freqz(B,[1],2^10);
	max_amp = max(abs(H));
	Bo = B/max_amp;
end

% must be row vectors
function [Y] = mirconv(X, H)
	l = size(H, 2);
	Xmir = horzcat(X((l+1):-1:2), X, X((end-1):-1:(end-l)));
	Ymir = conv(Xmir, H, 'same');
	Y = Ymir((1+l):(end-l));
end
