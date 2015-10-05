% a script that transforms the kernel matrices computed by the vl_feat
% toolbox to the format used by my software
%
%

%nTrain = 15;
nTest = 50;
%nSplit = 2;

splitdir = '/scratch_net/biwidl07/projects/caltech/splits';
splitfile = sprintf('%s/caltech101_nTrain%d_nTest%d_N%d.mat',splitdir,nTrain,nTest,nSplit);


load(splitfile,'te_label','tr_label');
nTrainPts = numel(tr_label);
nTestPts = numel(te_label);

kerndir = sprintf('/scratch_net/biwidl07/projects/vgg-mkl/vgg-mkl-class/data/cal-iccv-%d-%d/train/COMMON/baseline-avg/ker/',nTrain,nSplit);
savedir = sprintf('/scratch_net/biwidl07/projects/caltech/gram_matrices/caltech101_nTrain%d_nTest50_N%d/',nTrain,nSplit);

savedir

% Geometric Blur

if (1)
tr_savefile = sprintf('%scaltech101_nTrain%d_nTest50_N%d_feat1000.mat',savedir,nTrain,nSplit);
te_savefile = sprintf('%scaltech101_nTrain%d_nTest50_N%d_test_feat1000.mat',savedir,nTrain,nSplit);

if ~exist(tr_savefile,'file') || ~exist(te_savefile,'file')

    gb_train_file = [kerndir,'el2_gb.mat'];
    gb_test_file = [kerndir,'test-el2_gb.mat'];

    if ~exist(gb_train_file,'file') || ~exist(gb_test_file,'file')
	gb_train_file
	gb_test_file
	error('kern matrix not yet computed');
    end

    load(gb_train_file,'matrix');
    [n1,n2] = size(matrix);

    kernparam = 0;
    K = matrix(1:nTrainPts,1:nTrainPts);
    save(tr_savefile,'K','kernparam');

    clear matrix;
    load(gb_test_file,'matrix');
    [n1,n2] = size(matrix);

    assert(size(matrix,2)==nTestPts);
    K = matrix(1:nTrainPts,1:nTestPts)';
    save(te_savefile,'K','kernparam');
end
end

% PHOW

pyrLevs = 3;
feats = {'phowColor','phowGray'}
for fnum = 1:length(feats)

    for L=0:pyrLevs-1

	featnum = 1001 + L + pyrLevs*(fnum-1)
	
	tr_savefile = sprintf('%scaltech101_nTrain%d_nTest50_N%d_feat%d.mat',savedir,nTrain,nSplit,featnum);
	te_savefile = sprintf('%scaltech101_nTrain%d_nTest50_N%d_test_feat%d.mat',savedir,nTrain,nSplit,featnum);

	if ~exist(tr_savefile,'file') || ~exist(te_savefile,'file')

	    train_file = [kerndir,'echi2_',feats{fnum},'_L',num2str(L),'.mat'];
	    test_file = [kerndir,'test-echi2_',feats{fnum},'_L',num2str(L),'.mat'];

	    if ~exist(train_file,'file') || ~exist(test_file,'file')
		error('kern matrix not yet computed');
	    end
	    
	    load(train_file,'matrix');
	    [n1,n2] = size(matrix);

	    kernparam = 0;
	    K = matrix(1:nTrainPts,1:nTrainPts);
	    save(tr_savefile,'K','kernparam');

	    
	    load(test_file,'matrix');
	    [n1,n2] = size(matrix);

	    K = matrix(1:nTrainPts,1:nTestPts)';
	    save(te_savefile,'K','kernparam');
	    
	end
    end
end

assert(featnum == 1006)
%%SSIM 
pyrLevs = 3;

for L=1:pyrLevs-1

    featnum = 1006 + L;
    
    tr_savefile = sprintf('%scaltech101_nTrain%d_nTest50_N%d_feat%d.mat',savedir,nTrain,nSplit,featnum);
    te_savefile = sprintf('%scaltech101_nTrain%d_nTest50_N%d_test_feat%d.mat',savedir,nTrain,nSplit,featnum);

    if ~exist(tr_savefile,'file') || ~exist(te_savefile,'file')

	train_file = [kerndir,'echi2_ssim_L',num2str(L),'.mat'];
	test_file = [kerndir,'test-echi2_ssim_L',num2str(L),'.mat'];

	if ~exist(train_file,'file') || ~exist(test_file,'file')
	    error('kern matrix not yet computed');
	end
	
	load(train_file,'matrix');
	[n1,n2] = size(matrix);

	kernparam = 0;
	K = matrix(1:nTrainPts,1:nTrainPts);
	save(tr_savefile,'K','kernparam');

	clear matrix
	load(test_file,'matrix');
	[n1,n2] = size(matrix);

	K = matrix(1:nTrainPts,1:nTestPts)';
	save(te_savefile,'K','kernparam');
	
    end
end
