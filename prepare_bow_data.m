% [xtr,ytr] = collect_features(feat,indx,class,dataset)
%
% loading features of different types
% In: 'feat' : feature
%     'indx' : index of features 
%     'class' : e.g. 'wheelchair'
%     'dataset' : e.g. '101','256'

function [xtr,ytr] = prepare_bow_data(dataset,splitfile,classes)

switch dataset
 case '101'
  featuredir = '~/caltech/caltech101_features/';
 case '256'
  featuredir = '~/caltech/caltech256_features/';
end

if isfield(feat,'cellnum')
    totbins = 1;
    l=0;
    while totbins < max(feat.cellnum)
	l = l + 1;
	totbins = totbins + 4^l;
    end
    levs = 0:l;
else
    levs = sort(feat.level);
end

for i=1:numel(filelist)
    class{i} = strtok(filelist{i},'/');
end



  

fdir = sprintf('/agbs/cluster/pgehler/caltech/caltech%s_features/dense_bow/splits/',dataset);
[foo,split] = strtok(splitfile,'/');
split = split(2:end);
split = strrep(split,'.mat','');


fdir = [fdir,split,'/'];
switch feat.channel
 case 'g'
  suffix = sprintf('_grey.dense_sift.mat');
 case 'c'
  suffix = sprintf('_color.dense_sift.mat');
end

if isfield(feat,'cellnum') && feat.cellnum > 1
    % most probably this can be done so much easier :)

    % find the level where the cell is located
    cell_level = 0;
    while 1
	if feat.cellnum <= sum(4.^[0:cell_level])
	    break
	end
	cell_level = cell_level + 1;
    end

    % find the x,y coordinates of the cell
    cell_in_lev = feat.cellnum - sum(4.^[0:cell_level-1]);
    found = 0;
    for c1=1:2^cell_level
	for c2=1:2^cell_level
	    if ((c1-1)*2^cell_level+c2)==cell_in_lev
		found = 1;
		break;
	    end
	end
	if found, break; end
    end
end

for i=1:numel(filelist)
    load([fdir,filelist{i},suffix],'h','pts');

    tic
    if issparse(h), h = full(h); end
    imsize = max(pts);
    
    tmp_x = [];
    tmp_x = sparse(tmp_x);
    levs = 0:3;
	for j=1:numel(levs)
	    for c1=1:2^levs(j)
		for c2=1:2^levs(j)
		    indx = points_in_cell(pts,c1,c2,levs(j));
		    tmp_x = [tmp_x,hist(h(indx),1:300)];
		end
	    end
	end
    toc
    if ~exist('xtr','var')
	xtr = sparse(numel(filelist),size(tmp_x,2));
    end
    if ~exist('ytr','var')
	ytr = zeros(numel(filelist),1);
    end
    
    tmp_x = tmp_x./sum(tmp_x);
    xtr(i,:) = tmp_x;
    ytr(i,1) = find(strcmp(class{i},classes));
end


function a=vectorize(a)
a=a(:);

function indx=comp_indx(feat)

if isfield(feat,'cellnum')
    indx = feat.cellnum;
else
    levs = sort(feat.level);
    indx = [];
    for j=1:numel(levs)
	cellnums = sum(4.^[0:(levs(j)-1)])+ (1:4.^levs(j));
	indx = [indx,cellnums];
    end
end
