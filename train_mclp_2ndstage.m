% train_mclp_2ndstage(splitfile,combnum,weight_sharing)
%
% where
% 'splitfile' - definition of training/test images
% 'combnum' - number of combination  (load_combination.m)
% 'weight_sharing' - 1:LP-beta, 0:LP-B
% 
% checks whether the MCLP cross validation was done to determine an
% optimal nu. If so this script writes a file in 'mclp_jobs/' to compute
% the final combination weights.
%
% Peter Gehler

function train_mclp_2ndstage(splitfile,combnum,weight_sharing)

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
preddir = ['/scratch_net/biwidl07/projects/caltech/mclp_score/'];
preddir = [preddir,str,'/'];

%
% create this file after everything is done
%
if weight_sharing==0
    done_file = [preddir,'done_combination',num2str(combnum),'_2ndstage_lpB.mat'];	  
else
    done_file = [preddir,'done_combination',num2str(combnum),'_2ndstage_lpbeta.mat'];	  
end


%
% check if this feature was processed already
%
if exist(done_file,'file')
    fprintf('this combination was already computed!\n');
    fprintf('delete ''%s'' for redo\n',done_file);
    return
end

load(splitfile);
load(strrep(splitfile,'.mat','_cvsplit.mat'),'split');

str = strrep(strrep(splitfile,'splits/',''),'.mat','');
combdir = ['/scratch_net/biwidl07/projects/caltech/mclp_score/',str];
combdir = [combdir,'/combination',num2str(combnum)];

chainfile = ['/scratch_net/biwidl07/projects/caltech/mclp_jobs/',str];
if weight_sharing==0, chainfile = [chainfile,'_combination',num2str(combnum),'_2ndstage_lpB.txt'];
else, chainfile = [chainfile,'_combination',num2str(combnum),'_2ndstage_lpbeta.txt'];end

% all done? 
for n=1:numel(nus)
    for f=1:numel(split.train_ind)
	crossv_file = [combdir,'/fold',num2str(f),'.txt'];
	outfile = [combdir,'/fold',num2str(f),'_',num2str(nus(n)),'_',num2str(weight_sharing),'.txt'];
	if ~exist(outfile,'file')
	    fprintf(['outfile ''',outfile,''' does not exist\n'])
	    return;
	end
    end
end

fprintf('reading in scores...');
clear score
for fn=1:numel(featnums)
    score(:,:,fn) = load_mclp_score(splitfile,tr_files,featnums(fn));
    fprintf('\n%d of %d features read in\n\n',fn,numel(featnums));
		     % alloc mem
		     if ndims(score)==2 & numel(featnums)>1
			 score(:,:,2:numel(featnums)) = 0;
		     end
end
fprintf('done\n');

fprintf('computing cross validation error...');
for n=1:numel(nus)
    clear ypred;
    for f=1:numel(split.train_ind)
	train_ind = split.train_ind{f};
	test_ind = split.test_ind{f};
	outfile = [combdir,'/fold',num2str(f),'_',num2str(nus(n)),'_',num2str(weight_sharing),'.txt'];

	A = bzdlmread(outfile);
	ypred(test_ind) = mclp_predict(score(test_ind,:,:),A');
    end
    err(1,n) = avg_class_err(tr_label,ypred);
end
err(1,:) = err(1,:) + 1e-9*randn(size(err(1,:)));
bestnu(1) = nus(find(err(1,:)==min(err(1,:))));
fprintf('done\n');

%
% now get the best values for the regularization parameter nu
%

if weight_sharing==1,fprintf('lpbeta: ');
else,fprintf('lpb: ');end
fprintf('nu=%.4f,err=%.4f\n',bestnu,min(err));

%
% write a training file for mclp training of final combination
%
if weight_sharing==0,trainfile = [combdir,'/train_2ndstage_lpB.txt'];
else, trainfile = [combdir,'/train_2ndstage_lpbeta.txt'];end

fid = fopen(trainfile,'w');
for i=1:numel(tr_files)
    fprintf(fid,'%d',tr_label(i)-1);
    
    for fn=1:numel(featnums)
	fname = [preddir,'feature',num2str(featnums(fn)),'/'];
	fname = [fname,tr_files{i},'.txt'];
	fprintf(fid,' %s',fname);
    end
    
    if i<numel(tr_files), fprintf(fid,'\n');end
end
fclose(fid);


%
% write the file to be submitted
%
fid = fopen(chainfile,'w');

nu = bestnu;
mclpbin = ['/scratch_net/biwidl07/projects/caltech/code/mclp/mclp_script --solver mosek --weight_sharing ',num2str(weight_sharing)];
outfile = [combdir,'/2ndstage_',num2str(weight_sharing),'.txt'];
mclpbin = [mclpbin,' --nu ',num2str(nu)];
mclpbin = [mclpbin,' --train ',trainfile];
mclpbin = [mclpbin,' --output ',outfile];
fprintf(fid,[mclpbin,'\n']);
fclose(fid);

fprintf('done, now submit chainfile ''%s''\n',chainfile);
save(done_file,'bestnu','err');
