function res = test_all(p)

    %   Required fiels for parameters
    %   data_path:      directory of data and results
    %   str_compact:    name of the file with data (without .mat)
    %   comb:           model (e.g. 'FULL_MODEL' or 'FULL_MODEL_AUTHORS_0')
    %   'FULL_MODEL_AUTHORS_0' is the model with reciprocity
    %   xopt:           parameters of the model ([] if unspecified)
    %   estimate:       true for ML estimation
    %   compare:        true for comparison between data and model
    %   validate:       true for model validation
    %   do_plots:       true if plots when comparing data with model
    %
    %   Possible uses:
    %
    %   for estimating parameters given data
    %   ex with barrapunto: p.comb = 'FULL_MODEL';  p.xopt = []; p.validate = false; p.estimate = true; p.compare = false; p.do_plots = false; p.data_path = 'data/'; p.str_compact = 'compact_posts_bp_ok';
    %   ex with meneame:    p.comb = 'FULL_MODEL_AUTHORS_0'; p.xopt = []; p.validate = false; p.estimate = true; p.compare = false; p.do_plots = false; p.data_path = 'data/'; p.str_compact = '2015-03';
    
    %   for comparing fitted model with data
    %   estimate = false, compare = true, validate = false, do_plots = true
    %   ex with barrapunto: p.comb = 'FULL_MODEL'; p.xopt = [0.97,0.077,0.92]; p.validate = false; p.estimate = false; p.compare = true; p.do_plots = true; p.data_path = 'data/'; p.str_compact = 'compact_posts_bp_ok';
    %   ex with meneame:    p.comb = 'FULL_MODEL_AUTHORS_0'; p.xopt = [2.27, 0.30, 0.78, 5.15]; p.validate = false; p.estimate = true; p.compare = false; p.do_plots = true; p.data_path = 'data/'; p.str_compact = '2015-03';
    %
    %   for validating the model, e.g. fitting paramters to artificial data
    %   generated with given parameters
    %   estimate = false, compare = false, validate = true, do_plots = false
    %   ex with barrapunto: p.comb = 'FULL_MODEL';  p.xopt = [0.97,0.077,0.92]; p.validate = true; p.estimate = false; p.compare = false; p.do_plots = false; p.data_path = ''; p.str_compact = '';
    %   ex with meneame:    p.comb = 'FULL_MODEL_AUTHORS_0'; p.xopt = [2.27, 0.30, 0.78, 5.15]; p.validate = true; p.estimate = false; p.compare = false; p.do_plots = false; p.data_path = 'data/'; p.str_compact = '2015-03';
    
    
    if exist('ML_fit','file') ~= 2
        disp('Adding path...');
        addpath('./common')
        addpath('./estimation')
        addpath('./generation')
       % genpath(addpath('.'));
    end
    res = [];
    
    data_path = p.data_path;
    comb = p.comb;
    str_compact = p.str_compact;
    xopt = p.xopt;
    estimate = p.estimate;
    validate = p.validate;
    compare = p.compare;
    do_plots = p.do_plots;
    if ~isfield(p,'posts_idx')
        posts_idx = [];
    else
        posts_idx = p.post_idx;
    end
            
    if isempty(str_compact) && isempty(xopt)
        disp('error: specify either xopt or data in str_compact');
    end
    
    %% perform ML fit to the data
    if estimate 
        disp('- ML FIT -------------------------------------------------');
        data_file = [data_path str_compact '.mat'];
        res_file = [data_path 'res_' str_compact '_' comb '.txt'];
        pf = create_params_mlfit(data_file, comb, 5, res_file, 1e-10);

        pf.posts_idx = posts_idx;
        pf.nexp = 6;
        [A, fval] = ML_fit(pf);
        if pf.nexp > 1
            xopt = A(:,fval==min(fval));
        end
        xopt_file = [data_path 'xopt_' str_compact '_' comb '.mat'];
        disp(['saving xopt in ' xopt_file]);
        save(xopt_file, 'xopt');
    else
        
        % no need to perform ML fit to the data
        if ~isempty(str_compact)
            
            % load xopt from previous ML fit
            xopt_file = [data_path 'xopt_' str_compact '_' comb '.mat'];
            disp(['loading xopt from ' xopt_file]);
            if exist(xopt_file,'file')
                load(xopt_file);
            end
        else
            if isempty(xopt)
                disp('generating xopt randomly');
            end
        end
    end
    
    %% generate syntetic threads if we want to compare or validate the model
    if compare || validate
        
        % compute stats real data
        if ~isempty(str_compact) && ~isempty(data_path)

            disp('- GET STATS ----------------------------------------------');
            file_data = [data_path str_compact '.mat'];
            file_res = [data_path 'stats_' str_compact '.mat'];
            p = params_stats(file_data, file_res);
            get_stats(p);
        end

        disp('- TEST MODEL -------------------------------------------------');
        p = params_test(comb, xopt, 1000, data_path, str_compact, do_plots, true, true);
        res = test_model(p);
    end
    
    %% validate the model doing ML fit on the syntetic threads
    % (check the ML estimates of synt coincide with xopt from data)
    if validate
        
        disp('- VALIDATE MODEL -----------------------------------------');
        file_posts = [data_path 'compact_posts_synt_' str_compact '_' comb '.mat'];
        disp(['loading posts from ' file_posts]);
        p.data = load(file_posts);
        p.thresh_opt = 1e-8;
        p.comb = comb;
        p.nexp = 6;
        p.filename_res = ['test_all_synt_' str_compact '_' comb '.txt'];
        [A, ~] = ML_fit(p);
    end
end

function p = create_params_mlfit(str, comb, nexp, str2, thresh)
    p.data = load(str);
    p.comb = comb;
    p.nexp = nexp;
    p.filename_res = str2;
    p.thresh = thresh;
end

function p = params_stats(file_data, file_res)
    p.data = load(file_data);
    p.save_stats = true;
    p.filename_res = file_res;
end

function p = params_test(str_model, xopt, N, data_path, str_compact, do_plots, save_synt, save_stats)
    p.comb = str_model;
    p.xopt = xopt;
    p.N = N;
    p.data_path = data_path;
    p.str_compact = str_compact;
    p.do_plots = do_plots;
    p.save_synt = save_synt;
    p.save_stats = save_stats;
end


% % chooses most frequent solution
%         A = round((A*1000))./1000;
%         A = A';
%         if p.nexp > 1
%             [sols, counts] = grpstats(A,A(:,1),{'mean','numel'});
%             if size(sols,1)>1
%                 fprintf('\tfound %d solutions... too little data?\n\tconsider decreasing thresh_opt\n', size(sols,1));
%                 sols
%                 fprintf('\tcounts\n');
%                 disp(counts(:,1));
%                 [~,im] = max(counts(:,1));
%                 xopt = sols(im,:);
%             else
%                 xopt = A(1,1:end);
%             end
%         else
%             xopt = A(1,1:end);
%         end
    