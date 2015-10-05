%
% This file is a master script to create all commands needed to
% compute the Gram matrices, train the classifiers, prepare the
% data, ...
%
% Peter Gehler
%
clear all

% switches of which commands to write out
writeGrams = 0; 
writeMKL = 1;
writeMCLP = 1;
writeCV = 1;
writePhogs = 0;
writePhogs2 = 0;
writeDicts = 0;
writeBow = 0;

% This are all files for which the classifiers/gram matrices/ etc
% have to be computed. 5 splits of Caltech 101, 1 of Caltech256

clear splitfiles
cntr = 0;
for nTrain=5:5:30
    for splitnum=1:5
	cntr = cntr + 1;
	splitfiles{cntr} = ['splits/caltech101_nTrain',num2str(nTrain),'_nTest50_N',num2str(splitnum),'.mat'];
    end
end
for nTrain=[5:5:30,40,50]
    cntr = cntr + 1;
    splitfiles{cntr} = ['splits/caltech256_nTrain',num2str(nTrain),'_nTest25_N1.mat'];
end

silpstr = sprintf('export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/scratch_net/biwidl07/projects/caltech/code/shogun-0.7.3/lib;');
matstr = sprintf('cd /scratch_net/biwidl07/projects/caltech/; matlab -nojvm -nodisplay -nodesktop -r "');

% This is the file to write commands to
fid = fopen('commands.txt','w');

if (0)
    f = textread('caltech101_filelist','%s\n');
    for i=1:numel(f)
	str = sprintf('%scomputePhogs(''%s'');exit;"',matstr,f{i});
	fprintf(fid,'%s\n',str);
    end
end

if (0)
    f = textread('caltech256_filelist','%s\n');
    for i=1:numel(f)
	str = sprintf('%scomputePhogs(''%s'');exit;"',matstr,f{i});
	fprintf(fid,'%s\n',str);
    end
end
    

if (writeGrams)
    avgs = [530:629,330:429]; 
    
    % for which features to compute the Gram matrices? 
    featnums = [66:68,322:329,666:677,318:321,630,632,678,679,680,681,692,689:691,69,688];
    load_features;
    dataset = '101';nTest=50;
    for featnum=unique([avgs,featnums])
	for splitnr=1:5
	    for nTrain=5:5:30
		splitfile = sprintf('splits/caltech%s_nTrain%d_nTest%d_N%d.mat',dataset,nTrain,nTest,splitnr);
		gramfilename = create_gramfilename(splitfile,featnum);
		gramtestfile = strrep(gramfilename,'_feat','_test_feat');
		if exist(gramfilename,'file')&exist(gramtestfile,'file')
		    continue;
		end
		if isfield(f{featnum},'depends')
		    gramfilename = create_gramfilename(splitfile,f{featnum}.depends);
		    if exist(gramfilename,'file'), continue; end
		end
		
		str = sprintf('%swrite_gram_matrices(''%s'',%d,%d,%d,%d);exit;"',matstr,dataset,nTrain,nTest,splitnr,featnum);
		fprintf(fid,'%s\n',str);
	    end
	end
    end
    
    dataset = '256';nTest=25;
    for nTrain=[5:5:30,40,50] 
	for featnum=unique([avgs,featnums])
	    for splitnr=1
		splitfile = sprintf('splits/caltech%s_nTrain%d_nTest%d_N%d.mat',dataset,nTrain,nTest,splitnr);
		gramfilename = create_gramfilename(splitfile,featnum);
		gramtestfile = strrep(gramfilename,'_feat','_test_feat');
		if exist(gramfilename,'file')&exist(gramtestfile,'file')
		    continue;
		end
		if isfield(f{featnum},'depends')
		    gramfilename = create_gramfilename(splitfile,f{featnum}.depends);
		    if exist(gramfilename,'file'), continue; end
		end
		str = sprintf('%swrite_gram_matrices(''%s'',%d,%d,%d,%d);exit;"',matstr,dataset,nTrain,nTest,splitnr,featnum);
		fprintf(fid,'%s\n',str);
	    end
	end
    end
    
end



