function output = F_function(a,b)

% fixp = {7,7, 's'}; % # of integer bits (wo the sign), # of fractional bits, signed
% fixpu = {7,7, 'u'};
% qtype = 'SatTrc_NoWarn'; % Saturate the integer part, and trunctate the fractional part

f=@(a,b)(1-2*(a<0)).*(1-2*(b<0)).*min(abs(a),abs(b));%minsum

output = f(a,b);

end


