function [xopt, fval, posts_idx] = ML_fit(params)

% (REQUIRED) ---------------------------------------
% data should be the result of loading a compact_posts file 
if ~isfield(params, 'data'), disp('[ML_fit_sampl] Data missing'); return;
else data = params.data; end

% comb should be one of the allowed combinations (REQUIRED)
if ~isfield(params, 'comb'), disp('[ML_fit_sampl] Combination missing'); return;
else comb = params.comb; end

% (OPTIONAL) ---------------------------------------
% posts_idx is a vector of posts indices inside the data
if ~isfield(params, 'posts_idx'), posts_idx = [];
else posts_idx = params.posts_idx; end

% next is the number of fminsearches with different rnd initial conditions
if ~isfield(params, 'nexp'), nexp = 3;
else nexp = params.nexp; end

% filename_res is the file where outputs are written
if ~isfield(params, 'filename_res'), filename_res = '';
else filename_res = params.filename_res; end

% thresh_opt is the threshold to check fminsearch convergence
if ~isfield(params, 'thresh_opt'), thresh_opt = 1e-04;
else thresh_opt = params.thresh_opt; end

% if prepare is true we assume that the following fields exist:
%   degreeki, sel_post, ispost, nposts, Tmin, sel_levels, ...;
% Otherwise, we compute them
if ~isfield(params, 'preprocessed'), preprocessed = false;
else preprocessed = true; end

% use authors 
if ~isfield(data, 'cauthors'), cauthors = {};
else cauthors = data.cauthors; end

% use authors 
if ~isfield(data, 'cauthorsrep'), cauthorsrep = {};
else cauthorsrep = data.cauthorsrep; end

% id of fit
if ~isfield(params, 'idfit'), idfit = 0;
else idfit = params.idfit; end

% --------------------------------------------------

deg0 = 1;
max_params = 10;
% filename_res = ['test_' comb '.txt'];%['output_' str_compact '_' comb '.txt']; 

% get handler to the corresponding Likelihood function
fname = sprintf('fun2min_ML_%s', comb);
if ~exist(fname, 'file')
    fname2 = ['thread_' comb '_lik'];
    fname = 'generic_fun2min_ML';
    if ~exist(fname2, 'file')
        disp('error: no fun2min found');
        xopt = []; fval = [];
        return
    else
        disp(['found ' fname2]);
    end
end
disp(['using ' fname]);
% cmd=sprintf('handle_fmin = @%s;',fname);
% eval(cmd);

% get number of required parameters
num_params = get_numparams(comb);

% select the posts
if isempty(posts_idx)
    posts_idx = 1:numel(data.cpost);
    cpost = data.cpost;
    clevels = data.clevels;
    np=numel(cpost);
else
    np=numel(posts_idx);
    cpost = cell(1,np);
    clevels = cell(1,np);
    cauthors = cell(1,np);
    for cp = 1:np
        cpost{cp} = data.cpost{posts_idx(cp)};
        clevels{cp} = data.clevels{posts_idx(cp)};
        if isfield(data,'cauthors')
            cauthors{cp} = data.cauthors{posts_idx(cp)};            
        end
        if isfield(data,'cauthorsrep')
            cauthorsrep{cp} = data.cauthorsrep{posts_idx(cp)};
        end
    end
end

if strcmp(fname,'generic_fun2min_ML')
    vsizes_data = zeros(1,numel(cpost));
    for p=1:numel(cpost)
        vsizes_data(p) = numel(cpost{p});
    end
    params.prep = struct('Tmin', min(vsizes_data(vsizes_data>1)), ...
        'Tmax', min(2000,max(vsizes_data)));
    fprintf('Fitting %d posts with [%d-%d] comments\n', numel(cpost), ...
        params.prep.Tmin, params.prep.Tmax);
elseif ~preprocessed
    params.prep = prepare_ML_fit(params);
end

% perform nexp fits
% initialization of the first experiment only
xopt = zeros(max_params,nexp);%get_numparams(comb),

%------------
vtype = get_type_params(comb);
xini = get_initial_conditions(vtype, nexp);
%------------

pf = params.prep;

% for the generic optimization
pf.comb = comb;
pf.data.post = cpost;
% if iscell(cauthors{1})
for p = 1:numel(cauthors)
    [~,~,c] = unique([cauthorsrep{p}(1) cauthors{p}]);
    pf.data.post{p} = [-42 pf.data.post{p}];
    pf.data.author{p} = c';
end

