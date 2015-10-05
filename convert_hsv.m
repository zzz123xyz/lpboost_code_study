% convert_hsv(dataset)
%
% convert all images in 'dataset' (caltech101 or caltech256) to HSV
% images and store them for further preprocessing
function convert_hsv(dataset)

warning('off','MATLAB:intConvertNonIntVal');

switch dataset
 case 'caltech101'
  featuredir = '~/caltech/caltech101_features/hsv/';
  imdir = '/agbs/share/datasets/caltech_101/caltech101_images/';
  imtype = 'jpg';
 case 'caltech256'
  featuredir = '~/caltech/caltech256_features/hsv/';
  imdir = '/agbs/share/datasets/Caltech256/256_ObjectCategories/';
  imtype = 'jpg';
 otherwise
  error('unknown dataset');
end

system(['mkdir -p ' featuredir]);

nClasses = 0;
T = dir(imdir);
class = [];
for i=1:numel(T)
    if ~(T(i).isdir)
	continue
    end
    if strcmp(T(i).name,'.') || strcmp(T(i).name,'..')
	continue;
    end
    if strcmp(dataset,'caltech256') % because chl has links to each dir
	if ~numel(strfind(T(i).name,'.'))
	    continue;
	end
    end
    
    nClasses = nClasses + 1;
    class{nClasses} = T(i).name;
end

fprintf('found %d classes\n',nClasses);

shuff = randperm(nClasses);
for i=1:nClasses
    tic;
    ii = shuff(i);
    featureclassdir = [featuredir class{ii}];
    imclassdir = [imdir class{ii}];
    
    class{ii}

    convert_hsv_dir(imclassdir,featureclassdir,imtype);
    t=toc;
    fprintf('%d of %d done, %.2f seconds\nt',i,nClasses,t);

end
warning('on','MATLAB:intConvertNonIntVal');



function convert_hsv_dir(imdir,featuredir,type)

if ~strcmp(imdir(end),'/')
    imdir(end+1) = '/';
end
if ~strcmp(featuredir(end),'/')
    featuredir(end+1) = '/';
end

Xfiles = dir([imdir '*.' type]);

if ~exist(featuredir,'dir')
    fprintf('creating dir: ''%s''\n',featuredir);
    s = system(['mkdir -p ' featuredir]);
    if s~=0
	error('failed to created dir');
    end
end

shuff = randperm(numel(Xfiles));
for i=1:numel(Xfiles)
    ii = shuff(i);
    hfname = sprintf('%s%s_h.tif',featuredir,Xfiles(ii).name);
    sfname = sprintf('%s%s_s.tif',featuredir,Xfiles(ii).name);
    vfname = sprintf('%s%s_v.tif',featuredir,Xfiles(ii).name);
    greyname = sprintf('%s%s_grey.tif',featuredir,Xfiles(ii).name);

    
    if (exist(hfname,'file') && exist(sfname,'file') && ...
	exist(vfname,'file') && exist(greyname,'file'))
	fprintf('existing, skipping\r');
	continue;
    end
    
    fname = [imdir Xfiles(ii).name];
    I = imread(fname);

    if (ndims(I)==2)
	Ig = uint8(I);
	I = repmat(I,[1,1,3]);
    else
	Ig = uint8(.3*I(:,:,1) + .59 * I(:,:,2) + .11 * I(:,:,3));
    end
    
    if ~(exist(hfname,'file') && exist(sfname,'file') && exist(vfname,'file'))
	try
	    H = rgb2hsv(I);
	    H = uint8(255*H);
	    imwrite(H(:,:,1),hfname);
	    imwrite(H(:,:,2),sfname);
	    imwrite(H(:,:,3),vfname);
	catch
	    I = imresize(I,.5);
	    H = rgb2hsv(I);
	    H = uint8(255*H);
	    H = imresize(H,2);
	    imwrite(H(:,:,1),hfname);
	    imwrite(H(:,:,2),sfname);
	    imwrite(H(:,:,3),vfname);
	end
	
    end	

    if ~exist(greyname,'file')
	imwrite(Ig,greyname);
    end
    
end
