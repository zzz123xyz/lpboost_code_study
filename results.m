clear str; clear featnum;

str{1} = 'SIFT grey 1000: Level 0';featnum(1,1) = 322;
str{2} = 'SIFT grey 1000: Level 1';featnum(2) = 323;
str{3} = 'SIFT grey 1000: Level 2';featnum(3) = 324;
str{4} = 'SIFT grey 1000: Level 3';featnum(4) = 325;

str{5} = 'SIFT color 1000: Level 0';featnum(5) = 326;
str{6} = 'SIFT color 1000: Level 1';featnum(6) = 327;
str{7} = 'SIFT color 1000: Level 2';featnum(7) = 328;
str{8} = 'SIFT color 1000: Level 3';featnum(8) = 329;

str{9} = 'SIFT grey 300: Level 0';featnum(9) = 666;
str{10} = 'SIFT grey 300: Level 1';featnum(10) = 667;
str{11} = 'SIFT grey 300: Level 2';featnum(11) = 668;
str{12} = 'SIFT grey 300: Level 3';featnum(12) = 669;

str{13} = 'SIFT color 300: Level 0';featnum(13) = 318;
str{14} = 'SIFT color 300: Level 1';featnum(14) = 319;
str{15} = 'SIFT color 300: Level 2';featnum(15) = 320;
str{16} = 'SIFT color 300: Level 3';featnum(16) = 321;

str{17} = 'SIFT grey 1000 (averaged 100 windows)';featnum(17) = 630;
str{18} = 'SIFT color 1000 (averaged 100 windows)';featnum(18) = 632;

str{19} = 'SIFT grey 300 (averaged 100 windows)';featnum(19) = 309;
str{20} = 'SIFT color 300 (averaged 100 windows)';featnum(20) = 631;

%str{21} = 'SIFT grey 1000 (averaged 10 codebook)';featnum(21) = 665;
%str{22} = 'SIFT color 1000 (averaged 10 codebook)';featnum(22) = 664;

%str{23} = 'SIFT grey 300 (averaged 10 codebook)';featnum(23) = 107;
%str{24} = 'SIFT color 300 (averaged 10 codebook)';featnum(24) = 663;

str{21} = 'PHOG, 180,20: Level 0';featnum(21) = 670;
str{22} = 'PHOG, 180,20: Level 1';featnum(22) = 671;
str{23} = 'PHOG, 180,20: Level 2';featnum(23) = 672;
str{24} = 'PHOG, 180,20: Level 3';featnum(24) = 673;

str{25} = 'PHOG, 360,40: Level 0';featnum(25) = 674;
str{26} = 'PHOG, 360,40: Level 1';featnum(26) = 675;
str{27} = 'PHOG, 360,40: Level 2';featnum(27) = 676;
str{28} = 'PHOG, 360,40: Level 3';featnum(28) = 677;

str{29} = 'LBP: Level 0';featnum(29) = 66;
str{30} = 'LBP: Level 1';featnum(30) = 67;
str{31} = 'LBP: Level 2';featnum(31) = 68;

str{32} = 'Regcov: Level 0';featnum(32) = 689;
str{33} = 'Regcov: Level 1';featnum(33) = 690;
str{34} = 'Regcov: Level 2';featnum(34) = 691;

str{35} = 'PHOG, 180,20: Level 0:3';featnum(35) = 678;
str{36} = 'PHOG, 360,40: Level 0:3';featnum(36) = 679;

str{37} = 'SIFT grey 300 Level 0:3';featnum(37) = 680;
str{38} = 'SIFT color 300 Level 0:3';featnum(38) = 681;

str{39} = 'LBP: Level 0:2';featnum(39) = 69;

str{40} = 'Regcov: Level 0:2';featnum(40) = 692;
str{41} = 'V1+ gauss';featnum(41) = 688;

str{42} = 'Varma combination Phog+App (16 kernels) (41)';featnum(42) = 693;

% The following features turned out to have problems with the
% grey-level images. In this case the descriptor always looks like
% [f,0,0] with f being the descriptor for the grey image
%str{45} = 'rg-SIFT HarLap Level 0';featnum(45) = 682;
%str{46} = 'rg-SIFT HarLap Level 1';featnum(46) = 683;
%str{47} = 'rg-SIFT HarLap Level 2';featnum(47) = 684;
%str{48} = 'rg-SIFT HarLap Level 3';featnum(48) = 685;

%str{49} = 'rg-SIFT HarLap Level 0:3';featnum(49) = 686;

assert(numel(str)==numel(featnum));
