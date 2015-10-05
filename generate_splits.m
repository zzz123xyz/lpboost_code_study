% script: generate_splits
%
% generate several splits to be saved in 'splits/'
%
% splits are nested
clear all

rand('twister',100*sum(clock))

dataset = '101'
splitnums = 4:5

switch dataset 
 case '101'
  imtype = 'jpg';
  nTrainSamples = 30:-5:5;
  nTestSamples = [50];
  datadir = ['~/projects/caltech/caltech101_images'];
 case '256'
  imtype = 'jpg';
  nTrainSamples = [5,10,15,20,25,30,40,50];
  nTestSamples = 25;
  datadir = ['~/projects/caltech/caltech256_images'];
end

if (0)
system('find caltech101_images/* -type d > caltech101_dirlist');
system('find caltech256_images/* -type d > caltech256_dirlist');
end

classes101 = textread('caltech101_dirlist','%s\n');
classes256 = textread('caltech256_dirlist','%s\n');

assert(numel(classes101)==102);
assert(numel(classes256)==257);

files101 = textread('caltech101_filelist','%s\n');
files256 = textread('caltech256_filelist','%s\n');

assert(numel(files101)==9143);
assert(numel(files256)==30607);

files101 = strrep(files101,'caltech101_images/','');
classes101 = strrep(classes101,'caltech101_images/','');

files256 = strrep(files256,'caltech256_images/','');
classes256 = strrep(classes256,'caltech256_images/','');

for i=1:numel(files101)
    t = strfind(files101{i},'/');
    tmpclass{i} = files101{i}(1:t-1);
    label101(i,1) = find(strcmp(classes101,tmpclass{i}));
end

for i=1:numel(files256)
    t = strfind(files256{i},'/');
    tmpclass{i} = files256{i}(1:t-1);
    label256(i,1) = find(strcmp(classes256,tmpclass{i}));
end
assert(all(label256>0))



