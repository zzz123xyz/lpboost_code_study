% str = explain_feature(f)
%
% computes a description string 'str' for feature 'f' 
% 'f' can be either a struct or a number
function str = explain_feature(f)

if isnumeric(f);
    featnum = f;
    clear f;
    load_features;
    feat = f{featnum};
    clear f;
    f = feat; 
    clear feat;
end


str = f.type;

switch f.type
 case {'shape','shapen'}
  if isfield(f,'angle')
      str = sprintf('%s_Angle%d',str,f.angle);
  end
  if isfield(f,'angle')
      str = sprintf('%s_Bin%d',str,f.K);
  end
  if isfield(f,'nSubwindows')
      str = sprintf('%s_nSubwindows%d',str,f.nSubwindows);
  end

 case 'app'
  if isfield(f,'channel')
      str = sprintf('%s_Channel%s',str,f.channel);
  end
  if isfield(f,'K')
      str = sprintf('%s_K%d',str,f.K);
  end

  if isfield(f,'nSubwindows')
      str = sprintf('%s_nSubwindows%d',str,f.nSubwindows);
  end

end

if isfield(f,'cellnum')
    str = sprintf('%s_CellNum%d',str,f.cellnum);
elseif isfield(f,'level')
    for p=1:numel(f.level)
	str = sprintf('%s_Level%d',str,f.level(p));
    end
end
