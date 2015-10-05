% [points,scale,feats] = load_points(file)
%
% load points in Mikolayscik format. Function can handle gzipped
% files. 
% In: 'file' : filename
%
% Out: 'points' : xy-position of points [N,2]
%      'scale' : radius of where features were computed [N,1]
%      'feats' : Feature vector [N,D] with D being feature dimension.
%
% 03/18/09 Peter Gehler (pgehler@googlemail.com)
function [points,scale,feats] = load_points(file)

fprintf('loading points in ''%s''...',file);
X = bzdlmread(file);

if ~numel(X),  error('no feature points in that file');end

assert(X(1,1)==128);
assert(all(X(1,2:end)==0));
assert(X(2,1)==size(X,1)-2)
assert(all(X(2,2:end)==0));

featdim = X(1,1);
npoints = X(2,1);

X(1:2,:) = [];
points = uint32(X(:,1:2));
scale = 1./sqrt(X(:,3));
feats = X(:,6:end);


%if min(feats(:))<0
%    feats(feats==min(feats(:))) = 0;
%end

fprintf('done\n');