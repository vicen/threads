function stats = get_stats(params)

% (REQUIRED) ---------------------------------------
% data should be the result of loading a compact_posts file 
if ~isfield(params, 'data'), disp('[get_stats] Data missing'); return;
else data = params.data; end

% (OPTIONAL) ---------------------------------------
% posts_idx is a vector of posts indices inside the data
if ~isfield(params, 'posts_idx'), posts_idx = [];
else posts_idx = params.posts_idx; end

% fileoutput string with filename to save the stats
if ~isfield(params, 'save_stats'), save_stats = false;
else save_stats = params.save_stats; end

% fileoutput string with filename to save the stats
if ~isfield(params, 'filename_res'), filename_res = 'stats.mat';
else filename_res = params.filename_res; end

% ---------------------------------------

cpost = data.cpost;
clevels = data.clevels;
max_depth=max([clevels{:}]);

disp('computing stats');
% select the posts
if isempty(posts_idx)
    cpost = data.cpost;
    clevels = data.clevels;
    np=numel(cpost);
else
    np=numel(posts_idx);
    cpost = cell(1,np);
    clevels = cell(1,np);
    for cp = 1:np
        cpost{cp} = data.cpost{posts_idx(cp)};
        clevels{cp} = data.clevels{posts_idx(cp)};
    end
end

% get sizes of all data
vsizes_data_total = zeros(1,np);
for p = 1:np
    vsizes_data_total(p) = numel(cpost{p});
end

% preselect posts
useit = true(1,np);
for p = 1:np
    if (numel(cpost{p}) <1)
        useit(p) = false;
    end
end
np = sum(useit);

fprintf('Considering %d posts\n', np);

subtree_sizes_level_data = cell(max_depth, np);
subtree_sizes_all_data = [];
degrees_data = cell(max_depth,np);
vdepths_data = zeros(1,np);
vtotaldepths_data = [clevels{useit}];
vprop_data = zeros(1,np);
vsizes_data = zeros(1,np);

idx = 1;
for p = 1:numel(cpost)
    if useit(p)
        if mod(p,1000)==0
        disp([num2str(p) '/' num2str(numel(cpost))]);
        end
        cpost0 = cpost{p};
        levels0 = clevels{p};
        cpost0 = cpost0-1;

        % get other stats
        thresh = 0;
        vmax = 0;
        if ~isempty(cpost0)
            [subtree_sizes_level_data subtree_sizes_all_data degrees_data vdepths_data(idx) vprop_data(idx) vsizes_data(idx)] = ...
                get_stats_cpost(idx, cpost0, levels0, subtree_sizes_level_data, subtree_sizes_all_data, degrees_data, thresh, vmax);
        end
        idx = idx+1;
    else
        %keyboard;
    end
end

stats.subtree_sizes_level_data = subtree_sizes_level_data;
stats.subtree_sizes_all_data = subtree_sizes_all_data;
stats.degrees_data = degrees_data;
stats.vdepths_data = vdepths_data;
stats.vtotaldepths_data = vtotaldepths_data;
stats.vprop_data = vprop_data;
stats.vsizes_data = vsizes_data;

disp(['file is ' filename_res]);

if save_stats
    save(filename_res, ...
        'subtree_sizes_level_data', ...
        'subtree_sizes_all_data', ...
        'degrees_data', 'vdepths_data', 'vprop_data', 'vsizes_data', ...
        'vsizes_data_total', 'vtotaldepths_data');
end
