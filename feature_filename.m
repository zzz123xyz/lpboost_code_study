% fname = feature_filename(f,dataset,class)
%
% generate a unique filename where the features will be stored in.
% In: 'f' : feature
%     'dataset': e.g. '101','256',...
%     'class' : eg. 'wild_cat'

function fname = feature_filename(f,dataset,class)


switch f.type
 case {'shape','shapen'}
  fname = sprintf('data/%s_%s_shape_K%d_A%d',dataset,class,f.K,f.angle);
  levs = sort(f.level);
  for i=1:numel(levs)
      fname = sprintf('%s_l%d',fname,levs(i));
  end
  fname = sprintf('%s.mat',fname);
  
 case {'randomsubwindows_shape','randomsubwindows_shapen'}
  fname = sprintf('data/%s_%s_shape_K%d_A%d',dataset,class,f.K,f.angle);
  fname = sprintf('%s_%dsubwindows.mat',fname,f.nSubwindows);
 case 'app'
end
