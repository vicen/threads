function data_synt = test_model(params) 

% (REQUIRED) ---------------------------------------
% comb should be one of the allowed combinations (REQUIRED)
% Possible combinations: 

% [{'nobias_tau_PAprod'},{'nobias_tau_PAexp'},{'nobias_tau_noPA'},...
%         {'biasprod_tau_PAprod'},{'nobias_notau_PAexp'},{'nobias_notau_PAprod'},...
%         {'biasexp_notau_PAexp'},{'biasexp_tau_PAexp'},{'biasexp_tau_PAprod'}];

if ~isfield(params, 'comb'), disp('[test_model] Combination missing'); return;
else comb = params.comb; end

% xopt should be parameters of respective comb
if ~isfield(params, 'xopt'), disp('[test_model] Parameters missing'); return;
else xopt = params.xopt; end

% (OPTIONAL) ---------------------------------------
% N number of posts to generate
if ~isfield(params, 'N'), N = 2e3; return;
else N = params.N; end

% str_compact is string of respective dataset in data dir, ej 'bp_ok'
if ~isfield(params, 'str_compact'), str_compact = ''; 
else str_compact = params.str_compact; end

% do_plots true for plotting comparison (REQUIRED is str_compact)
if ~isfield(params, 'do_plots'), do_plots = false; 
else do_plots = params.do_plots; end

% save_synt for saving compact_posts_synt_ 
if ~isfield(params, 'save_synt'), save_synt = false; 
else save_synt = params.save_synt; end

% save_stats for saving stats_synt_synt_ 
if ~isfield(params, 'save_stats'), save_stats = false; 
else save_stats = params.save_stats; end

% --------------------------------------------------

% clear;
fname = sprintf('thread_%s', comb);
% deg0 = 1;
% do_plots=1;
% save_synt =true;
figs_dir = 'figures/';

% get handler to the model function
disp(['using ' fname]);
cmd=sprintf('handle_fthread = @%s;',fname);
eval(cmd);

% load data stats - generated using ./get_stats_data.m
if ~isempty(str_compact)
    %dirdata = '../../prob_post/';
    dirdata = '../data/';
    file_data_stats = [dirdata 'stats_' str_compact '.mat'];
    fprintf('dataset is %s\n', str_compact);
    fprintf(['loading ' file_data_stats ' ... ']);
    data_stats = load(file_data_stats);
    fprintf('done\n');
    vsizes_model = generate_numcomments(N, data_stats.vsizes_data);
else
    fprintf('generating posts sizes...');
    vsizes_model=nonzeros(round(exp(4+randn(1,N))));
    tries = 1;
    while (numel(vsizes_model) ~= N) && (tries < 10)
        vsizes_model=nonzeros(round(exp(4+randn(1,N))));
        tries = tries + 1;
    end
    fprintf('done\n');
    N = numel(vsizes_model);
end
fprintf('simulating %d posts\n', N);

% generate threads
subtree_sizes_level_model = cell(20,N);
degrees_model = cell(20,N);
vdepths_model = zeros(1,N);
vprop_model = zeros(1,N);

thresh = 1;
tic;
errs = 0;
for p = 1:N
    [cpost{p}, clevels{p}] = handle_fthread(vsizes_model(p), xopt);
    
    % transform the post for statistics
    cpost{p} = cpost{p}(2:end);
    clevels{p} = clevels{p}(2:end);
    apost = cpost{p}-1;
    alevel = clevels{p};

    % get other stats is necessary
    if save_stats || do_plots
        subtree_sizes_all_model = [];
        stree_stats.vmax = [];
        [subtree_sizes_level_model subtree_sizes_all_model degrees_model vdepths_model(p) vprop_model(p)] = ...
            get_stats_cpost(p, apost, alevel, subtree_sizes_level_model, subtree_sizes_all_model, degrees_model, thresh, stree_stats.vmax);
    end
end
toc;
vtotal_depths_model = [clevels{:}];
fprintf('%d threads generated in %.2f scnds (%d errors)\n', N, toc, errs);



model_stats=[];
% save stats
model_stats.subtree_sizes_level_model = subtree_sizes_level_model;
model_stats.subtree_sizes_all_model = subtree_sizes_all_model;
model_stats.degrees_model = degrees_model;
model_stats.vdepths_model = vdepths_model;
model_stats.vprop_model = vprop_model;
model_stats.vsizes_model = vsizes_model;
model_stats.vtotaldepths_model = vtotal_depths_model;
model_stats.comb = comb;
model_stats.xopt = xopt;

model_stats.dataset = dataset;
model_stats.str_compact = str_compact;
model_stats.N = N;
    
if save_stats
    % save stats
    stats_outfile = ['../data/stats_synt_' str_compact '_' comb '.mat'];
    disp(['saving stats posts in ' stats_outfile]);
    save(stats_outfile, 'model_stats');
end

if save_synt
    % save generated threads
    cposts_outfile = ['../data/compact_posts_synt_' str_compact '_' comb '.mat'];
    disp(['saving compact posts in ' cposts_outfile]);
    save(cposts_outfile, 'cpost', 'clevels', 'xopt', 'N');
end

data_synt.cpost = cpost;
data_synt.clevels = clevels;
data_synt.xopt = xopt;
data_synt.N = N;
data_synt.model_stats = model_stats;

if do_plots && ~isempty(str_compact)
    plot_comparison_global(model_stats, data_stats, comb) 
    
    filename_str = [str_compact '_N' num2str(N) '_' comb '.pdf'];
    h=figure(1);saveas(h,[figs_dir '1st_level_' filename_str]);
    h=figure(2);saveas(h,[figs_dir 'Nst_level_' filename_str]);
    h=figure(3);saveas(h,[figs_dir 'correl_' filename_str]);
    h=figure(4);saveas(h,[figs_dir 'mdepth_' filename_str]);
    h=figure(5);saveas(h,[figs_dir 'all_deg_sub_' filename_str]);
end
