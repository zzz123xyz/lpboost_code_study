%
% Compute the Phog data for all 1000 random subwindows
%
clear all
f{1}.type = 'randomsubwindows_shape';
f{1}.angle = 360;
f{1}.K = 40;
f{1}.level = 0;
f{1}.nSubwindows = 1000;

dataset = '101'

switch dataset 
 case '101'
  imtype = 'jpg';
  datadir = ['~/projects/caltech/caltech101'];
 case '256'
  imtype = 'jpg';
  datadir = ['~/projects/caltech/caltech256'];
end

Xdirs = dir(datadir);

nClasses = 0;
for i=1:numel(Xdirs)
    
    if ~Xdirs(i).isdir
	continue;
    end
    
    
    if strcmp(Xdirs(i).name,'.') || strcmp(Xdirs(i).name,'..')
	continue;
    end
    
    % remove the links chl created in the directory
    if strcmp(dataset,'256') && ~numel(strfind(Xdirs(i).name,'.'))
	continue;
    end
    
    if strcmp(dataset,'101') && strcmp(Xdirs(i).name,'BACKGROUND_Google')
	continue;
    end

    if strcmp(dataset,'256') && strcmp(Xdirs(i).name,'257.clutter')
	continue;
    end
    
    nClasses = nClasses + 1;
    class{nClasses} = Xdirs(i).name;
end
class = sort(class);
for i=1:nClasses
    classdir{nClasses} = [datadir '/' class{i}];
end


fprintf('found %d classes\n',nClasses);

fl = randperm(numel(f));
for fff=1:numel(fl)
    ff = fl(fff);
    
    cl = randperm(nClasses);
    for cc=1:nClasses
	c=cl(cc);
	fprintf('processing class ''%s''\n',class{c});
	featfile = feature_filename(f{ff},dataset,class{c});
	if (exist(featfile,'file'))
	    fprintf(['file ''',featfile,''' exists, skipping\n']);
	    continue;
	end
	
	Xfiles = dir([datadir '/' class{c} '/*.' imtype]);

	fname = [];
	for i=1:numel(Xfiles)
	    fname{i} = Xfiles(i).name;
	end
	fname = sort(fname);
	
	for i=1:numel(fname)
	    fname{i} = sprintf('%s/%s',class{c},fname{i});
	end
	
	keyboard
	
	[x] = generate_features(f{ff},fname,dataset);
	y = c*ones(size(x,1),1);
	
	if ~exist(featfile,'file')
	    save(featfile,'x','y','fname')
	end
	clear x y;
    end
end
