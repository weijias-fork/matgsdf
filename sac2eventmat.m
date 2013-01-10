% This script is used to convert event based sac files into event mat which is the input for the following 
% scripts
%
%
clear;

dbpath = './sacdata/';
eventfile = 'allevent';
outpath = './eventmat/';

if ~exist(outpath)
	mkdir(outpath);
end

eventids = textread([dbpath,eventfile],'%s');

for ie = 1:length(eventids)
	clear event
	datapath = [dbpath, char(eventids(ie)),'/'];
	disp(datapath);
	saclist = dir([datapath,'*.sac']);
	for isac = 1:length(saclist)
		% read sac file
		sacfilename = [datapath,saclist(isac).name];
		sac = readsac(sacfilename);
		days = (datenum(sac.NZYEAR-1,12,31)+sac.NZJDAY-datenum(1970,1,1));
		otime = days*24*3600 + sac.NZHOUR*3600+sac.NZMIN*60+sac.NZSEC+sac.NZMSEC/1000;
		% initial the event information by the first sac file
		if isac == 1
			event.evla = sac.EVLA;
			event.evlo = sac.EVLO;
			event.otime = otime;
			event.dbpath = datapath;
		end
		% build up event.stadata structure
		event.stadata(isac).stla = sac.STLA;
		event.stadata(isac).stlo = sac.STLO;
		event.stadata(isac).stel = sac.STEL;
		event.stadata(isac).dist = deg2km(distance(sac.STLA,sac.STLO,sac.EVLA,sac.EVLO));
		event.stadata(isac).otime = otime+sac.B;
		event.stadata(isac).delta = sac.DELTA;
		event.stadata(isac).data = sac.DATA1;
		event.stadata(isac).cmp = sac.KCMPNM;
		event.stadata(isac).stnm = sac.KSTNM;
		event.stadata(isac).filename = sacfilename;
		if sac.DELTA == 1
			event.stadata(isac).cmp = 'LHZ';
		end
	end
	matfilename = [outpath,char(eventids(ie))];
	save(matfilename,'event')
	disp(['Save to ',matfilename]);
end % end of loop ie

