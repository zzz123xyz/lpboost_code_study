%
% ATTENTION: only add features at the end!!!!
%
% This file defines all the features that are used by the classifiers. Do
% not change and only add features at the end!
% 'void' features are dummies!
%

clear f;

for i=1:58
    f{i}.type = 'void';
end

% 59
f{end+1}.type = 'app';
f{end}.channel = 'g';
f{end}.K = 300;
f{end}.level = 0:3;

% 60
f{end+1}.type = 'regcov';
f{end}.level = 0:2;

% 61-64
for level = 0:3
    f{end+1}.type = 'void';
end
% 65
f{end+1}.type = 'void';

% 66-68
for level = 0:2
    f{end+1}.type = 'lbp';
    f{end}.level = level;
end

% 69
f{end+1}.type = 'lbp';
f{end}.level = 0:2;

% 70
f{end+1}.type = 'shapen';
f{end}.angle = 360;
f{end}.K = 40;
f{end}.level = 1;

%
% IGNORE THE NEXT FOUR FEATURES THERE WAS A CONFUSION. REGCOVN2 is
% EXACTLY the same and gives the correct results
%
% 71 -73
for level = 0:2
    f{end+1}.type = 'regcovn';
    f{end}.level = level;
end

% 74
f{end+1}.type = 'regcovn';
f{end}.level = 0:2;

for ijklm=75:86
    f{ijklm}.type = 'void';
end
clear ijklm

% 87:96
for indx=1:10
    f{end+1}.type = 'app';
    f{end}.channel = 'g';
    f{end}.level = 0;
    f{end}.K = 300;
    f{end}.oneForAll = indx;
end

% 97:106
for indx=1:10
    f{end+1}.type = 'void';
end

%107 the mean of the kernel matrices of features 87:97
f{end+1}.type = 'avg';
f{end}.avgInd = 87:96;

f{end+1}.type = 'void';

% 109:208
for indxWindow=1:100
    f{end+1}.type = 'app';
    f{end}.channel = 'g';
    f{end}.level = 0;
    f{end}.K = 300;
    f{end}.indxWindow = indxWindow;
    f{end}.oneForAll = 1;
    f{end}.depends = 309;
end

% 209:308
for indxWindow=1:100
   f{end+1}.type = 'void';
end

%309 mean over 100 subwindows using app_g
f{end+1}.type = 'avg';
f{end}.avgInd = 109:208;

%310 mean over 100 subwindows using app_c
f{end+1}.type = 'void';


%311: self similarity
f{end+1}.type = 'ssim';
f{end}.level = 0;

%312: average over shape pyramid 360_40 0:3
f{end+1}.type = 'avg';
f{end}.avgInd = 1:4;

%313: average over shape pyramid 180_20 0:3
f{end+1}.type = 'avg';
f{end}.avgInd = 5:8;

%314: average over appearance grey 0:3
f{end+1}.type = 'avg';
f{end}.avgInd = 29:32;

%315: average over appearance color 0:3
f{end+1}.type = 'avg';
f{end}.avgInd = 61:64;

%316: average over appearance LBP 0:2
f{end+1}.type = 'avg';
f{end}.avgInd = 66:68;

%317: average over appearance REGCOV 0:2
f{end+1}.type = 'avg';
f{end}.avgInd = 71:73;

% 318:321: H,S,V, sift stacked (3*128 dims)
for lev=0:3
    f{end+1}.type = 'app';
    f{end}.channel = 'colorstacked';
    f{end}.level = lev;
    f{end}.K = 300;
    f{end}.oneForAll = 1;
end

% 322:325: grey 1000 entries
for lev=0:3
    f{end+1}.type = 'app';
    f{end}.channel = 'g';
    f{end}.level = lev;
    f{end}.K = 1000;
    f{end}.oneForAll = 1;
end

% 326:329: H,S,V, sift stacked (3*128 dims)grey 1000 entries
for lev=0:3
    f{end+1}.type = 'app';
    f{end}.channel = 'colorstacked';
    f{end}.level = lev;
    f{end}.K = 1000;
    f{end}.oneForAll = 1;
end

% 330:429
for indxWindow=1:100
   f{end+1}.type = 'app';
   f{end}.channel = 'g';
   f{end}.K = 1000;
   f{end}.indxWindow = indxWindow;
   f{end}.depends = 630;
   f{end}.oneForAll = 1;
end

% 430:529
for indxWindow=1:100
   f{end+1}.type = 'app';
   f{end}.channel = 'colorstacked';
   f{end}.K = 300;
   f{end}.indxWindow = indxWindow;
   f{end}.depends = 631;
   f{end}.oneForAll = 1;
end

% 530:629
for indxWindow=1:100
   f{end+1}.type = 'app';
   f{end}.channel = 'colorstacked';
   f{end}.K = 1000;
   f{end}.indxWindow = indxWindow;
   f{end}.depends = 632;
   f{end}.oneForAll = 1;
