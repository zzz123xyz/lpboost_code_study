% computePhog - computes PHOG for 100 random subwindows
%
% computePhog(dataset)
% 
% input:  'dataset' - either 101 or 256
%
% output: 

function computePhog(dataset)

rand('twister',100*sum(clock));

switch dataset
 case '101'
  filelist = textread('caltech101_filelist','%s\n');
  case '256'
  filelist = textread('caltech256_filelist','%s\n');
 otherwise 
  error('');
end

shuff = randperm(numel(filelist));
for i=1:numel(filelist)
    computePhogImage(filelist{shuff(i)});
end


function computePhogImage(imagefname);


fprintf('processing ''%s''\n',imagefname);

load('subwindows.mat');

angles = [180,360];
Ks = [20,40];

warning off; addpath code/vgg_phog/;  warning on
levs = 0;

E = [];
for k=1:numel(angles)
    angle = angles(k);
    K = Ks(k);
    
    fname = [strrep(imagefname,'_images/',sprintf('_features/phog/subwindows/A%d_K%d/',angle,K))];
    if (exist(fname,'file')||exist([fname,'.bz2'],'file')), continue; end

    % ... precompute the common part
    if numel(E)==0
	[A180,A360,E,Gr] = vgg_phog_preprocess(imagefname);
    end
    
    % ... create directory if it does not yet exist
    tt=strfind(fname,'/');
    if ~exist(fname(1:tt(end)),'dir'), 	system(['mkdir -p ',fname(1:tt(end))]);    end
    
    f = [];
    % ... for all images
    for n=1:100 % size(windows_lr,1)

	
	% ... compute the regeion of interest randomly already randomly
	% sampled beforehand ...
	roi = [ceil(windows_ul(n,1) .* size(A360,1)),ceil(windows_lr(n,1)*size(A360,1)),ceil(windows_ul(n,2)*size(A360,2)),ceil(windows_lr(n,2)*size(A360,2))]';
	roi(2) = min(roi(2),size(A360,1));
	roi(4) = min(roi(4),size(A360,2));
	
	assert(roi(1)<roi(2))
	assert(roi(3)<roi(4))
	
	roi(roi==0)=1;
	% ... compute the descriptor ...
	switch angle
	 case 180
	  x = vgg_phog_compute(A180,E,Gr,180,K,0,roi);
	 case 360
	  x = vgg_phog_compute(A360,E,Gr,360,K,0,roi);
	 otherwise
	  error('invalid argument for angle');
	end


	f = [f,single(x)];
    end

    %... and save the feature
    dlmwrite(fname,f');
    system(['bzip2 ',fname]);

end
