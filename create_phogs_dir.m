function create_phogs_dir(imdir,featuredir,type);

warning off
addpath ~/matlab/mfiles/hog
warning on

if ~strcmp(imdir(end),'/')
    imdir(end+1) = '/';
end
if ~strcmp(featuredir(end),'/')
    featuredir(end+1) = '/';
end

Xfiles = dir([imdir '*.' type]);

if ~exist(featuredir,'dir')
    fprintf('creating dir: ''%s''\n',featuredir);
    s = system(['mkdir -p ' featuredir]);
    if s~=0
	error('failed to created dir');
    end
end

shuff = randperm(numel(Xfiles));
for i=1:numel(Xfiles)
    tic;
    ii = shuff(i);
    
    fname = [imdir Xfiles(ii).name];

    if (1)
	phogfname = sprintf('%s%s.mat',featuredir,Xfiles(ii).name);
	if exist(phogfname,'file')
	    fprintf('this file already exists, skipping...\r');
	    continue;
	end
	try
	    [A180,A360,E,Gr] = vgg_phog_preprocess(fname);
	    save(phogfname,'A180','A360','E','Gr');
	catch
	    
	end
	
    else
	% create the hogs for 180 and 360 degrees and store them both
	% in the same file
	phogfname = sprintf('%s%s.phog',featuredir,Xfiles(ii).name);
	if exist(phogfname,'file') || exist([phogfname '.gz'],'file')
	    fprintf('this file already exists, skipping...\r');
	    continue;
	end

	
	I = imread(fname);
	try
	    [f180,coords] = hog(I,180);
	    [f360,coords] = hog(I,360);
	    
	    t = [coords(:,1),coords(:,2),f180,f360];
	    fid = fopen(phogfname,'w');
	    fprintf(fid,'%d %d\n',size(I,1),size(I,2));
	    fprintf(fid,'%d %d %.4f %.4f\n',t');
	    fclose(fid);
	    clear t;
	catch
	    I = imresize(I,0.5);
	    [f180,coords] = hog(I,180);
	    [f360,coords] = hog(I,360);
	    
	    t = [coords(:,1),coords(:,2),f180,f360];
	    fid = fopen(phogfname,'w');
	    fprintf(fid,'%d %d\n',size(I,1),size(I,2));
	    fprintf(fid,'%d %d %.4f %.4f\n',t');
	    fclose(fid);
	    clear t;
	    fprintf('could not process %s\n',fname);
	end
    end
    t=toc;
    fprintf('%d of %d done, %.2f seconds per image\r',i,numel(Xfiles),t);
end
