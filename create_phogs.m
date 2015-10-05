function create_phogs(dataset)

switch dataset
 case 'caltech101'
  phogdir = '~/projects/caltech/caltech101_features/phog/';
  datadir = '/agbs/share/datasets/caltech_101/caltech101_images/';
  imtype = 'jpg';
 case 'caltech256'
  phogdir = '~/projects/caltech/caltech256_features/phog/';
  datadir = '/agbs/share/datasets/Caltech256/256_ObjectCategories/';
  imtype = 'jpg';
 otherwise
  error('unknown dataset');
end

system(['mkdir -p ' phogdir]);

warning off
addpath ~/software/vgg_phog/
warning on

nClasses = 0;
T = dir(datadir);
for i=1:numel(T)
    if ~(T(i).isdir),continue;   end
    if strcmp(T(i).name,'.') || strcmp(T(i).name,'..'),continue;   end

    if strcmp(dataset,'caltech256') % because chl has links to each dir
	if ~numel(strfind(T(i).name,'.')), continue;end
    end
   
    nClasses = nClasses + 1;
    class{nClasses} = T(i).name;
end

fprintf('found %d classes\n',nClasses);


shuff = randperm(nClasses);
for i=1:nClasses
    ii = shuff(i);
    imclassdir = [datadir class{ii}];
    phogclassdir = [phogdir class{ii}];
    
    fprintf('processing : %s\n',class{ii});
    create_phogs_dir(imclassdir,phogclassdir,imtype);
end
	