%% filter invalid posts (TEMPORARY HACK!!!!...)
%% We need to discard (for the moment) those posts that have a comment that 
%% replies to the same comment more than once (including post) or we an author
%% replies to itself OR the same author writes two consecutive comments
if strcmp(fname,'generic_fun2min_ML')
    
    pf.hndfmin = str2func(fname2);

    valids = zeros(1,numel(pf.data.post));
    clear vliks;
    vliks = cell(1,1);
    if ~isempty(posts_idx)
        nn = 0;
        Tmin = 1000;
        Tmax = -1000;
        new_posts_idx = zeros(1,numel(pf.data.post));
        reported = false;
        nc = zeros(1,numel(pf.data.post));
        for k = 1:numel(pf.data.post)
            nc(k) = numel(pf.data.post{k});
        end
        [ncs, inc] = sort(nc,'descend');
        for k = 1:numel(pf.data.post)  
            if k==91
                keyboard;
            end
           
            %vlik = pf.hndfmin(numel(pf.data.post{k})-1, xini(1:num_params, 1), {pf.data.post{k}, pf.data.author{k}});
            vlik = pf.hndfmin(numel(pf.data.post{inc(k)})-1, xini(1:num_params, 1), {pf.data.post{inc(k)}, pf.data.author{inc(k)}});
            numel(vlik)

            % make a file with selected posts
            deb.post{k} = pf.data.post{inc(k)};
            deb.sizes{k} = numel(deb.post{k});
            deb.auth{k} = pf.data.author{inc(k)};
            deb.liks{k} = vlik;

            vliks{inc(k)} = vlik;
            if ~any(vlik(3:end)==-1)
                nn = nn+1;
                valids(inc(k)) = true;
                new_posts_idx(nn) = posts_idx(inc(k));
                pf.data.post2{nn} = pf.data.post{inc(k)};
                pf.data.author2{nn} = pf.data.author{inc(k)};
                nc = numel(pf.data.post{inc(k)});
                if nc < Tmin 
                    Tmin = nc;
                end
                if nc > Tmax
                    Tmax = nc;
                end
            else
                if ~reported
                    display('Filtering...');
                    reported  = true;
                end
            end
        end
        if nn<10
            display('Less than 10 posts selected! Exiting...');
            fval = Inf;
            return
        end
        new_posts_idx(nn+1:end) = [];
        pf.data.post = pf.data.post2;
        pf.data.author = pf.data.author2;
        np = numel(pf.data.post);
        pf.Tmin = Tmin-1;
        pf.Tmax = Tmax-1;
        fprintf('Reduced to %d posts with [%d-%d] comments\n', nn, pf.Tmin, pf.Tmax);
        posts_idx = new_posts_idx;
        
        save('debug.mat','deb');
    end
end
%% END OF HACK

% perform nexp estimates with random initial conditions
xoptex = cell(1,nexp);
fvalex = cell(1,nexp);
exitflagex = cell(1,nexp);
for ex = 1:nexp
    
    handle_fmin = str2func(fname);
    old_options=optimset('fminsearch');
    newoptions=optimset(old_options,'MaxFunEvals',5e3,'MaxIter',3e3,'TolFun',thresh_opt,'TolX',thresh_opt);%,'Display','iter');

    % optimization
    x0 = xini(1:num_params, ex);
    x0 = x0(1:get_numparams(comb));
    
    %x0 = [1.3, .8, 3.1]';
    tic;
    [x, fvalex{ex}, exitflagex{ex}, ~] = fminsearch(@(x) handle_fmin(x, pf), x0, newoptions);
    tim = toc;
    fprintf('\t[%d/%d] %s\n\t\tx0 = %s\n\t\tx  = %s\n', ex, nexp, filename_res, num2str(x0'), num2str(x'));
    fprintf('\t\tloglik = %e\n',fvalex{ex});
    disp([num2str(tim) ' secs']);
    xoptex{ex} = padarray(x, max_params-num_params, 0, 'post');

    % dump results
    if ~isempty(filename_res)
        fid = fopen(filename_res, 'a');
        fprintf(fid, '%f ', [xoptex{ex}(1:end-1)' idfit fvalex{ex} exitflagex{ex} tim ex pf.Tmin pf.Tmax np]);
        fprintf(fid, '\n');
        fclose(fid);    
    end
end
fval = zeros(1,nexp);
exitflag = zeros(1,nexp);
for ex = 1:nexp
    xopt(1:get_numparams(comb),ex) = xoptex{ex}(1:get_numparams(comb));
    fval(ex) = fvalex{ex};
    exitflag(ex) = exitflagex{ex};    
end