% CALTECH 101
if strcmp(dataset,'101')
    for nn=1:numel(splitnums)
	N = splitnums(nn);
	
	tr30 = []; tr25 = []; tr20 = []; tr15 = []; tr10 = []; tr5 = [];
	te30 = []; te25 = []; te20 = []; te15 = []; te10 = []; te5 = [];

	for c=1:102
	    ind = find(label101==c);

	    ind = ind(randperm(numel(ind)));
	    
	    tr30 = [tr30;ind(1:30)]; 
	    te=ind(31:end);te(51:end) = [];
	    te30 = [te30;te];
	    
	    tr25 = [tr25;ind(1:25)]; 
	    te=ind(26:end);te(51:end) = [];
	    te25 = [te25;te];

	    tr20 = [tr20;ind(1:20)]; 
	    te=ind(21:end);te(51:end) = [];
	    te20 = [te20;te];

	    tr15 = [tr15;ind(1:15)]; 
	    te=ind(16:end);te(51:end) = [];
	    te15 = [te15;te];

	    tr10 = [tr10;ind(1:10)]; 
	    te=ind(11:end);te(51:end) = [];
	    te10 = [te10;te];

	    tr5 = [tr5;ind(1:5)]; 
	    te=ind(6:end);te(51:end) = [];
	    te5= [te5;te];

	end

	assert(numel(intersect(tr30,te30))==0);
	assert(numel(intersect(tr25,te25))==0);
	assert(numel(intersect(tr20,te20))==0);
	assert(numel(intersect(tr15,te15))==0);
	assert(numel(intersect(tr10,te10))==0);
	assert(numel(intersect(tr5,te5))==0);

	class = classes101;
	for n=5:5:30
	    tr_files = []; te_files = [];
	    tr_label = []; te_label = [];
	    eval(['tr_ind=tr',num2str(n),';']);
	    eval(['te_ind=te',num2str(n),';']);

	    for i=1:numel(tr_ind)
		tr_files{i} = files101{tr_ind(i)};
		tr_label(i,1) = label101(tr_ind(i));
	    end
	    for i=1:numel(te_ind)
		te_files{i} = files101{te_ind(i)};
		te_label(i,1) = label101(te_ind(i));
	    end
	    for i=1:numel(tr_files)
		for j=1:numel(te_files)
		    assert(strcmp(te_files{j},tr_files{i})==0);
		end
	    end
	    
	    splitfile = ['/agbs/cluster/pgehler/projects/caltech/splits/caltech101_nTrain',num2str(n),'_nTest50_N',num2str(N),'.mat'];
	    if exist(splitfile,'file')
		warning(['file ''',splitfile,''' exists! skipping']);
		continue; 
	    end
	    save(splitfile,'tr_files','tr_label','te_label','te_files','class','tr_ind','te_ind');
	    
	    
	    [split.train_ind,split.test_ind] = create_cvsplit(tr_label,5);
	    save(strrep(splitfile,'.mat','_cvsplit.mat'),'split');

	    %save(splitfile,'tr_ind','te_ind','class','classdir');
	end
    end


elseif strcmp(dataset,'256')
% CALTECH 256

    for nn=1:numel(splitnums)
	N = splitnums(nn);
	
	tr50 = []; tr40 = []; tr30 = []; tr25 = []; tr20 = []; tr15 = []; tr10 = []; tr5 = [];
	te50 = []; te40 = []; te30 = []; te25 = []; te20 = []; te15 = []; te10 = []; te5 = [];

	for c=1:257
	    
	    % remove clutter
	    if (find(strcmp(classes256,'257.clutter'))==c)
		continue;
	    end
	    
	    ind = find(label256==c);

	    ind = ind(randperm(numel(ind)));
	    
	    tr50 = [tr50;ind(1:50)]; 
	    te=ind(end:-1:51);te(26:end) = [];
	    te50 = [te50;te];

	    tr40 = [tr40;ind(1:40)]; 
	    te=ind(end:-1:41);te(26:end) = [];
	    te40 = [te40;te];

	    tr30 = [tr30;ind(1:30)]; 
	    te=ind(end:-1:31);te(26:end) = [];
	    te30 = [te30;te];
	    
	    tr25 = [tr25;ind(1:25)]; 
	    te=ind(end:-1:26);te(26:end) = [];
	    te25 = [te25;te];

	    tr20 = [tr20;ind(1:20)]; 
	    te=ind(end:-1:21);te(26:end) = [];
	    te20 = [te20;te];

	    tr15 = [tr15;ind(1:15)]; 
	    te=ind(end:-1:16);te(26:end) = [];
	    te15 = [te15;te];

	    tr10 = [tr10;ind(1:10)]; 
	    te=ind(end:-1:11);te(26:end) = [];
	    te10 = [te10;te];

	    tr5 = [tr5;ind(1:5)]; 
	    te=ind(end:-1:6);te(26:end) = [];
	    te5= [te5;te];

	end

	assert(numel(unique(te50))==numel(te50));
	assert(numel(unique(te40))==numel(te40));
	assert(numel(unique(te30))==numel(te30));
	assert(numel(unique(te25))==numel(te25));
	assert(numel(unique(te20))==numel(te20));
	assert(numel(unique(te15))==numel(te15));
	assert(numel(unique(te10))==numel(te10));
	assert(numel(unique(te5))==numel(te5));

	assert(numel(unique(tr50))==numel(tr50));
	assert(numel(unique(tr40))==numel(tr40));
	assert(numel(unique(tr30))==numel(tr30));
	assert(numel(unique(tr25))==numel(tr25));
	assert(numel(unique(tr20))==numel(tr20));
	assert(numel(unique(tr15))==numel(tr15));
	assert(numel(unique(tr10))==numel(tr10));
	assert(numel(unique(tr5))==numel(tr5));

	assert(numel(intersect(tr50,te50))==0);
	assert(numel(intersect(tr40,te40))==0);
	assert(numel(intersect(tr30,te30))==0);
	assert(numel(intersect(tr25,te25))==0);
	assert(numel(intersect(tr20,te20))==0);
	assert(numel(intersect(tr15,te15))==0);
	assert(numel(intersect(tr10,te10))==0);
	assert(numel(intersect(tr5,te5))==0);

	class = classes256;
	for n=[5:5:30,40,50]
	    tr_files = []; te_files = [];
	    tr_label = []; te_label = [];
	    eval(['tr_ind=tr',num2str(n),';']);
	    eval(['te_ind=te',num2str(n),';']);

	    for i=1:numel(tr_ind)
		tr_files{i} = files256{tr_ind(i)};
		tr_label(i,1) = label256(tr_ind(i));
	    end
	    for i=1:numel(te_ind)
		te_files{i} = files256{te_ind(i)};
		te_label(i,1) = label256(te_ind(i));
	    end
	    for i=1:numel(tr_files)
		assert(all(strcmp(te_files,tr_files{i}))==0);
	    end
	    
	    splitfile = ['/agbs/cluster/pgehler/projects/caltech/splits/caltech256_nTrain',num2str(n),'_nTest25_N',num2str(N),'.mat'];
	    if exist(splitfile,'file')
		warning(['file ''',splitfile,''' exists! skipping']);
		continue; 
	    end
	    save(splitfile,'tr_files','tr_label','te_label','te_files','class','tr_ind','te_ind');
	    
	    [split.train_ind,split.test_ind] = create_cvsplit(tr_label,5);
	    save(strrep(splitfile,'.mat','_cvsplit.mat'),'split');
	    
	end
    end
end