if (writePhogs)
    fid_list = fopen('caltech101_filelist','r');
    flist = textscan(fid_list,'%s\n');
    flist = flist{1};
    fclose(fid_list);clear fid_list;

    for i=1:50:numel(flist)
	
	str = ['cd ~/projects/caltech/; matlab -nojvm -nodisplay -r "'];
	for n=0:min(numel(flist)-i,49)
	    str = sprintf('%s computePhog(''%s'',%d,%d);',str,flist{i+n},40,360);
	end
	str = sprintf('%s exit;"',str);
	fprintf(fid,'%s\n',str);

	str = ['cd ~/projects/caltech/; matlab -nojvm -nodisplay -r "'];
	for n=0:min(numel(flist)-i,49)
	    str = sprintf('%s computePhog(''%s'',%d,%d);',str,flist{i+n},20,180);
	end
	str = sprintf('%s exit;"',str);
	fprintf(fid,'%s\n',str);

    end
end

%
% DICTIONARY CREATION
%
if (writeDicts)
    types = {'grey'};
    datasets = {'101','256'};
    
    for K=[300,1000]
	for d=1:numel(datasets)
	    dataset = datasets{d};
	    for t=1:numel(types)
		type = types{t};
		for s=1:10
		    if ~exist(sprintf('/agbs/cluster/pgehler/projects/caltech/dictionaries/oneForAll_nr%d/caltech%s_%s_K%d.mat',s,dataset,type,K),'file')
			str = sprintf('%screate_dictionaries(%d,%d,''%s'',''%s'');exit;"',matstr,K,s,type,dataset);
			fprintf(fid,'%s\n',str);
		    end
		end 
	    end
	end

	for d=1:numel(datasets)
	    dataset = datasets{d};
	    type = 'colorstacked';
	    for s=1:10
		if ~exist(sprintf('/agbs/cluster/pgehler/projects/caltech/dictionaries/oneForAll_nr%d/caltech%s_%s_K%d.mat',s,dataset,type,K),'file')
		    str = sprintf('%screate_dictionaries(%d,%d,''%s'',''%s'');exit;"',matstr,K,s,type,dataset);
		    fprintf(fid,'%s\n',str);
		end
	    end 
	end
    end
    
end


%
%
%
if (writePhogs2)
    filelist = textread('caltech101_filelist','%s\n');
    for i=1:numel(filelist)
	fname = filelist{i};
	fname1 = [strrep(fname,'_images/',sprintf('_features/phog/subwindows/A%d_K%d/',360,40))];
	fname2 = [strrep(fname,'_images/',sprintf('_features/phog/subwindows/A%d_K%d/',360,40))];

	if exist([fname1,'.bz2']) & exist([fname2,'.bz2']), continue; end
	str = sprintf('%scomputePhogImage(''%s'');exit;"',matstr,fname);
	fprintf(fid,'%s\n',str);
    end


    filelist = textread('caltech256_filelist','%s\n');
    for i=1:numel(filelist)
	fname = filelist{i};
	fname1 = [strrep(fname,'_images/',sprintf('_features/phog/subwindows/A%d_K%d/',360,40))];
	fname2 = [strrep(fname,'_images/',sprintf('_features/phog/subwindows/A%d_K%d/',360,40))];

	if exist([fname1,'.bz2']) & exist([fname2,'.bz2']), continue; end
	str = sprintf('%scomputePhogImage(''%s'');exit;"',matstr,fname);
	fprintf(fid,'%s\n',str);
    end
end


%
% QUANTIZATION
%
if (writeBow)
    for K=[300,1000]
	for s=1:1
	    str = sprintf('%screate_bow(%d,%d,''grey'',0,0,0,''101'');exit;"',matstr,K,s);
	    fprintf(fid,'%s\n',str);
	    str = sprintf('%screate_bow(%d,%d,''colorstacked'',0,0,0,''101'');exit;"',matstr,K,s);
	    fprintf(fid,'%s\n',str);
	    str = sprintf('%screate_bow(%d,%d,''grey'',0,0,0,''256'');exit;"',matstr,K,s);
	    fprintf(fid,'%s\n',str);
	    str = sprintf('%screate_bow(%d,%d,''colorstacked'',0,0,0,''256'');exit;"',matstr,K,s);
	    fprintf(fid,'%s\n',str);
	end
    end
end


