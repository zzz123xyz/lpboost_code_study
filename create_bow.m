% create_bow(K,oneForAllNr,type,splitNr,nTrain,nTest,dataset)
%
% K - codebook size
% oneForALlNr - 0: if dictionary using splitfiles (clean version)
%		>0:if to use a dictioanry created using ALL images
% type - 'color' or 'grey'
% splitNr - splitNr
% nTrain/nTest
% dataset = '101' or '256'
%
%
function create_bow(K,oneForAllNr,type,splitNr,nTrain,nTest,dataset)


switch version('-release')
 case '2008a',rand('twister',sum(100*clock))
 case '2008b',RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
 otherwise
  rand('twister',sum(100*clock))
end


% I switched from the cleanest setting ( one dict per split) to one
% dict for all. Therefore I added an extra argument to the
% function. Since there are more dictianries created, this can be 1:10
if oneForAllNr>0

    dictfile = sprintf('dictionaries/oneForAll_nr%d/caltech%s_%s_K%d.mat',oneForAllNr,dataset,type,K);
    filelist = textread(['caltech',dataset,'_filelist'],'%s\n');
    out_dir = sprintf('/agbs/cluster/pgehler/projects/caltech/caltech%s_features/dense_bow/oneForAll_nr%d_K%d/',dataset,oneForAllNr,K);
    filelist = strrep(filelist,['caltech',dataset,'_images/'],'');
else
    
    splitfile = sprintf('splits/caltech%s_nTrain%d_nTest%d_N%d.mat',dataset,nTrain,nTest,splitNr);
    dictfile = sprintf('dictionaries/caltech%s_nTrain%d_nTest%d_N%d_%s_K%d.mat',dataset,nTrain,nTest,splitNr,type,K);

    out_dir = sprintf('/agbs/cluster/pgehler/projects/caltech/caltech%s_features/dense_bow/%s/',dataset,strrep(splitfile,'.mat',''));

    load(splitfile,'tr_files','te_files');
    filelist = [tr_files,te_files];

end
system(['mkdir -p ' out_dir]);


warning off
addpath code/mpi_kmeans/
warning on

load(dictfile,'Cx');
in_dir = sprintf('caltech%s_features/dense/',dataset);

switch dataset
 case {'101','256'}

  shuff = randperm(numel(filelist));
  shuff(1:5)
  tic
  for ii=1:numel(filelist)
      i = shuff(ii);
      fname = [filelist{i} '_' type '.dense_sift'];
      fname = strrep(fname,['caltech',dataset,'_images/'],'');
      out_file = [out_dir,fname,'.mat'];

      
      if exist(out_file,'file')
	  continue
      end
      

      f = [];pts = [];scl = [];
      switch type
       case 'grey'
	in_file = [in_dir,fname];
	[pts,scl,f] =  load_points(in_file);
	
       case 'color'
	fname = [filelist{i} '_h.dense_sift'];
	in_file = [in_dir,fname];
	[tmp_pts,tmp_scl,tmp_f] =  load_points(in_file);
	f = [f;tmp_f];
	pts = [pts;tmp_pts];
	scl = [scl;tmp_scl];

	fname = [filelist{i} '_s.dense_sift'];
	in_file = [in_dir,fname];
	[tmp_pts,tmp_scl,tmp_f] =  load_points(in_file);
	f = [f;tmp_f];
	pts = [pts;tmp_pts];
	scl = [scl;tmp_scl];

	fname = [filelist{i} '_v.dense_sift'];
	in_file = [in_dir,fname];
	[tmp_pts,tmp_scl,tmp_f] =  load_points(in_file);
	f = [f;tmp_f]; 
	pts = [pts;tmp_pts];
	scl = [scl;tmp_scl];
	
	
       case 'colorstacked'
	%
	% [H,S,V] = nPts,3*128 dims
	%
	
	fname = [filelist{i} '_h.dense_sift'];
	in_file = [in_dir,fname];
	[pts,scl,tmp_f] =  load_points(in_file);
	f = [f,tmp_f];

	fname = [filelist{i} '_s.dense_sift'];
	in_file = [in_dir,fname];
	[ignore1,ignore2,tmp_f] =  load_points(in_file);
	try
	    f = [f,tmp_f];
	catch 
	    warning(['failed file: ''',in_file,'''\n']);
	    continue;
	end

	fname = [filelist{i} '_v.dense_sift'];
	in_file = [in_dir,fname];
	[ignore1,ignore2,tmp_f] =  load_points(in_file);
	try
	    f = [f,tmp_f];
	catch 
	    warning(['failed file: ''',in_file,'''\n']);
	    continue;
	end

      end
      
      h = mpi_assign_mex(f',Cx);
      if min(h(:))<1 || max(h(:))>K
	  error('histogram out of bounds');
      end

      scl = single(scl);
      class = strtok(fname,'/');
      if ~exist([out_dir,class],'dir'),system(['mkdir -p ' out_dir class]);end
      save(out_file,'h','pts','scl');
      t = toc;
      fprintf('\r%d/%d done, %.4f minutes to go',ii,numel(filelist),numel(filelist)*t/ii/60);
  end
  fprintf('all files done\n');

 otherwise
  error('unknown dataset');
end
