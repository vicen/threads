function data_synt = sample_model(params)

% (REQUIRED) ---------------------------------------
% comb should be one of the allowed combinations (REQUIRED)
% Possible combinations: 

% 2.39, 0.31, 0.98
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

% vsizes_model distribution of sizes (Binomial with parameters plength[1] and plength[2])
if ~isfield(params, 'plength'), plength(1) = 1e2; plength(2) = .9;
else plength = params.plength; end

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

% generate sizes. Binomial with params sizes[1] and sizes[2]
vsizes_model = binornd(plength(1),plength(2),1,N);

% generate threads
subtree_sizes_level_model = cell(20,N);
degrees_model = cell(20,N);
vdepths_model = zeros(1,N);
vprop_model = zeros(1,N);

thresh = 1;
tic;
errs = 0;
for p = 1:N
    [spost{p}, slevels{p}] = handle_fthread(vsizes_model(p), xopt);

    % transform the post for statistics
    spost{p} = spost{p}(2:end);
    slevels{p} = slevels{p}(2:end);
    apost = spost{p}-1;
    alevel = slevels{p};

    % get other stats is necessary
    if save_stats || do_plots
        subtree_sizes_all_model = [];
        stree_stats.vmax = [];
        [subtree_sizes_level_model subtree_sizes_all_model degrees_model vdepths_model(p) vprop_model(p)] = ...
            get_stats_spost(p, apost, alevel, subtree_sizes_level_model, subtree_sizes_all_model, degrees_model, thresh, stree_stats.vmax);
    end
end
toc;
vtotal_depths_model = [slevels{:}];
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

model_stats.N = N;
    
if save_stats
    % save stats
    stats_outfile = ['../data/stats_synt_' str_compact '_' comb '.mat'];
    disp(['saving stats posts in ' stats_outfile]);
    save(stats_outfile, 'model_stats');
end

if save_synt
    % save generated threads
    sposts_outfile = ['../data/compact_posts_synt_' str_compact '_' comb '.mat'];
    disp(['saving compact posts in ' sposts_outfile]);
    save(sposts_outfile, 'spost', 'slevels', 'xopt', 'N');
end

data_synt.spost = spost;
data_synt.slevels = slevels;
data_synt.xopt = xopt;
data_synt.N = N;
data_synt.model_stats = model_stats;
