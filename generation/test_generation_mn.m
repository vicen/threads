clear all;
addpath(genpath('.'));

% compute stats real data
p.data = load('data/mn/2011-01.mat');
p.save_stats = true;
p.filename_stats = 'mn-2011-01';

get_stats(p);

% compute synt threads and compare
p.comb = 'FULL_MODEL';
p.xopt = [.5 .1 1];
p.N = 100;
p.str_compact = 'mn-2011-01';
p.do_plots = true;
p.save_synt = true;
p.save_stats = true;

test_model(p);
