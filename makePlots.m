% This function was used to generate the plots for the ICCV submission
%
% use the following values of 'combnum': 30,32,33,39
%
% Peter Gehler

clear all

combnum = 39;
%combnum = 28;
%combnum = 39; % sift - grey - 300 - 0:3
%combnum = 33; % 8 kernels, level 2 of every feature
%combnum = 39; % all features
%combnum = 32; % Phot angle 360 40 bins

%dataset = '101';
dataset = '256'; reportOn250Only=0;

load_combinations;
load_features;

switch combnum
 case 11, 
 case 27
 case 28, titlestr='SIFT - K=1000';
 case 29
 case 30, titlestr='SIFT - grey - K=300 (4 kernels)'; ax = [4.5 30.5 35 65];
 case 31, 
 case 32, titlestr='PHOG: Angle-360,40 bins (4 kernels)'; ax = [4.5 30.5 33 60];
 case 33, titlestr='Pyramid Level 2 kernels (8 kernels)'; ax = [4.5 30.5 35 75];
 case 34, 
 case 39, 
  switch dataset
   case '101'
    titlestr=sprintf('Caltech-%s (39 kernels)',dataset); ax = [4.5 30.5 40 80];
   case '256'
    titlestr=sprintf('Caltech-%s (39 kernels)',dataset); ax = [4.5 50.5 15 55];
  end
 case 40, titlestr = 'Region Covariance';
 case 41, 
 case 44,
  switch dataset
   case '101'
    titlestr=sprintf('Caltech-%s (48 kernels)',dataset);ax = [4.5 30.5 40 85];
   case '256'
    error('not yet done');
  end
   otherwise
  error('unknown combination');
end

switch dataset
 case '101', nTest = 50;nSplits = 5; nTrainPoints=5:5:30;
 case '256', nTest = 25;nSplits = 1; nTrainPoints=[5:5:30,40,50];
end

featnums = combination{combnum};


switch dataset
 case '101'
  for nTrain=nTrainPoints
      for splitnum=1:nSplits
	  splitfile = sprintf('splits/caltech%s_nTrain%d_nTest%d_N%d.mat',dataset,nTrain,nTest,splitnum);
	  bestFeature = cv_between_features(splitfile,featnums);
	  fprintf('split%d, nTrain %d: best Feature is %d: %s\n',splitnum,nTrain,bestFeature,explain_feature(bestFeature));
	  err_single(nTrain,splitnum) = train_and_predict_single(splitfile,bestFeature);

	  err_varma(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'varma',1000);
	  err_silp(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'silp',1000);
	  err_product(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'product',1000);
	  err_average(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'average',1000);
	  err_logistic(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'linear_empkernel_logistic',0.1);
	  err_lpb(combnum,nTrain,splitnum) = test_mclp_2ndstage(splitfile,combnum,0);
	  err_lpbeta(combnum,nTrain,splitnum) =test_mclp_2ndstage(splitfile,combnum,1);
	  err_lp_avg(combnum,nTrain,splitnum) =test_mclp_2ndstage_avg(splitfile,combnum);
      end
  end
 case '256'
  for nTrain=nTrainPoints
      for splitnum=1:nSplits
	  splitfile = sprintf('splits/caltech%s_nTrain%d_nTest%d_N%d.mat',dataset,nTrain,nTest,splitnum);

	  bestFeature = cv_between_features(splitfile,featnums);
	  fprintf('best Feature is %d: %s\n',bestFeature,explain_feature(bestFeature));
	  if (reportOn250Only)
	      err_single(nTrain,splitnum) = train_and_predict_single_caltech250(splitfile,bestFeature);

	      err_varma(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'varma',1000);
	      err_silp(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'silp',1000);
	      err_product(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'product',1000);
	      err_average(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'average',1000);
	      err_logistic(combnum,nTrain,splitnum) = mkltest_combination_caltech250(splitfile,combnum,'linear_empkernel_logistic',0.1);
	      err_lpb(combnum,nTrain,splitnum) = test_mclp_2ndstage_caltech250(splitfile,combnum,0);
	      err_lpbeta(combnum,nTrain,splitnum) =test_mclp_2ndstage_caltech250(splitfile,combnum,1);
	  else
	      err_single(nTrain,splitnum) = train_and_predict_single(splitfile,bestFeature);
	      err_varma(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'varma',1000);
	      err_silp(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'silp',1000);
	      err_product(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'product',1000);
	      err_average(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'average',1000);
	      err_logistic(combnum,nTrain,splitnum) = mkltest_combination(splitfile,combnum,'linear_empkernel_logistic',0.1);
	      err_lpb(combnum,nTrain,splitnum) = test_mclp_2ndstage(splitfile,combnum,0);
	      err_lpbeta(combnum,nTrain,splitnum) =test_mclp_2ndstage(splitfile,combnum,1);
	  end
      end
  end
