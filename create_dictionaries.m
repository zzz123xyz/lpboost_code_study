% Cx = create_dictionaries(K,splitfile)
%
% creating the dictionaries for the training/test splits on densely
% sampled appearance features. Does not override existing
% dictionaries for split specified in 'splitfile'! Files will be
% stored in 'dictionaries/...'
%
% IN: 
%  'K' : number of cluster centers
%  'splitfile' - storage point of training files and labels
% OUT: 
%  'Cx' - cluster centers
%
% after this is done use 'create_bow' to assign the features
%
function Cx = create_dictionaries(K,splitfile,type,dataset);

MAXFEATSPERIM = 5000;
MAXIMSPERCAT = 5;
KMEANS_RESTARTS = 0;
MAXTOTFEATS = 500000;

% adding kmeans dir
warning off
addpath code/mpi_kmeans
warning on

% when submitting to the cluster, setting the rand seed to
% 100*clock is not sufficient to get distinct random
% numbers. Therefore I sampled some beforehand
load('randseeds.mat');
rand('twister',seeds(splitfile));

%switch version('-release')
% case '2008a',rand('twister',sum(100*clock))
% case '2008b',RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
%end

%
% DICTIONARY ONLY USING TRAINING IMAGES
% use the predefined split 'splitfile' to load the training data
% for this split. The codebook will be build using only these files
%
if isstr(splitfile)

    if strfind(splitfile,'101')>0
	assert(strcmp(dataset,'101'));
    elseif strfind(splitfile,'256')>0
	assert(strcmp(dataset,'256'));
    else
	error('could not identify dataset')
    end
    
    if ~exist(splitfile,'file')
	error('no such split created yet');
    end

    % loading the training files
    load(splitfile,'tr_files','tr_label');

    ids = sort(unique(tr_label));


    % file where to save the dictionary in
    filestr = strrep(splitfile,'splits/','');
    filestr = strrep(filestr,'.mat','');
    dataset = sscanf(filestr,'caltech%d_');
    dictfile = sprintf('/agbs/cluster/pgehler/projects/caltech/dictionaries/%s_%s_K%d.mat',filestr,type,K);

else
    
    %
    % DICTIONARY USING ALL IMAGES
    % if splitfile is a number we will simply draw files at random
    % from the dataset and build a codebook with them. This should
    % not alter the experimentes too much. However this is a lot
    % easier to average over. I created about 10 dictionaries
    %
    tr_files = textread(['caltech',dataset,'_filelist'],'%s\n');

    flist = strrep(tr_files,['caltech',dataset,'_images/'],'');
    for i=1:numel(flist)
	t = strfind(flist{i},'/');
	class{i} = flist{i}(1:t-1);
    end
    classes = unique(class);
    for i=1:numel(class);
	tr_label(i,1) = find(strcmp(class{i},classes));
    end
    assert(all(tr_label>0));

    dictfile = sprintf('/agbs/cluster/pgehler/projects/caltech/dictionaries/oneForAll_nr%d/caltech%s_%s_K%d.mat',splitfile,dataset,type,K);

    ids = sort(unique(tr_label));
    
end
clear splitfile


dictfile

featdir = sprintf('caltech%s_features/dense/',dataset);

dict_files = [];
for i=1:numel(ids)
    ind = find(tr_label==ids(i));
    shuff = randperm(numel(ind));
    
    ind = ind(shuff);
    
    for k=1:min(MAXIMSPERCAT,numel(ind))
	dict_files{end+1} = strrep(tr_files{ind(k)},['caltech',dataset,'_images/'],'');
    end
   
end



if exist(dictfile,'file')
    warning(['this dictionary ''',dictfile,'''was already created\n']);
    return;
end

%%%%
%
% dictF_files{i}
%
%%%%
if (MAXFEATSPERIM * numel(dict_files))>MAXTOTFEATS
    fprintf('reducing the number of features per image from %d ',MAXFEATSPERIM);
    MAXFEATSPERIM = ceil(MAXTOTFEATS/numel(dict_files));
    fprintf('to %d\n',MAXFEATSPERIM);
end

fprintf('collecting the features for ''%s''\n',type);
switch type
 case {'color','grey'}
  feats = zeros(numel(dict_files)*MAXFEATSPERIM,128);
case 'colorstacked'
  feats = zeros(numel(dict_files)*MAXFEATSPERIM,3*128);
 otherwise
  error('unknoown type');
end

pt = 0;
for i=1:numel(dict_files)
    switch type
     case 'grey'
      featfile = sprintf('%s%s_grey.dense_sift',featdir,dict_files{i});
      [pts,scl,f] = load_points(featfile);
     case 'color'
      f = [];
      channels = {'h','s','v'};
      for c=1:numel(channels)
	  featfile = sprintf('%s%s_%s.dense_sift',featdir,dict_files{i},channels{c});
	  [pts,scl,tmp_f] = load_points(featfile);
	  f = [f;tmp_f];
      end
     case 'colorstacked'
      f = [];
      channels = {'h','s','v'};
      for c=1:numel(channels)
	  featfile = sprintf('%s%s_%s.dense_sift',featdir,dict_files{i},channels{c});
	  [pts,scl,tmp_f] = load_points(featfile);
	  f = [f,tmp_f];
      end
     otherwise
      error('unknown type');
    end
    shuff = randperm(size(f,1));
    shuff = shuff(1:min(MAXFEATSPERIM,numel(shuff)));
    feats(pt+(1:numel(shuff)),:) = f(shuff,:);
    pt = pt + numel(shuff);
    fprintf('%.2f percent done\r',100*i/numel(dict_files));

end
feats(pt+1:end,:) = [];
fprintf('all done\n');

shuff = randperm(size(feats,1));
shuff = shuff(1:min(MAXTOTFEATS,numel(shuff)));
feats = feats(shuff,:);

fprintf('features of size %dx%d\n',size(feats,1),size(feats,2));
fprintf('starting KMEANS K=%d, clustering (%d restarts) ...\n',K,KMEANS_RESTARTS);
Cx = mpi_kmeans(feats',K,0,KMEANS_RESTARTS);
fprintf('done\n');

fprintf('saving in ''%s''\n',dictfile);
save(dictfile,'Cx','dict_files');



