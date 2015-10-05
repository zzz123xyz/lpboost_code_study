% str = explain_feature(f)
%
% computes a description string 'str' for feature 'f'
function str = explain_combination(f)

switch f
 case 1
  str = 'Shape360,Level0:3';
 case 2
  str = 'Shape180,Level0:3';
 case 3
  str = 'Shp360,all pyramid bins';
 case 4
  str = 'Shp360, complete pyramid';
 case 5
  str = 'Appg,Level0:2';
 case 11
  str = 'LBP:Level0:2';
 case 13
  str = 'AppG,Level0:3';
 case 17
  str = 'Regcov, Level 0:2';
 case 18
  str = 'Shp306+180,AppG+C,Level0:3 (16kernels)';
 case 21
  str = 'Shp306+180,AppG+C,Level0:3;Regcov,LBP,Level0:2 (22kernels)';
 case 23
  str = 'Shp306+180,AppG+C,Level0:3;Regcov,LBP,Level0:2+stacked (28kernels)';
 case 25
  str = 'Shp,App,LBP,regcov, pyramid levels averaged (6 kernels)';
 case 26
  str = 'Shp,App pyramid levels averaged (4 kernels)';
 case 27
  str = 'HSV-SIFT K300, Lev 0:3 (4 kernels)';
 case 28
  str = 'SIFT K1000, Lev 0:3 (4 kernels)';
 case 29
  str = 'HSV-SIFT K1000, Lev 0:3 (4 kernels)';
 case 30
  str = 'SIFT K300, Lev 0:3 (4 kernels)';
 case 31
  str = 'PHOG 180 K20 Levl 0:3 (4 kernels)';
 case 32
  str = 'PHOG 360 K40 Levl 0:3 (4 kernels)';
 case 33
  str = 'Level 2 of every feature';
 case 34
  str = 'rg-SIFT all levels';
 case 35
  str = 'The best shot!';
 case 37
 str = 'old best shot, do not use';
 case 38
  str = 'old best shot, do not use';
 case 39
  str = 'The best shot! incl gauss V1|';
 case 40
 str = 'Regcov Lev 0;2, (rbf)';
 case 41
 str = 'Phog+App (Varma)';
 case 43
 str = 'oxford kernels (ssim,gb,phowColor,phowGray)';
 case 44
 str = 'best shot + oxford kernels';
end
