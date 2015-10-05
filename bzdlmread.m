%D = bzdlmread(imfilename)
% 
% acts as dlmread but is also reading gzipped or bzipped files
%
% example: D = bzdlmread('test.txt.bz2');
%	   D = bzdlmread('test.txt');
%
% Peter Gehler
function D = bzdlmread(imfilename)


if numel(imfilename)>3 && ~(strcmp(imfilename(end-3:end),'.bz2')|strcmp(imfilename(end-2:end),'.gz'))

    if exist(imfilename,'file')
	D = dlmread(imfilename);
    elseif exist([imfilename,'.bz2'],'file')
	D = bzdlmread([imfilename,'.bz2']);
    elseif exist([imfilename,'.gz'],'file')
	D = bzdlmread([imfilename,'.gz']);
    else
	error(['file ''',imfilename,''' does not exist!']);
    end

elseif strcmp(imfilename(end-2:end),'.gz')

    if exist(imfilename,'file')
	[ignore,tempfile] = system('tempfile');tempfile(end) = [];
	system(['rm -f ',tempfile]);
	system(['zcat ',imfilename,'>',tempfile]);
	D = dlmread(tempfile);
	system(['rm -f ',tempfile]);
    elseif exist(imfilename(1:end-3),'file')
	D = dlmread(imfilename(1:end-3));
    else 
	error(['file ''',imfilename,''' does not exist!']);
    end

elseif strcmp(imfilename(end-3:end),'.bz2')

    if exist(imfilename,'file')
	[ignore,tempfile] = system('tempfile');tempfile(end) = [];
	system(['rm -f ',tempfile]);
	system(['bzcat ',imfilename,'>',tempfile]);
	D = dlmread(tempfile);
	system(['rm -f ',tempfile]);
    elseif exist(imfilename(1:end-4),'file')
	D = dlmread(imfilename(1:end-4));
    else 
	error(['file ''',imfilename,''' does not exist!']);
    end
    
end