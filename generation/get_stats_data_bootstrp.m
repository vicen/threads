function samples = get_stats_data_bootstrp(str_compact, N, boots, quant)

% str_compact = 'bp_ok';
% N = 5e4;

% load data
dirdata = '../data/';
disp(['loading ' dirdata 'compact_posts_' str_compact '.mat']);
data = load([dirdata 'compact_posts_' str_compact '.mat']);

% get sizes
vsizes_data = zeros(1,numel(data.cpost));
for p=1:numel(data.cpost)
    vsizes_data(p) = numel(data.cpost{p});
end

% filter posts with less than quant% of cmnts
Ns = quantile(vsizes_data, quant);
[c,d] = find(vsizes_data>=Ns);
data2.cpost = cell(1,numel(d));
data2.clevels= cell(1,numel(d));
for p=1:numel(d)
    data2.cpost{p} = data.cpost{d(p)};
    data2.clevels{p} = data.clevels{d(p)};
end

% get a random subset of size N
if boots
    fprintf('Sampling with replacement %d posts\n', N);
    samples = randsample(1:numel(data2.cpost), N, true);
else
    samples = 1:numel(data2.cpost);
end

p = [];
p.data = data;
p.posts_idx = samples;
p.save_stats = true;
p.filename_res = [dirdata 'stats_' str_compact '_bootstrp' num2str(N) '_quant' num2str(quant) '.mat'];
get_stats(p);