%
% MCLP TRAINING
%
if (writeMCLP)
    clear f
    load_features;fts = f;clear f;
    for n=1:numel(splitfiles)
	splitfile = splitfiles{n};
	
	
	%
	% this is two stage training
	%

	if strfind(splitfile,'256'),
	    combinations = [11,32,30,39];
	elseif strfind(splitfile,'101'),
	    combinations = [32,30,33,39];
	end

	mclpdir = strrep(splitfile,'.mat','');
	mclpdir = strrep(mclpdir,'splits/','mclp_score/');

	results;clear str;

	load_combinations;
	for combnum=combinations
	    featnum = unique([featnum,combination{combnum}]);
	end

	%
	% STAGE 1 - training of individual classifiers
	%
	for f=featnum

	    % check whether the gram file was created
	    gramfilename = create_gramfilename(splitfile,f);
	    if ~exist(gramfilename,'file'), continue; end
	    
	    % check whether the classifier was already trained
	    done_file = [mclpdir,'/done_feature',num2str(f),'.mat'];
	    if exist(done_file,'file'), continue;end

	    % for efficiency, we split into parallel or sequential
            % trianing, it does not really matter
	    if strfind(splitfile,'256')>0
		doesExist = true; % check which files need to be written
		for C=[1,10,50,100,500,1000];
		    fname = sprintf('/scratch_net/biwidl07/projects/caltech/mclp_score/%s/feature%d/cvfile_C%d.mat',strrep(strrep(splitfile,'splits/',''),'.mat',''),f,C);
		    if exist(fname,'file'), continue; end
		    str = sprintf('%strain_and_predict_single(''%s'',%d,1,%g);exit"',matstr,splitfile,f,C);
		    fprintf(fid,'%s\n',str);
		    doesExist =false;
		end
		% single CVs are done, now compute the final one
		if doesExist
		    str = sprintf('%strain_and_predict_single(''%s'',%d,1,0);exit"',matstr,splitfile,f);
		    fprintf(fid,'%s\n',str);
		end
	    else
		str = sprintf('%strain_and_predict_single(''%s'',%d);exit"',matstr,splitfile,f);
		fprintf(fid,'%s\n',str);
	    end
	end

	%
	% STAGE 2 - training of mixing coefficients
	%
	for combnum = combinations
	    
	    done_file_1st_lpbeta = [mclpdir,'/done_combination',num2str(combnum),'_lpbeta.mat'];
	    done_file_1st_lpB    = [mclpdir,'/done_combination',num2str(combnum),'_lpB.mat'];
	
	    done_file_2nd_lpbeta = [mclpdir,'/done_combination',num2str(combnum),'_2ndstage_lpbeta.mat'];
	    done_file_2nd_lpB    = [mclpdir,'/done_combination',num2str(combnum),'_2ndstage_lpB.mat'];

	    predfile_lpbeta = [mclpdir,'/combination',num2str(combnum),'/test_prediction_lpbeta.mat'];
	    predfile_avg = [mclpdir,'/combination',num2str(combnum),'/test_prediction_avg.mat'];
	    predfile_lpB    = [mclpdir,'/combination',num2str(combnum),'/test_prediction_lpB.mat'];

	    % lp-beta training
	    if ~exist(done_file_1st_lpbeta,'file')
		str = sprintf('%strain_mclp(''%s'',%d,1);exit"',matstr,splitfile,combnum);
		fprintf(fid,'%s\n',str);
	    elseif exist(done_file_1st_lpbeta,'file') & ~exist(done_file_2nd_lpbeta,'file')
		str = sprintf('%strain_mclp_2ndstage(''%s'',%d,1);exit"',matstr,splitfile,combnum);
		fprintf(fid,'%s\n',str);
	    elseif exist(done_file_1st_lpbeta,'file') & exist(done_file_2nd_lpbeta,'file') & ~exist(predfile_lpbeta,'file')
		str = sprintf('%stest_mclp_2ndstage(''%s'',%d,1);exit"',matstr,splitfile,combnum);
		fprintf(fid,'%s\n',str);
	    end
	    
	    % Test simple averaging of the classifiers
	    if ~exist(predfile_avg,'file')
		str = sprintf('%stest_mclp_2ndstage_avg(''%s'',%d);exit"',matstr,splitfile,combnum);
		fprintf(fid,'%s\n',str);
	    end
	    
	    % LP training
	    if ~exist(done_file_1st_lpB,'file')
		str = sprintf('%strain_mclp(''%s'',%d,0);exit"',matstr,splitfile,combnum);
		fprintf(fid,'%s\n',str);
	    elseif exist(done_file_1st_lpB,'file') & ~exist(done_file_2nd_lpB,'file')
		str = sprintf('%strain_mclp_2ndstage(''%s'',%d,0);exit"',matstr,splitfile,combnum);
		fprintf(fid,'%s\n',str);
	    elseif exist(done_file_1st_lpB,'file') & exist(done_file_2nd_lpB,'file') & ~exist(predfile_lpB,'file')
		str = sprintf('%stest_mclp_2ndstage(''%s'',%d,0);exit"',matstr,splitfile,combnum);
		fprintf(fid,'%s\n',str);
	    end
	    
	    

	end
    end
