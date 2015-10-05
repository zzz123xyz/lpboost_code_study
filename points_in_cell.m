% compute the indices of all points pts which fall into the cell
% c1,c2 of level l
%
%
function indx = points_in_cell(pts,c1,c2,l)


if l==0
    indx = 1:size(pts,1);
    return;
end

imsize = max(pts);

imsize = imsize/(2^l);

ind1 = find( (pts(:,1) <= c1*imsize(1)) & (pts(:,1) > (c1-1)*imsize(1)));
ind2 = find( (pts(:,2) <= c2*imsize(2)) & (pts(:,2) > (c2-1)*imsize(2)));

indx = intersect(ind1,ind2);

