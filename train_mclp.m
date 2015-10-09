% train_mclp(splitfile,combnum,weight_sharing)
%
% where 
% 'splitfile' - definition of training/test files
% 'combnum' - number of combination to train for (load_combinations.m)
% 'weight_sharing' - 1: LP-beta, 0:LP-B
%
% checks whether all participating weak learners are present and
% subsequently writes a file in the directory 'mclp_jobs/'
%
% Peter Gehler
function train_mclp(splitfile,combnum,weight_sharing)

%
% check if the combination has to be computed
%
load_combinations;
featnums = combination{combnum};

load_settings;

%
% creating directory to write predictions in 
%
str = strrep(strrep(splitfile,'splits/',''),'.mat','');
preddir = ['mclp_score/'];
preddir = [preddir,str,'/'];

%
% create this file at the end of this script
%
if weight_sharing==1
    done_file = [preddir,'done_combination',num2str(combnum),'_lpbeta.mat'];	  
else
    done_file = [preddir,'done_combination',num2str(combnum),'_lpB.mat'];	  
end

%
% check if this feature was processed already
%
if exist(done_file,'file')
    fprintf('this combination was already computed!\n');
    fprintf('delete ''%s'' for redo\n',done_file);
    return
end

%
% split the training data into different folds to search for the
% best nu
%
load(splitfile);
cvsplitfile = strrep(splitfile,'.mat','_cvsplit.mat');
if ~exist(cvsplitfile,'file')
    create_mclp_cvsplit(splitfile);
end
load(cvsplitfile,'split');

str = strrep(strrep(splitfile,'splits/',''),'.mat','');
combdir = ['mclp_score/',str];
combdir = [combdir,'/combination',num2str(combnum)];
system(['mkdir -p ',combdir]);

chainfile = ['mclp_jobs/',str];
chainfile = [chainfile,'_combination',num2str(combnum),'.txt'];

if weight_sharing==1
    chainfile = strrep(chainfile,'.txt','_lpbeta.txt');
else
    chainfile = strrep(chainfile,'.txt','_lpB.txt');
end

for f=1:numel(split.test_ind)
    train_ind = split.train_ind{f};
    crossv_file = [combdir,'/fold',num2str(f),'.txt'];
    if exist(crossv_file,'file'),continue;  end
    fid = fopen(crossv_file,'w');
    for i=1:numel(train_ind)
	fprintf(fid,'%d',tr_label(train_ind(i))-1);
	
	for fn=1:numel(featnums)
	    fname = [preddir,'feature',num2str(featnums(fn)),'/'];
	    fname = [fname,tr_files{train_ind(i)},'.txt'];
	    fprintf(fid,' %s',fname);
	end
	
	if i<numel(train_ind), fprintf(fid,'\n');end
    end
    fclose(fid);
end


fprintf('writing a file for chain submitting jobs...');
fid = fopen(chainfile,'w');
if fid<0, error('could not open file');end
for n=1:numel(nus)
    for f=1:numel(split.train_ind)
	mclpbin = ['code/mclp/mclp_script --solver mosek --weight_sharing ',num2str(weight_sharing)];
	crossv_file = [combdir,'/fold',num2str(f),'.txt'];
	outfile = [combdir,'/fold',num2str(f),'_',num2str(nus(n)),'_',num2str(weight_sharing),'.txt'];
	mclpbin = [mclpbin,' --nu ',num2str(nus(n))];
	mclpbin = [mclpbin,' --train ',crossv_file];
	mclpbin = [mclpbin,' --output ',outfile];
	fprintf(fid,[mclpbin,'\n']);
    end
end
fclose(fid);
fprintf('done\n');

system(['touch ',done_file]);
fprintf(['now submit the chainfile ''',chainfile,'''\n']);

