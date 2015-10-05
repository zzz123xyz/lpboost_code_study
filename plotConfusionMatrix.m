% test_mclp_2ndstage(splitfile,combnum,task_sharing)
%
% Compute test predictions using the input parameters. If the
% predictions are already done, simply print out the results
%
% weight_sharing = 1 : LP-beta
% weight_sharing = 0 : LP-B
%
%
% Peter Gehler
function [err,ypred,te_label] = plotConfusionMatrix(splitfile,combnum,weight_sharing)
err = Inf;
VERBOSE = 0;

load_combinations;
featnums = combination{combnum};

%
% creating directory to write predictions in 
%
str = strrep(strrep(splitfile,'splits/',''),'.mat','');
preddir = ['/agbs/cluster/pgehler/projects/caltech/mclp_score/'];
preddir = [preddir,str,'/'];

%
% create this file after everything is done
%
if weight_sharing
    done_file = [preddir,'done_combination',num2str(combnum),'_2ndstage_lpbeta.mat'];	  
else
    done_file = [preddir,'done_combination',num2str(combnum),'_2ndstage_lpB.mat'];	  
end

% check whether the first stage (the bestNU) was already
% computed. If not we can not proceed
if ~exist(done_file,'file'),  return; end

if weight_sharing==0
    predfile = [preddir,'combination',num2str(combnum),'/test_prediction_lpB.mat'];	  
else
    predfile = [preddir,'combination',num2str(combnum),'/test_prediction_lpbeta.mat'];	  
end

load(splitfile,'te_label','class');

%
% If this combination was already computed simplty write out the results
%
if ~exist(predfile,'file')
    error(''); 
end

load(predfile,'ypred');

err = avg_class_err(te_label,ypred);
if weight_sharing==1,fprintf('%d LP-beta    acc %.3f\n',combnum,1-err);
else,fprintf('%d LP-B    acc %.3f\n',combnum,1-err);  end


C = zeros(numel(unique(te_label)),numel(unique(ypred)));
for i=1:numel(te_label)
    C(te_label(i),ypred(i)) = C(te_label(i),ypred(i)) + 1;
end

for i=1:size(C,1)
    C(i,:) = C(i,:)./sum(C(i,:));
end

figure(1);clf; 
imagesc(C,[0,1]);
colorbar;
xlabel('class nr','FontSize',26);
ylabel('class nr','FontSize',26)
set(gca,'FontSize',26);
title('Confusion Matrix','FontSize',26);
axis square



CC = diag(C);

[sortCorrect,ind] = sort(CC,'ascend');

figure(2);clf; hold on
barh(sortCorrect);
set(gca,'ylim',[1,numel(sortCorrect)])
plot(mean(sortCorrect)*ones(2,1),[1,numel(class)],'-','LineWidth',2);
set(gca,'YTick',1:numel(class))


c = class(ind);

if strfind(splitfile,'256')>0

    for i=1:numel(c)
	if mod(i,2)==0
	    c{i} = sprintf('%s-------------',c{i}(5:end));
	else
	    c{i} = c{i}(5:end);
	end
    end
end

set(gca,'YTickLabel',c,'FontSize',6)


xlabel('accuracy','FontSize',20);
ylabel('class name','FontSize',20)


if strfind(splitfile,'256')>0
    set(gcf,'PaperPosition',[0 0 20 35]);
    %print -depsc2 ~/latex/thesis/figures/chapterFeatureCombination/caltech256-classname-versus-accuracy.eps
elseif strfind(splitfile,'101')>0
    set(gcf,'PaperPosition',[0 0 20 25]);
    %print -depsc2 ~/latex/thesis/figures/chapterFeatureCombination/caltech101-classname-versus-accuracy.eps
end