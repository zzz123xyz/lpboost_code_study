function classifierfile = generate_classifierfname(splitfile,method,combnum,classnr,C)

load_combinations;
featnums = combination{combnum};

if strfind(splitfile,'101')>0
    dataset = '101';
elseif strfind(splitfile,'256')>0
    dataset = '256';
else
    error('could not identify dataset')
end

fname = strrep(splitfile,'splits/',['caltech',dataset,'_classifier/']);
fname = [strrep(fname,'.mat','/'),method,'/'];
str = sprintf('f%d_',featnums);str(end) = [];
classifierdir = [fname,str];
if ~exist(classifierdir,'dir'), system(['mkdir -p ',classifierdir]);end
if classnr>0
    classifierfile = sprintf('%s/fixedC%d_class%d.mat',classifierdir,C,classnr);
else
    classifierfile = sprintf('%s/fixedC%d.mat',classifierdir,C);
end