end


%
% MKL TRAINING
%
if (writeMKL)
    for n=1:numel(splitfiles)
	splitfile = splitfiles{n};
	if strfind(splitfile,'256'),
	    nClasses = 256;
	    combinations = [11,30,32,39];
	elseif strfind(splitfile,'101'),nClasses=102;
	    combinations = [11,40,27:33,39,41];
	    combinations =[32,30,33,39,43,44];
	end

	for combnum =combinations
	    % check if all needed gram matrices are there
	    load_combinations; fnums = combination{combnum}; does_exist = 1;
	    for ff=fnums
		gramfilename = create_gramfilename(splitfile,ff);
		if ~exist(gramfilename,'file'), does_exist = 0;break;end
	    end
	    if ~does_exist
		fprintf(['file ''',gramfilename,''' does not yet exist\n']);
		continue;
	    end
	    
	    varmaWritten = 0;
	    silpWritten = 0;
	    
	    C=1000;
	    if ~exist(generate_classifierfname(splitfile,'average',combnum,1,C),'file')
		str = sprintf('%smkltrain_combination(''%s'',%d,''%s'',%d);exit;"',matstr,splitfile,combnum,'average',C);
		fprintf(fid,'%s\n',str);
	    end
	    
	    C = 1000;
	    if ~exist(generate_classifierfname(splitfile,'product',combnum,1,C),'file')
		str = sprintf('%smkltrain_combination(''%s'',%d,''%s'',%d);exit;"',matstr,splitfile,combnum,'product',C);
		fprintf(fid,'%s\n',str);
	    end

	    
	    C = 1000;
	    for c=1:nClasses
		

		% either sequential (all classes at once)
		if ~exist(generate_classifierfname(splitfile,'silp',combnum,c,C),'file')&~silpWritten
		    str = sprintf('%s%smkltrain_combination(''%s'',%d,''%s'',%d);exit;"',silpstr,matstr,splitfile,combnum,'silp',C);
		    fprintf(fid,'%s\n',str);
		    silpWritten=1;
		end

		% VARMA == SILP but slower
		%if ~exist(generate_classifierfname(splitfile,'varma',combnum,c,C),'file')&~varmaWritten
		%	str = sprintf('%smkltrain_combination(''%s'',%d,''%s'',%d);exit;"',matstr,splitfile,combnum,'varma',C);
		%	fprintf(fid,'%s\n',str);
		%	varmaWritten=1;
		%    end

	    end
	end
    end
end

%
% Perform Cross validation to figure out which is the best single
% kernel for which combination
%
if (writeCV)
    clear f
    
    load_features;fts = f;clear f;
    for n=1:numel(splitfiles)
	splitfile = splitfiles{n};
	if strfind(splitfile,'256'),
	    combinations = [30,11,32,39];
	elseif strfind(splitfile,'101'),
	    combinations = [30,32,33,39];
	end

	mclpdir = strrep(splitfile,'.mat','');
	mclpdir = strrep(mclpdir,'splits/','mclp_score/');

	results;clear str;

	load_combinations;
	
	for combnum=combinations;
	    featnums = combination{combnum};

	    tmp_str = 'cv-best';
	    for ff=featnums
		tmp_str = sprintf('%s_f%d',tmp_str,ff);
	    end
	    fname = sprintf('%s/%s.mat',strrep(strrep(splitfile,'.mat',''),'splits/','mclp_score/'),tmp_str);
	    if exist(fname,'file'), continue; end
	    
	    
	    str = sprintf('%scv_between_features(''%s'',',matstr,splitfile);
	    str = sprintf('%s[%d',str,featnums(1));
	    for ff=featnums(2:end);
		str = sprintf('%s,%d',str,ff);
	    end
	    str = sprintf('%s]);exit"',str);
	    fprintf(fid,'%s\n',str);
	end
    end
end


str = sprintf('%sreportResults;exit;"',matstr);
fprintf(fid,'%s\n',str);

fclose(fid);

!wc -l commands.txt
