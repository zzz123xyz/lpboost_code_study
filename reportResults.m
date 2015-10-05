%
% print the results for Caltech101 and Caltech256
%
% Peter Gehler

clear all

reportCaltech101 = 1;
reportCaltech256 = 1;

combinations101 =  [11,40,27:33,39,41];
combinations101 =  [39,43,44];%[30,32,33,39,43,44];

combinations256 =  [11,30,32,39];
combinations256 =  [39];

nofSplits101 = 1:5;
nofSplits256 = 1;

nTrainPoints101 = 5:5:30; %15; %5:5:30;
nTrainPoints256 = [5:5:30,40,50];

if (reportCaltech101)
    fprintf('\n\nCALTECH101 !!!\n');
    
    if (0)
	results;
	for i=1:numel(featnum)
	    f=featnum(i);
	    for nTrain=5:5:30
		for splitnum=1:nofSplits101
		    splitfile = sprintf('splits/caltech101_nTrain%d_nTest50_N%d.mat',nTrain,splitnum);
		    err(f,nTrain,splitnum) = train_and_predict_single(splitfile,f);
		    %if ~isinf(err),fprintf('\tfeature %d: acc = %2.1f\n',f,100*(1-err));end
		end
	    end
	    fprintf('%s: ',str{i});
	    for nTrain=5:5:30
		thisErr = err(f,nTrain,:);thisErr(isinf(thisErr))=[];
		stdErr = std(thisErr);
		fprintf('%0.1f +- %.01f ',100* (1-mean(thisErr)),100*stdErr);
	    end
	    fprintf('\n');
	end
    end

    for combnum=combinations101
	fprintf('\n');
	for nTrain=nTrainPoints101
	    for splitnum=1:nofSplits101
		splitfile = sprintf('splits/caltech101_nTrain%d_nTest50_N%d.mat',nTrain,splitnum);
		err_varma(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'varma',1000);
		err_silp(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'silp',1000);
		err_product(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'product',1000);
		err_avg(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'average',1000);
		err_linearMC1(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'linear_multiclass',1);
		err_linearMC01(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'linear_multiclass',0.1);
		err_linear_logistic(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'linear_empkernel_logistic',0.1);
		err_lpb(combnum,nTrain,splitnum) = test_mclp_2ndstage(splitfile,combnum,0);
		err_lpbeta(combnum,nTrain,splitnum) = test_mclp_2ndstage(splitfile,combnum,1);
		err_lp_avg(combnum,nTrain,splitnum) = test_mclp_2ndstage_avg(splitfile,combnum);
	    
	    end
	end

	fprintf('combination %d: %s product:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_product(combnum,nTrainPoints101,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s average:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_avg(combnum,nTrainPoints101,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s linear logistic:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_linear_logistic(combnum,nTrainPoints101,:));thisErr(:,any(isinf(thisErr)))=[];
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s varma:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_varma(combnum,nTrainPoints101,:));thisErr(:,any(isinf(thisErr)))=[];
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s silp:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_silp(combnum,nTrainPoints101,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s LP-avg:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_lp_avg(combnum,nTrainPoints101,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s LP-beta:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_lpbeta(combnum,nTrainPoints101,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s LP-B:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_lpb(combnum,nTrainPoints101,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');


    end
end

clear thisErr splitfile
clear err*

if (reportCaltech256)

    fprintf('\n\nCALTECH256 !!!\n');
    if (0)
	results;
	for i=1:numel(featnum)
	    f=featnum(i);
	    for nTrain=nTrainPoints256
		for splitnum=1:nofSplits256
		    splitfile = sprintf('splits/caltech256_nTrain%d_nTest25_N%d.mat',nTrain,splitnum);
		    err(f,nTrain,splitnum) = train_and_predict_single(splitfile,f);
		    %if ~isinf(err),fprintf('\tfeature %d: acc = %2.1f\n',f,100*(1-err));end
		end
	    end
	    fprintf('%s: ',str{i});
	    for nTrain=nTrainPoints256
		thisErr = err(f,nTrain,:);thisErr(isinf(thisErr))=[];
		stdErr = std(thisErr);
		fprintf('%0.1f +- %.01f ',100* (1-mean(thisErr)),100*stdErr);
	    end
	    fprintf('\n');
	end
    end
    
    for combnum=combinations256
	
	for nTrain=nTrainPoints256
	    for splitnum=1
		splitfile = sprintf('splits/caltech256_nTrain%d_nTest25_N%d.mat',nTrain,splitnum);
		err_varma(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'varma',1000);
		err_silp(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'silp',1000);
		err_product(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'product',1000);
		err_avg(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'average',1000);
		err_linearMC1(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'linear_multiclass',1);
		err_linearMC01(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'linear_multiclass',0.1);
		%err_lpb(combnum,nTrain,splitnum) = test_mclp_2ndstage(splitfile,combnum,0);
		err_lpbeta(combnum,nTrain,splitnum) = test_mclp_2ndstage(splitfile,combnum,1);

		err_250_varma(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'varma',1000);
		err_250_silp(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'silp',1000);
		err_250_product(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'product',1000);
		err_250_avg(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'average',1000);
		err_linearMC1(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'linear_multiclass',1);
		err_linearMC01(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'linear_multiclass',0.1);
		err_250_lpbeta(combnum,nTrain,splitnum) = test_mclp_2ndstage_caltech250(splitfile,combnum,1);
	    end
	end
	
	
	
	fprintf('combination %d: %s varma:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_varma(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s silp:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_silp(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s product:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_product(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s average:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_avg(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	%	fprintf('combination %d: %s LP-B:  ',combnum,explain_combination(combnum));
	%	thisErr = squeeze(err_lpb(combnum,nTrainPoints256,:));
	%	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	%	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	%	fprintf('\n');
	
	fprintf('combination %d: %s LP-beta:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_lpbeta(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	
	fprintf('\n\nTesting only on Categories 1-250\n');
	fprintf('combination %d: %s varma:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_250_varma(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s silp:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_250_silp(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s product:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_250_product(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s average:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_250_avg(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');

	fprintf('combination %d: %s LP-beta:  ',combnum,explain_combination(combnum));
	thisErr = squeeze(err_250_lpbeta(combnum,nTrainPoints256,:));
	if any(size(thisErr)==1),fprintf('%0.1f ',100*[(1-(thisErr))']);
	else, fprintf('%0.1f +- %.01f ',100*[(1-mean(thisErr,2))';std(thisErr')]);end
	fprintf('\n');
	fprintf('\n');
	
    end
end



