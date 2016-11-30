function t = now2num()

% t = now2num()
% 	Returns the number of seconds since midnight

time = datestr(now,'dd-mm-yyyy HH:MM:SS FFF');

hr = str2num(time(12:13));
mi = str2num(time(15:16));
sc = str2num(time(18:19));
ms = str2num(time(21:23));

t = 3600*hr+60*mi+sc+ms/1000;
