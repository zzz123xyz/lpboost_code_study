% score = load_mclp_score(splitfile,filenames,featnum)
%
% Peter Gehler
function score = load_mclp_score(splitfile,filenames,featnum)


str = strrep(strrep(splitfile,'splits/',''),'.mat','');
preddir = ['/scratch_net/biwidl07/projects/caltech/mclp_score/'];
preddir = [preddir,str,'/feature',num2str(featnum),'/'];

for j=1:numel(filenames)
    fname = [preddir,filenames{j},'.txt'];
    %t= bzdlmread(fname);
    t= load(fname);
    if numel(t)==0, error(['error reading file ',fname,'''']); end
    if ~exist('score','var'), score = zeros(numel(filenames),size(t,2));end
    score(j,:) = t;
    if mod(j,10)==0,fprintf('%d of %d done\r',j,numel(filenames));end
end

