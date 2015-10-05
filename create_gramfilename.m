function fname = create_gramfilename(splitfile,featnum)

fdir = strrep(splitfile,'splits/','gram_matrices/');
fdir = strrep(fdir,'.mat','');
if ~exist(fdir,'dir'), system(['mkdir -p ',fdir]);end

prefix = strrep(splitfile,'.mat','');
prefix = strrep(prefix,'splits/','');

fname = [fdir,'/',prefix,'_feat',num2str(featnum),'.mat'];
