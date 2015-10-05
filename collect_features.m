% [xtr,ytr] = collect_features(feat,indx,class,dataset)
%
% loading features of different types
% In: 'feat' : feature
%     'indx' : index of features 
%     'class' : e.g. 'wheelchair'
%     'dataset' : e.g. '101','256'
%
% indSubwindow - index of subwindow over which feature is to be
% computed (all 1000 subwindows are stored in subwindows.mat)
%
% function is pretty messy since it grew over time. Choose an
% example feature and walk through the code to understand it
%
%
% 03/18/09 Peter Gehler (pgehler@googlemail.com)
function [xtr,ytr] = collect_features(feat,filelist,dataset,splitfile,classes,indSubwindow)

switch dataset
 case '101'
  featuredir = '~/projects/caltech/caltech101_features/';
 case '256'
  featuredir = '~/projects/caltech/caltech256_features/';
end

if exist('indSubwindow','var')
    load([get_project_dir,'/subwindows.mat');
else 
    indSubwindow = 0;
end

if isfield(feat,'cellnum')
    totbins = 1;
    l=0;
    while totbins < max(feat.cellnum)
	l = l + 1;
	totbins = totbins + 4^l;
    end
    levs = 0:l;
elseif isfield(feat,'level')
    levs = sort(feat.level);
else
    levs = 0;
end

for i=1:numel(filelist)
    class{i} = strtok(filelist{i},'/');
end


switch feat.type

 case {'v1plus','v1plus_rbf'}
  
  for i=1:numel(filelist)
      fname = sprintf('caltech%s_features/v1plus/%s.v1like_a_plus.mat',dataset,filelist{i});
      load(fname,'data');
      if ~exist('xtr','var'), xtr = zeros(numel(filelist),numel(data),'single'); end
      xtr(i,:) = single(data);
  end
  
 case {'rgsift'}
  for i=1:numel(filelist)
      tmp_x = [];
      for l=1:numel(feat.level)
	  lev = feat.level(l);
	  switch dataset 
	   case '101'
	    outfile = sprintf('/agbs/cluster/chl/caltech_101/rgsift-peter/%s',filelist{i});
	   case '256'
	    classnum = str2num(filelist{i}(1:strfind(filelist{i},'.')-1));
	    outfile = sprintf('/agbs/cluster/chl/Caltech256/rgsift-peter/%03d/%s',classnum,filelist{i}(strfind(filelist{i},'/'):end));
	  end
	  if feat.K==300
	      outfile = strrep(outfile,'.jpg',sprintf('.hist%d',lev));
	  else
	      error('not implemented yet');
	  end
	  xx = bzdlmread(outfile);xx=xx./(sum(xx(:))+eps);
	  tmp_x = [tmp_x,xx];
      end
      xtr(i,:) = tmp_x;
      xtr(i,:) = xtr(i,:)./sum(xtr(i,:)+eps);
      fprintf('%d of %d done\r',i,numel(filelist))
  end
  
  
  %
  % Loading PHOG appearance feature
  %
 case {'phog'}

  if indSubwindow==0
      for i=1:numel(filelist)
	  tmp_x = [];
	  for l=1:numel(feat.level)
	      lev = feat.level(l);
	      outfile = sprintf('caltech%s_features/phog/A%d_K%d/Level%d/%s',dataset,feat.angle,feat.K,lev,filelist{i});
	      tmp_x = [tmp_x,bzdlmread(outfile)];
	  end
	  if ~exist('xtr','var'), xtr = zeros(numel(filelist),numel(tmp_x));end
	  xtr(i,:) = tmp_x;
	  xtr(i,:) = xtr(i,:)./sum(xtr(i,:)+eps);
	  fprintf('%d of %d done\r',i,numel(filelist))
      end
  else
      %
      % The subwindows are already precomputed, 'indSubwindow'
      % indexes into the list
      %
      xtr = zeros(numel(filelist),feat.K);
      for i=1:numel(filelist)
	  outfile = sprintf('caltech%s_features/phog/subwindows/A%d_K%d/%s',dataset,feat.angle,feat.K,filelist{i});
	  tmp_x = bzdlmread(outfile);
	  xtr(i,:) = tmp_x(indSubwindow,:);
	  xtr(i,:) = xtr(i,:)./sum(xtr(i,:)+eps);
	  fprintf('%d of %d done\r',i,numel(filelist))
      end
  end
  
    %
    % Loading PHOG appearance feature, (the old deprectadet way)
    %
 case {'shape','shapen'}
  
  warning off
  addpath code/vgg_phog
  warning on
  
  xtr = [];ytr = [];
  
  if indSubwindow > 0
      
      keyboard
      
  else

      % for all levels...
      for i=1:numel(levs)
	  tmp_feat = feat;
	  tmp_feat.level = levs(i);
	  
	  % ... and all classes ...
	  tmp_x = [];tmp_y = [];
	  for c=1:numel(classes)

	      % ... find the files in this class ...
	      indx = find(strcmp(classes{c},class));

	      if numel(indx)==0
		  continue; 
	      end

	      % ... and load them (in this file the features from
              % ALL images are stored!)
	      featfile = feature_filename(tmp_feat,dataset,classes{c}); 

	      load(featfile,'x','y','fname');
	      
	      % ... extract and store their features ...
	      for j=1:numel(indx)
		  [ignore,ind] = max(strcmp(filelist{indx(j)},fname));
		  tmp_x = [tmp_x;x(ind,:)];	
		  tmp_y = [tmp_y;y(ind)];
	      end
	  end

	  %
	  % normalize each bin individually
	  %
	  if strcmp(feat.type,'shapen')
	      for cn=0:feat.K:size(tmp_x,2)-1
		  indx = cn + (1:feat.K);
		  nrm_x = sum(tmp_x(:,indx),2);
		  indx2 = find(nrm_x~=0);
		  tmp_x(indx2,indx) = tmp_x(indx2,indx)./repmat(nrm_x(indx2),1,feat.K);
	      end
	  end
	  
	  % attach the features ...
	  xtr = [xtr,tmp_x];
	  % ... and store the labels ..
	  ytr = tmp_y;
      end

      % only a number of cells is requested, cut them out
      if isfield(feat,'cellnum')
	  indx = [];
	  for i=1:numel(feat.cellnum)
	      indx = [indx, (feat.cellnum(i)-1)*feat.K+(1:feat.K)];
	  end
	  
	  xtr = xtr(:,indx);
      end
      % normalize all features with positive entries to one
      nrm_x = sum(xtr,2);
      indx = find(nrm_x~=0);
      xtr(indx,:) = xtr(indx,:)./repmat(nrm_x(indx),1,size(xtr,2));;
  end  
  %
  %
  %
 case 'app'
  
  if isfield(feat,'oneForAll')&feat.oneForAll>0
      fdir = sprintf('%scaltech%s_features/dense_bow/oneForAll_nr%d_K%d/',get_project_dir,dataset,feat.oneForAll,feat.K);
  else
      fdir = sprintf('%s/caltech%s_features/dense_bow/splits/',get_project_dir,dataset);
      [foo,split] = strtok(splitfile,'/');
      split = split(2:end);
      split = strrep(split,'.mat','');
      fdir = [fdir,split,'/'];
  end
  
  switch feat.channel
   case 'g'
    suffix = sprintf('_grey.dense_sift.mat');
   case 'c'
    suffix = sprintf('_color.dense_sift.mat');
   case 'colorstacked'
    suffix = sprintf('_colorstacked.dense_sift.mat');
   otherwise
    error(['unknown channel : ''',feat.channel,'''\n']);
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

      if issparse(h), h = full(h); end
      imsize = max(pts);
      
      tmp_x = [];
      tmp_x = sparse(tmp_x);
      if indSubwindow > 0
	  
	  indx = points_in_subwindow(pts,windows_lr(indSubwindow,:),windows_ul(indSubwindow,:));
	  tmp_x = hist(h(indx),1:feat.K);
	  
      elseif isfield(feat,'cellnum')
	  
	  if feat.cellnum == 1 % first level, whole image
	      tmp_x = hist(h,1:feat.K); 
	  else
	      indx = points_in_cell(pts,c1,c2,cell_level);
	      tmp_x = hist(h(indx),1:feat.K);
	  end
      else
	  for j=1:numel(levs)
	      for c1=1:2^levs(j)
		  for c2=1:2^levs(j)
		      indx = points_in_cell(pts,c1,c2,levs(j));
		      tmp_x = [tmp_x,hist(h(indx),1:feat.K)];
		  end
	      end
	  end
      end
      
      if ~exist('xtr','var')
	  try
	      xtr = zeros(numel(filelist),size(tmp_x,2));
	  catch
	      xtr = sparse(numel(filelist),size(tmp_x,2));
	  end
      end
      if ~exist('ytr','var')
	  ytr = zeros(numel(filelist),1);
      end
      
      tmp_x = tmp_x./(eps+sum(tmp_x));
      xtr(i,:) = tmp_x;
      ytr(i,1) = find(strcmp(class{i},classes));
      fprintf('%d of %d done\r',i,numel(filelist));
  end
  xtr = sparse(xtr);
  %
  % Region covariate features
  %
  
 case {'regcov','regcovn','regcovn2','regcovn_rbf'}
  xtr = [];ytr = [];
  
  if isfield(feat,'cellnum')
      indx = feat.cellnum;
  else
      indx = [];
      for j=1:numel(levs)
	  cellnums = sum(4.^[0:(levs(j)-1)])+ (1:4.^levs(j));
	  indx = [indx,cellnums];
      end
  end
  
  featdir = [featuredir,strrep(feat.type,'_rbf',''),'/'];
  for i=1:numel(filelist)
      T = bzdlmread([featdir,filelist{i},'.txt']);
      
      T = vectorize(T(indx,:));
      if ~numel(xtr)
	  xtr = zeros(numel(filelist),numel(T));
      end
      xtr(i,:) = T(:);

      if nargout > 1
	  ytr(i,1) = find(strcmp(class{i},classes));
      end
  end
  
 case 'lbp'
  xtr = [];
  ytr = [];
  
  indx = comp_indx(feat);
  
  featdir = [featuredir,'lbp/'];
  for i=1:numel(filelist)
      T = bzdlmread([featdir,filelist{i},'.txt']);
      T = vectorize(T(indx,:));
      if ~numel(xtr)
	  xtr = zeros(numel(filelist),numel(T));
      end
      T = T./sum(T+eps);
      xtr(i,:) = T;
      if nargout > 1
	  ytr(i,1) = find(strcmp(class{i},classes));
      end
  end
  
 otherwise
  error('such feature type is not known');
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
