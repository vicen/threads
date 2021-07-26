function prep = prepare_ML_fit(params)

% (REQUIRED) ---------------------------------------
% data should be the result of loading a compact_posts file 
if ~isfield(params, 'data'), disp('[ML_fit_sampl] Data missing'); return;
else data = params.data; end

% (OPTIONAL) ---------------------------------------
% posts_idx is a vector of posts indices inside the data
if ~isfield(params, 'posts_idx'), posts_idx = [];
else posts_idx = params.posts_idx; end

% --------------------------------------------------
deg0=1;
% select the posts
if isempty(posts_idx)
    cpost = data.cpost;
    clevels = data.clevels;
    if isfield(data,'cauthors')
        cauthors = data.cauthors;
    end
    np=numel(cpost);
else
    np=numel(posts_idx);
    cpost = cell(1,np);
    clevels = cell(1,np);
    for cp = 1:np
        cpost{cp} = data.cpost{posts_idx(cp)};
        clevels{cp} = data.clevels{posts_idx(cp)};
         if isfield(data,'cauthors')
            cauthors{cp} = data.cauthors{posts_idx(cp)};
        end       
    end
end

tic
vsizes_data = zeros(1,numel(cpost));
for p=1:numel(cpost)
    vsizes_data(p) = numel(cpost{p});
end
Tmin = min(vsizes_data(vsizes_data>1));
Tmax = min(2000,max(vsizes_data));

fprintf('Fitting %d posts with [%d-%d] comments\n', np, Tmin, Tmax);

% group posts per size
nposts = zeros(1,Tmax);
sel_authors = cell(1,Tmax);
%sel_probs = cell(1,Tmax);
for p = 1:numel(cpost);
    numcmnts = numel(cpost{p});
    if (numcmnts>=Tmin) && (numcmnts<=Tmax)
        nposts(numcmnts) = nposts(numcmnts) + 1;
        sel_post{numcmnts}(:,nposts(numcmnts)) = cpost{p};
        sel_levels{numcmnts}(:,nposts(numcmnts)) = clevels{p};
       
        %% for debugging [
%         sel_probs{numcmnts}(:,nposts(numcmnts)) = params.data.cprobs{p};
%         sel_cZs{numcmnts}(:,nposts(numcmnts)) = params.data.cZs{p};
%         sel_cforb{numcmnts}(:,nposts(numcmnts),:) = params.data.cforb{p};
        %% for debugging ]
        
        if isfield(data,'cauthors')
            if ~isempty(cauthors{p})
                sel_authors{numcmnts}(:,nposts(numcmnts)) = cauthors{p};
            end
        end
    end
end
fprintf('selecting %d posts\n', sum(nposts));

tic;

% degrees at all time-steps
% degrees(k,t,i) is the degree of node k at time t in thread i 
for T = Tmin:Tmax
    degrees{T} = zeros(T+1,T,nposts(T));
    for p = 1:nposts(T),
        degrees{T}(1,:,p) = cumsum(sel_post{T}(:,p)==1) + deg0 -1;
        for c = 2:T+1,
            degrees{T}(c,:,p) = cumsum(sel_post{T}(:,p)==c) + deg0;
        end
        degrees{T}(:,:,p) = triu(degrees{T}(:,:,p),-1);

        % normalize degrees
        %degrees{T}(:,:,p) = degrees{T}(:,:,p)./repmat(sum(degrees{T}(:,:,p),1),T+1,1);
    end
end

% degreeki(k,i) is the degree of the parent of comment k at time k-1 in thread i 
for T = Tmin:Tmax

    % first row IS NOT USED in fun2min...
    degreeki{T} = ones(T,nposts(T));

    for p = 1:nposts(T),
        for t = 2:T
            if degrees{T}(sel_post{T}(t,p),t,p) > 0
                degreeki{T}(t,p) = degrees{T}(sel_post{T}(t,p),t,p)-1;
                %degreeki{T}(t,p) = degrees{T}(sel_post{T}(t,p),t-1,p);
            else
                fprintf('error in post %d at t %d parent is %d\n', p, t, sel_post{T}(t,p));
            end
        end
    end
    if nposts(T) > 0
        ispost{T} = sel_post{T}==1;
    end
end

% preprocess authors, if available
% rec{T}(i,p) contains wether comment i in post p of length T is reciprocal
rec = cell(1,numel(sel_authors));
% recZ{T}(t,p) contains sum of reciprocal comments at time t
recZ = cell(1,numel(sel_authors));
forb = cell(1,numel(sel_authors));
if ~isempty(sel_authors{Tmin})
    for T = Tmin:Tmax
        for p = 1:nposts(T),
            [~,b,c] = unique(sel_authors{T}(:,p));
            if ~isempty(b)
                % pp is vector of parents
                pp = [-42 sel_post{T}(:,p)'];
                % c is vector of authors id
                c = [-42 c'];                   
                % pp2 contains parents of parents
                pp2 = zeros(1,T+1);
                pp2(pp ~= -42) = pp(pp(pp ~= -42));  
                % c2 contains authors of parents of parents
                c2 = zeros(1,T+1);
                c2(pp2>1) = c(pp2(pp2>1));   
                rec{T}(:,p) = c2(2:end) == c(2:end);

                recZ{T}(:,p) = zeros(T+1,1);
                cp = zeros(1,T+1);
                cp(pp ~= -42) = c(pp(pp ~= -42));
                for t = 2:T+1
                    % only consider last one
                    %recZ{T}(t,p) = sum(cp(1:t-1) == c(t));
                    recZ{T}(t,p) = any(cp(1:t-1) == c(t));
                end
                
                % forbidden comments (required for Z)
                auth_com_replied = zeros(numel(b),T); % whether author replied a comment
                forb{T} = ones(T+1,nposts(T),T);
                for t = 3:T+1
                    % we forbide to reply own comments
                    forb{T}(t,p,1:t-1) = (c(t) == c(1:t-1));
                    % we forbide more than one reply to the same comment
                    forb{T}(t,p, auth_com_replied(c(t),:)==1) = 1;
                    auth_com_replied(c(t),pp(t)) = 1;
                end
                forb{T}(1,:,:) = [];
                %diff = abs(squeeze(sel_cforb{T}(:,p,:)) - squeeze(forb{T}(:,p,:)));
%                 if any(diff(:))
%                     keyboard;
%                 end
            end
        end
        if nposts(T)>0 && ~isempty(b)
            recZ{T}(1,:) = [];
        end
    end
end

% forbidden comments need to be considered, since they don't contribute
% to the normalization. We need, per each post p and time-step t,
% a vector of 

toc;

prep.degreeki = degreeki;
prep.sel_post = sel_post;
prep.ispost = ispost;
prep.nposts = nposts;
prep.Tmin = Tmin;
prep.Tmax = Tmax;
prep.sel_levels = sel_levels;
prep.rec = rec;
prep.recZ = recZ;

% prep.sel_probs = sel_probs; % for debugging
% prep.sel_cZs = sel_cZs;     % for debugging
% prep.sel_cforb = sel_cforb;     % for debugging
