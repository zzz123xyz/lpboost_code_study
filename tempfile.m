function s = tempfile(varargin)

prefix =[];
dir = [];
suffix = [];

for i=1:2:nargin-1
    switch varargin{i}
     case 'p'
      prefix = varargin{i+1};
     case 'd'
      dir = varargin{i+1};
     case 's'
      suffix = varargin{i+1};
     otherwise
      error('no such argument');
    end
end
    
cmd = sprintf('/bin/tempfile');
if numel(dir)
    cmd = sprintf('%s -d %s',cmd,dir);
end
if numel(suffix)
    cmd = sprintf('%s -s %s',cmd,suffix);
end


[ignore,s] = system(cmd);

system(['rm -f ' s]);
s = strrep(s,sprintf('\n'),'');
s = strrep(s,' ','');

% on the cluster the -d switch of tempfile call is ignored
if numel(dir) && numel(strfind(s,dir))==0
    
    ind = findstr(s,'/');
    s = s(ind(end)+1:end);
    if dir(end)=='/'
	s = [dir s];
    else
	s = [dir '/' s];
    end
end

if numel(prefix)
    ind = findstr(s,'/');
    ind = ind(end);
    s = [s(1:ind) prefix s(ind+1:end)];
end


system(['touch ' s]);