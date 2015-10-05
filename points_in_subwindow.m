function indx = points_in_subwindow(pts,window_lr,window_ul);

imsize = double(max(pts));

assert(all(window_lr<=1));
assert(all(window_ul<=1));
assert(all(window_lr>=0));
assert(all(window_ul>=0));


lr = ceil(window_lr .* imsize);
ul = ceil(window_ul .* imsize);

ul(ul==0) = 1;
lr(1) = min(lr(1),imsize(1));
lr(2) = min(lr(2),imsize(2));


ind1 = find(pts(:,1) >= ul(1) & pts(:,1) <= lr(1));
ind2 = find(pts(:,2) >= ul(2) & pts(:,2) <= lr(2));

indx = intersect(ind1,ind2);

