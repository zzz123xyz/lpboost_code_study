% err = mkltest_combination(splitfile,combnum,opts)
%
% loads the results from each individual one-versus-rest classifier
% and comptues the error;
%
%
function [err,Ypred,te_label] = mkltest_combination(splitfile,combnum,method,C)

%
% file where the classifiers are stored in
%
err = Inf;
load(splitfile,'te_label');
nClasses = numel(unique(te_label));

classifierfile = generate_classifierfname(splitfile,method,combnum,1,C);
resultfile = strrep(classifierfile,'class1','finalresult');
if exist(resultfile,'file'), 
    load(resultfile,'err','Ypred'); 
    assert(err==avg_class_err(te_label,Ypred));
    return; 
end

switch method
    % predict multiclass
 case 'linear_multiclass'
  classifierfile = generate_classifierfname(splitfile,method,combnum,0,C);
  if ~exist(classifierfile,'file'), return; end
  load(classifierfile,'out');
  [ignore,Ypred] = max(out,[],2);
 otherwise
  % predict 1 vs Rest
  for c=1:nClasses

      classifierfile = generate_classifierfname(splitfile,method,combnum,c,C);
      if ~exist(classifierfile,'file')
	  return;
      end
      load(classifierfile,'out');
      outTest(:,c) = out;

  end
  [foo,Ypred] = max(outTest,[],2);
end
err = avg_class_err(te_label,Ypred);
save(resultfile,'err','Ypred');

