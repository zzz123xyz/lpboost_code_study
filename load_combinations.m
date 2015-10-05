% load_combinations
%
% script file which creates a variable 'combination' which is a
% cell array. Each cell entry corresponds to one combination of
% features, the elements in each cell to the feature index as
% specified by load_features.m
%
% ATTENTION: only add combinations at the end
%
% 18.03.09 Peter Gehler

clear combination;

combination{1} = [];
combination{2} = [];
combination{3} = [];
combination{4} = [];
combination{5} = [];
combination{6} = [];
combination{7} = [];
combination{8} = [];
combination{9} = [];
combination{10} = [];
combination{11} = [66,67,68]; % LBP, 0,1,2
combination{12} = [];
combination{13} = [];
combination{14} = [];
combination{15} = [];
combination{16} = [];
combination{17} = [71:73]; % regcovn (linear kernel deprecated)
combination{18} = [];
combination{19} = [];
combination{20} = [];
combination{21} = [];
combination{22} = [];
combination{23} = [];
combination{24} = [];

combination{25} = [312:317]; % all kernels using averaged pyramids
combination{26} = [312:315]; % SHAPE+APP averaged kernels

combination{27} = [318:321]; %SIFT color Lev0:3, K=300
combination{28} = [322:325]; %SIFT grey Lev0:3, K=1000
combination{29} = [326:329]; %SIFT color Lev0:3, K=1000
combination{30} = [666:669]; %SIFT grey Lev0:3, K=300


combination{31} = [670:673]; %PHOG 180 K 20 Lev0:3
combination{32} = [674:677]; %PHOG 360 K40 Lev 0:3

combination{33} = [320,324,328,668,672,676,68,691]; % From every pyr Level 2

combination{34} = [682:685]; %rg-SIFT HarLap all levels

combination{35} = [];
combination{36} = [];
combination{37} = [];
combination{38} = [];

% best shot! all color, all grey, 300,1000, all Phogs 180,360, LBP,
% Regcov, all levels and all stacked + averaged over subwindows grey+color,K=1000
combination{39} = [318:321,322:325,326:329,666:669,670:673,674:677,66:68,689:691,681,680,679,678,692,69,630,632,688];

combination{40} = [689:691]; % regcovn

% Varma setting:
combination{41} = [670:673,674:677,318:321,666:669];


% those elements which were selected at least three times across
% all experiments from combination{39} (20 features)
combination{42} = combination{39}([1,5,9,12,13,17,18,19,20,21,25,27,28,29,30,34,35,37,38,39]);


% all vgg-mkl matrices (GB. SSIM, phowCOlor, phowGray)
combination{43} = [1000:1008];
combination{44} = [combination{39},combination{43}];


