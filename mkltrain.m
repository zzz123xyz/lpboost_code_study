% [ws, alpha, b] = mkltrain(y, Ks, C, mkl_eps, svm_eps,opts);
%
% Train a mixture of kernels. Specify the method via struct 'opts'
%
% opts.alg - 'silp','product','average','varma','simplemkl',...
%
% 03/18/09 Peter Gehler (pgehler@googlemail.com)
function [ws, alpha, b] = mkltrain(y, Ks, C, mkl_eps, svm_eps,opts);

warning('off','MATLAB:dispatcher:pathWarning')
addpath code/mkl
addpath code/libsvm-matlab
addpath code/liblinear-1.33/matlab
warning('on','MATLAB:dispatcher:pathWarning')

switch opts.alg
 case {'silp','silp_marginscaled'}
  [ws, alpha, b] = mkltrain_silp(y, Ks, C, mkl_eps, svm_eps);
 case 'simplemkl'
  [ws, alpha, b] = mkltrain_mysimple(y, Ks, C, mkl_eps,svm_eps);
 case 'varma' 
  [ws, alpha, b] = mkltrain_varma(y, Ks, C, mkl_eps, svm_eps);
 case 'average' 
  ws = ones(size(Ks,3),1);ws=ws/sum(ws);
  K = Kbeta(Ks,ws);
  [alpha,b] = libsvm(y,K,C,svm_eps);
 case 'product' 
  ws = 1;
  [alpha,b] = libsvm(y,Ks,C,svm_eps);
  
 case 'linear_multiclass'
  model = train(y, sparse(double(Ks)),['-c ',num2str(C),' -s 4 -e 0.001']);
  alpha = model.w(:,1:end-1);
  b = model.w(:,end);
  ws = 0;

 case 'linear_empkernel_logistic'

  model = train(y, sparse(double(Ks)),['-c ',num2str(C),' -s 0 -e 0.001']);
  alpha = model.w(1,1:end-1)'*y(1);
  b = model.w(1,end)*y(1);
  ws = 0;

 case 'linear_empkernel_l2loss'

  model = train(y, sparse(double(Ks)),['-c ',num2str(C),' -s 1 -e 0.001']);
  alpha = model.w(1,1:end-1)'*y(1);
  b = model.w(1,end)*y(1);
  ws = 0;
  
 case 'linear_empkernel_l1loss'

  model = train(y, sparse(double(Ks)),['-c ',num2str(C),' -s 3 -e 0.001']);
  alpha = model.w(1,1:end-1)'*y(1);
  b = model.w(1,end)*y(1);
  ws = 0;

  %global X
  %X = Ks;
  %[alpha,b]= primal_svm(1,y,1/C);
  %ws = 0;
 otherwise
  error('no such algorithm');
end

