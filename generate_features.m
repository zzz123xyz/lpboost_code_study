% [xtr] = generate_features(feat,filelist,dataset)
%
% loading features of different types
% In: 'feat' : feature
%     'indx' : index of features 
%     'class' : e.g. 'wheelchair'
%     'dataset' : e.g. '101','256'

function [xtr] = generate_features(feat,filelist,dataset)

switch dataset
 case '101'
  featuredir = '~/projects/caltech/caltech101_features/';
  imdir = '~/projects/caltech/caltech101/';
 case '256'
  featuredir = '~/projects/caltech/caltech256_features/';
  imdir = '~/projects/caltech/caltech256/';
end

switch feat.type
    %
    % Loading PHOG appearance feature
    %
 case 'shape'
  
  warning off
  addpath ~/software/vgg_phog
  warning on

  levs = sort(feat.level);
  fdir = ([featuredir 'phog/']);
  xtr = [];ytr = [];

  if numel(levs) > 1
      error('only one level allowed');
  end
  
  xtr = zeros(numel(filelist),feat.K*4^levs);
  for k=1:numel(filelist)
      switch feat.angle
       case 180
	load([fdir,filelist{k},'.mat'],'A180','E','Gr');
	xtr(k,:) = vgg_phog_compute(A180,E,Gr,180,feat.K,levs);
       case 360
	load([fdir,filelist{k},'.mat'],'A360','E','Gr');
	xtr(k,:) = vgg_phog_compute(A360,E,Gr,360,feat.K,levs);
       otherwise
	error('invalid argument for angle');
      end
  end

  %
  % variant of shape: we compute the features for all subwindows in
  % the file 'subwindows.mat'
  %
 case 'randomsubwindows_shape'
  load('subwindows.mat');
  
  warning off; addpath ~/software/vgg_phog;  warning on
  levs = 0;
  fdir = ([featuredir 'phog/']);

  
  xtr = zeros(numel(filelist),size(windows_lr,1),feat.K);
  
  for k=1:numel(filelist)

      [A180,A360,E,Gr] = vgg_phog_preprocess([imdir filelist{k}]);
      
      for n=1:size(windows_lr,1)
	  roi = [ceil(windows_ul(n,1) .* size(A360,1)),ceil(windows_lr(n,1)*size(A360,1)),ceil(windows_ul(n,2)*size(A360,2)),ceil(windows_lr(n,2)*size(A360,2))]';
	  roi(2) = min(roi(2),size(A360,1));
	  roi(4) = min(roi(4),size(A360,2));
	  roi(roi==0)=1;
	  switch feat.angle
	   case 180
	    xtr(k,n,:) = vgg_phog_compute(A180,E,Gr,180,feat.K,0,roi);
	   case 360
	    xtr(k,n,:) = vgg_phog_compute(A360,E,Gr,360,feat.K,0,roi);
	   otherwise
	    error('invalid argument for angle');
	  end
      end
      
      fprintf('%d of %d done\r',k,numel(filelist));
  end

  %
  %
  %
 case 'appgrey'
  
 case 'appcolor'

 otherwise
  error('such feature type is not known');
end



% if (0)  
% %case 'app'
%   fdir = ([ex.featuredir '/dense_bow/']);
%   suffix = sprintf('_grey.dense_sift.mat');
  
%   if classnum
%       mem = find(ex.tr_label==classnum);
%       if numel(mem) == 0
% 	  error('no feature descriptors found');
%       end
%   else
%       mem = 1:numel(filelist);
%   end
  

%   for k=1:numel(mem)
%       load([fdir filelist{mem(k)} suffix],'h','pts')

%       tmp_h = hist(h,1:300);
      
%       if ~ex.no_hist_normalize
% 	  h = tmp_h./sum(tmp_h);
%       else
% 	  h = tmp_h;
%       end

%       x(k,:) = h;
      
%       if classnum
% 	  y(k,1) = classnum;
%       else
% 	  str = filelist{mem(k)};
% 	  class = str(1:(strfind(str,'/')-1));
% 	  ind = find(strcmp(ex.class,class));
% 	  if numel(ind)~=1
% 	      error('no class found');
% 	  end
	  
% 	  y(k,1) = ind;
%       end
%   end

  

%  case 'shapeapp'
% end