end

%630 mean over 100 subwindows using app_g K = 1000
f{end+1}.type = 'avg';
f{end}.avgInd = 330:429;

%631 mean over 100 subwindows using app_c K = 300
f{end+1}.type = 'avg';
f{end}.avgInd = 430:529;

%632 mean over 100 subwindows using app_colorstacked K = 1000;
f{end+1}.type = 'avg';
f{end}.avgInd = 530:629;

% 633:642
for indx=1:10
    f{end+1}.type = 'app';
    f{end}.channel = 'colorstacked';
    f{end}.level = 0;
    f{end}.K = 300;
    f{end}.oneForAll = indx;
end

% 643:652
for indx=1:10
    f{end+1}.type = 'app';
    f{end}.channel = 'colorstacked';
    f{end}.level = 0;
    f{end}.K = 1000;
    f{end}.oneForAll = indx;
end

% 653:662
for indx=1:10
    f{end+1}.type = 'app';
    f{end}.channel = 'g';
    f{end}.level = 0;
    f{end}.K = 1000;
    f{end}.oneForAll = indx;
end

    %663:
f{end+1}.type = 'avg';
f{end}.avgInd = 633:642;

    %664:
f{end+1}.type = 'avg';
f{end}.avgInd = 643:652;

%665: average over 10 codebooks K=1000,grey
   f{end+1}.type = 'avg';
f{end}.avgInd = 653:662;

%666:669
for level = 0:3
    f{end+1}.type = 'app';
    f{end}.channel = 'g';
    f{end}.level = level;
    f{end}.K = 300;
    f{end}.oneForAll = 1;
end

% 670:673
for level = 0:3
    f{end+1}.type = 'phog';
    f{end}.angle = 180;
    f{end}.K = 20;
    f{end}.level = level;
end

% 674:677
for level = 0:3
    f{end+1}.type = 'phog';
    f{end}.angle = 360;
    f{end}.K = 40;
    f{end}.level = level;
end


%678 Phog Lev 0:3
f{end+1}.type = 'product';
f{end}.prodInd = 670:673;

%679 Phog 360, 40 Lev 0:3
f{end+1}.type = 'product';
f{end}.prodInd = 674:677;

% 680 Product of App - grey K = 300; lev 0:3
f{end+1}.type = 'product';
f{end}.prodInd = 666:669;
%f{end+1}.type = 'app';
%f{end}.channel = 'g';
%f{end}.level = 0:3;
%f{end}.K = 300;
%f{end}.oneForAll = 1;

% 681 Product of App -color - K=300 Lev 0:3
f{end+1}.type = 'product';
f{end} .prodInd = 318:321;
%f{end+1}.type = 'app';
%f{end}.channel = 'colorstacked';
%f{end}.level = 0:3;
%f{end}.K = 300;
%f{end}.oneForAll = 1;

% 682-685
for lev=0:3
    f{end+1}.type = 'rgsift';
    f{end}.level = lev;
    f{end}.K = 300;
end

%686
f{end+1}.type = 'rgsift';
f{end}.level = 0:3;
f{end}.K = 300;


%687
f{end+1}.type = 'v1plus';

%688
f{end+1}.type = 'v1plus_rbf';

% 689:691
for level = 0:2
    f{end+1}.type = 'regcovn_rbf';
    f{end}.level = level;
end

% 692
f{end+1}.type = 'product';
f{end}.prodInd = 689:691;

% 693: concatenation as in varma Shp+App 4+4+4+4 kernels
f{end+1}.type = 'product';
f{end}.prodInd = [670:673,674:677,318:321,666:669];

% 694:793
for i=1:100
    f{end+1}.type = 'phog';
    f{end}.angle = 360;
    f{end}.K = 40;
    f{end}.indxWindow = i;
    f{end}.depends = 794;
end

%794
f{end+1}.type = 'avg';
f{end}.avgInd = 694:793;

% 795:894
for i=1:100
    f{end+1}.type = 'phog';
    f{end}.angle = 180;
    f{end}.K = 20;
    f{end}.indxWindow = i;
    f{end}.depends = 895;
end

%895
f{end+1}.type = 'avg';
f{end}.avgInd = 795:894;


f{1000}.type= 'gb';
f{1001}.type= 'phowColor';
f{1001}.level = 0;
f{1002}.type= 'phowColor';
f{1002}.level = 1;
f{1003}.type= 'phowColor';
f{1003}.level = 2;

f{1004}.type= 'phowGray';
f{1004}.level = 0;
f{1005}.type= 'phowGray';
f{1005}.level = 1;
f{1006}.type= 'phowGray';
f{1006}.level = 2;

f{1007}.type= 'ssim';
f{1007}.level = 1;
f{1008}.type= 'ssim';
f{1008}.level = 2;
