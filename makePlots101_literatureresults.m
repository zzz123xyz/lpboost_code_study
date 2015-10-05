
clear all

figure(1);clf;hold on

color = {'mo-','bo-','go-','yo-','co-','ko-'};

color_lpbeta = 'ro-';
color_lpb = 'ro--';
color_varma = 'bo-';
color_silp = 'bo-';
color_logistic = 'go-';
color_separate = 'm-';
color_product = 'ko-';
color_average = 'co-';


dataset  = '101';

switch dataset
 case '101'
  %@techreport{griffinHolubPerona,
  %Author = {G. Griffin and A. Holub and P. Perona},
  %Title = {Caltech-256 Object Category Dataset},
  %Institution = {California Institute of Technology},
  %    Year = {2007},
  %    URL = {http://authors.library.caltech.edu/7694},
  %    Number = {7694}
  % 
  %}
  griffintechreport = [-Inf -Inf -Inf -Inf -Inf 67.6];
  griffintechreportstd = [-Inf -Inf -Inf -Inf -Inf 1.4];


  str{1} = 'Zhang, Berg, Maire and Malik (CVPR06)';
  pts{1} = [1, 5, 10, 15, 20, 30];
  results{1} = [22, 46, 54.8, 59.1, 61.6, 66.2];

  str{2} = 'Lazebnik, Schmid and Ponce (CVPR06)';
  pts{2} = [15,30];
  results{2} = [56.4, 64.6];

  str{3} = 'Wang, Zhang and Fei-Fei (CVPR06)';
  pts{3} = [5, 15, 20, 25, 30];
  results{3} = [19.5, 44.5, 50, 56, 63];

  str{4} = 'Grauman and Darrell (ICCV05)';
  pts{4} = [1, 3, 5, 10, 15, 20, 25, 30];
  results{4} = [18, 28, 34.8, 44, 50, 53.5, 55.5, 58.2];

  str{5} = 'Mutch and Lowe (CVPR06)';
  pts{5} = [15, 30];
  results{5} = [51,  56];

  str{6} = 'Pinto, Cox and DiCarlo (PLOS08)';
  pts{6} = [1, 2, 3, 4, 5, 10, 15, 30];
  results{6} = [24, 33.2, 39.8, 44.6, 47.9, 56.8, 61.44, 67.36];

  str{7} = 'Griffin, Holub and Perona (TR06)';
  pts{7} = [5, 10, 15, 20, 25, 30];
  results{7} = [44.2, 54.2,  59.4, 63.3, 65.8, 67.3];

  for nTrain=5:5:30
      for splitnum=1:3
	  splitfile = sprintf('splits/caltech101_nTrain%d_nTest50_N%d.mat',nTrain,splitnum);
	  err_lpbeta(39,nTrain,splitnum) =test_mclp_2ndstage(splitfile,39,1);
      end
  end

  figure(1); clf; hold on
  for i=[1:6]
      plot(pts{i},results{i},color{i},'LineWidth',2);
  end
  plot(pts{7},results{7},'o-','LineWidth',2,'Color',[1,0.4,0.2]);

  thisErr = squeeze(err_lpbeta(39,5:5:30,:));
  meanAcc = mean(1-thisErr,2);
  stdAcc = std((1-thisErr)');

  errorbar(5:5:30,100*meanAcc,100*stdAcc,'r*-','LineWidth',2);
  str{8} = 'LP-\beta (this paper)';

  a = axis;
  axis([1,30,a(3),a(4)]);
  legend(str,'FontSize',16,'Location','SouthEast');

  grid on
  set(gca,'FontSize',26);
  xlabel('#training examples','FontSize',26);
  ylabel('accuracy','FontSize',26);

  title('Caltech101 comparison to literature','FontSize',26);
  
 case '256'
  
  str{1} = 'Griffin, Holub and Perona (TR06)';
  pts{1} = [5 10 15 20 25 30 50];
  results{1} = [18.74,25.01,28.4,31.31,33.2,34.2,39.01];

  str{2} = 'Pinto, Cox and DiCarlo (PLOS08)';
  pts{2} = [15];
  results{2} = [24];

  for nTrain=5:5:30
      for splitnum=1:1
	  splitfile = sprintf('splits/caltech256_nTrain%d_nTest25_N%d.mat',nTrain,splitnum);
	  err_lpbeta(39,nTrain,splitnum) =test_mclp_2ndstage(splitfile,39,1);
      end
  end

  figure(1); clf; hold on
  for i=1:2
      plot(pts{i},results{i},color{i},'LineWidth',2);
  end

  meanAcc = 100*(1-err_lpbeta(39,5:5:30,1));
  plot(5:5:30,meanAcc,'ro-','LineWidth',2);
  str{3} = 'LP-\beta';
  
    a = axis;
  axis([5,30,a(3),a(4)]);
  legend(str,'FontSize',16,'Location','SouthEast');

  grid on
  set(gca,'FontSize',20);
  xlabel('#training examples','FontSize',20);
  ylabel('accuracy','FontSize',20);

  
end