end


color_lpbeta = 'ro-';
color_lpb = 'ro--';
color_varma = 'bo-';
color_silp = 'bo-';
color_logistic = 'go-';
color_separate = 'mo--';
color_product = 'ko-';
color_average = 'co-';


clear f; load_features;
figure(1);clf;hold on

switch dataset
 case '101'

  thisErr = squeeze(err_single(nTrainPoints,:));
  meanAcc = mean(1-thisErr,2);
  stdAcc = std((1-thisErr)');
  errorbar(nTrainPoints,100*meanAcc,100*stdAcc,color_separate,'LineWidth',2);
  %legend_text{1} = strrep(explain_feature(f{featnums(bestSingleMatrix)}),'_','\_');
  legend_text{1} = 'best feature';
  i=2;

  fprintf('Best Feature ');
  fprintf('&%.1f $\\pm$ %.1f',100*[meanAcc,stdAcc']');
  fprintf('\\\\\n');
  
  if (0)
  thisErr = squeeze(err_product(combnum,nTrainPoints,:));
  meanAcc = mean(1-thisErr,2);
  stdAcc = std((1-thisErr)');
  errorbar(nTrainPoints,100*meanAcc,100*stdAcc,color_product,'LineWidth',2);
  legend_text{i} = 'product';
  i=i+1;
  fprintf('Product ');
  fprintf('&%.1f $\\pm$ %.1f ',100*[meanAcc,stdAcc']');
  fprintf('\\\\\n');
  end

  thisErr = squeeze(err_average(combnum,nTrainPoints,:));
  meanAcc = mean(1-thisErr,2);
  stdAcc = std((1-thisErr)');
  errorbar(nTrainPoints,100*meanAcc,100*stdAcc,color_average,'LineWidth',2);
  legend_text{i} = 'average';
  i=i+1;
  fprintf('Average ');
  fprintf('&%.1f $\\pm$ %.1f',100*[meanAcc,stdAcc']');
  fprintf('\\\\\n');


  if (combnum ~= 39)
      thisErr = squeeze(err_logistic(combnum,nTrainPoints,:));
      thisErr(:,any(isinf(thisErr))) = [];
      meanAcc = mean(1-thisErr,2);
      stdAcc = std((1-thisErr)');
      errorbar(nTrainPoints,100*meanAcc,100*stdAcc,color_logistic,'LineWidth',2);
      legend_text{i} = 'CG-boost';
      i=i+1;
      fprintf('CG-Boost ');
      fprintf('&%.1f $\\pm$ %.1f ',100*[meanAcc,stdAcc']');
      fprintf('\\\\\n');
  end

  thisErr = squeeze(err_silp(combnum,nTrainPoints,:));
  meanAcc = mean(1-thisErr,2);
  stdAcc = std((1-thisErr)');
  errorbar(nTrainPoints,100*meanAcc,100*stdAcc,color_silp,'LineWidth',2);
  legend_text{i} = 'MKL'; % (silp or simple)';
  i=i+1;
  fprintf('MKL ');
  fprintf('&%.1f $\\pm$ %.1f ',100*[meanAcc,stdAcc']');
  fprintf('\\\\\n');


  if (0)
      thisErr = squeeze(err_varma(combnum,nTrainPoints,:));
      meanAcc = mean(1-thisErr,2);
      stdAcc = std((1-thisErr)');
      errorbar(nTrainPoints,100*meanAcc,100*stdAcc,color_varma,'LineWidth',2);
      legend_text{i} = 'MKL (varma)';
      i=i+1;
  end
  
  thisErr = squeeze(err_lpbeta(combnum,nTrainPoints,:));
  meanAcc = mean(1-thisErr,2);
  stdAcc = std((1-thisErr)');
  errorbar(nTrainPoints,100*meanAcc,100*stdAcc,color_lpbeta,'LineWidth',2);
  legend_text{i} = 'LP-\beta';
  i=i+1;
  fprintf('LP-$\\beta$ ');
  fprintf('&%.1f $\\pm$ %.1f',100*[meanAcc,stdAcc']');
  fprintf('\\\\\n');


  if (0)
  thisErr = squeeze(err_lpb(combnum,nTrainPoints,:));
  meanAcc = mean(1-thisErr,2);
  stdAcc = std((1-thisErr)');
  errorbar(nTrainPoints,100*meanAcc,100*stdAcc,color_lpb,'LineWidth',2);
  legend_text{i} = 'LP-B';
  i=i+1;
  grid on
  legend(legend_text,'Location','SouthEast','FontSize',20)
  fprintf('LP-B ');
  fprintf('&%.1f $\\pm$ %.1f',100*[meanAcc,stdAcc']');
  fprintf('\\\\\n');
  end
    
  thisErr = squeeze(err_lp_avg(combnum,nTrainPoints,:));
  meanAcc = mean(1-thisErr,2);
  stdAcc = std((1-thisErr)');
  i=i+1;
  fprintf('LP-Avg ');
  fprintf('&%.1f $\\pm$ %.1f ',100*[meanAcc,stdAcc']');
  fprintf('\\\\\n');


 case '256'
  
  thisErr = squeeze(err_single(nTrainPoints,:));
  % [ignore,bestSingleMatrix] = min(sum(mean(err(featnums,nTrainPoints,:),3),2));
  %  thisErr = squeeze(err(featnums(bestSingleMatrix),nTrainPoints,:));
  plot(nTrainPoints,100*(1-thisErr),color_separate,'LineWidth',2);
  legend_text{1} = 'best feature';
  i=2;
  fprintf('Best Feature ');
  fprintf('&%.1f ',100*[1-thisErr]);
  fprintf('\\\\\n');



  if (0)
      thisErr = squeeze(err_product(combnum,nTrainPoints,:));
      plot(nTrainPoints,100*(1-thisErr),color_product,'LineWidth',2);
      legend_text{i} = 'product';
      i=i+1;
      fprintf('Product ');
      fprintf('&%.1f ',100*[1-thisErr]);
      fprintf('\\\\\n');
  end

  thisErr = squeeze(err_average(combnum,nTrainPoints,:));
  plot(nTrainPoints,100*(1-thisErr),color_average,'LineWidth',2);
  legend_text{i} = 'average';
  i=i+1;
  fprintf('Average ');
  fprintf('&%.1f ',100*[1-thisErr]);
  fprintf('\\\\\n');
 

  if (0)
      thisErr = squeeze(err_logistic(combnum,nTrainPoints,:));
      plot(nTrainPoints,100*(1-thisErr),color_logistic,'LineWidth',2);
      legend_text{i} = 'cg-boost';
      i=i+1;
  end
  %thisErr = squeeze(err_silp(combnum,nTrainPoints,:));
  %plot(nTrainPoints,100*(1-thisErr),color_silp,'LineWidth',2);
  thisErr = squeeze(err_silp(combnum,5:5:30,:));
  plot(5:5:30,100*(1-thisErr),color_silp,'LineWidth',2);
  legend_text{i} = 'MKL';
  i=i+1;
  fprintf('MKL ');
  fprintf('&%.1f ',100*[1-thisErr]);
  fprintf('\\\\\n');
 

  if (0)
      thisErr = squeeze(err_varma(combnum,nTrainPoints,:));
      plot(nTrainPoints,100*(1-thisErr),color_varma,'LineWidth',2);
      legend_text{i} = 'MKL (varma)';
      i=i+1;
  end

  thisErr = squeeze(err_lpbeta(combnum,nTrainPoints,:));
  plot(nTrainPoints,100*(1-thisErr),color_lpbeta,'LineWidth',2);
  legend_text{i} = 'LP-\beta';
  i=i+1;
  fprintf('LP-$\\beta$ ');
  fprintf('&%.1f ',100*[1-thisErr]);
   fprintf('\\\\\n');

   if(0)
       thisErr = squeeze(err_lpb(combnum,nTrainPoints,:));
       plot(nTrainPoints,100*(1-thisErr),color_lpb,'LineWidth',2);
       legend_text{i} = 'LP-B';
       i=i+1;
       fprintf('LP-B ');
       fprintf('&%.1f ',100*[1-thisErr]);
       fprintf('\\\\\n');
   end
  
  legend_text{i} = 'Griffin, Holub and Perona (TR06)';
  i=i+1;
  pts{1} = [5 10 15 20 25 30 50];
  results{1} = [18.74,25.01,28.4,31.31,33.2,34.2,39.01];

  legend_text{i} = 'Pinto, Cox and DiCarlo (PLOS08)';
  i=i+1;
  pts{2} = [15];
  results{2} = [24];
  plot(pts{1},results{1},'-o','LineWidth',2,'Color',[1,0.4,0.2]);
  plot(pts{2},results{2},'k.','LineWidth',2,'MarkerSize',35);

  %  plot(nTrainPoints,100*(1-err(688,nTrainPoints)),'b*-','LineWidth',3);
  %ax = [4.5 33 15 47];
  grid on
  legend(legend_text,'Location','SouthEast','FontSize',14)

 otherwise
  error('unknown dataset');
end


set(gca,'FontSize',26);

xlabel('#training examples','FontSize',26);
ylabel('accuracy','FontSize',26);

axis(ax);
title(titlestr,'FontSize',26);

legend(legend_text,'Location','SouthEast');
grid on
  
