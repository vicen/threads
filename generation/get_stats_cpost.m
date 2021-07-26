function [subtreeSizesLevel, subtreeSizesAll, degrees, depth, prop, num_comments] = ...
    get_stats_cpost(p, parent_vector, level_vector, subtreeSizesLevel, subtreeSizesAll, degrees, thresh, vmax)

num_comments=numel(parent_vector);

% get depth
depth = max(level_vector);

% get proportion of direct comments
prop = sum(parent_vector==0)/num_comments;

% get subtree sizes per node v
if thresh > 0
    parent_vector2 = parent_vector( 1:thresh );
    for v = 1:vmax
        is_in_subtree=false(1,thresh);
        is_in_subtree(v) = true;
        was_processed = false(1,thresh);
        to_process = xor(was_processed, is_in_subtree);
        while sum(to_process)>0
          for x=find(to_process)
              %Add new neodes with parent x
              is_in_subtree(x==parent_vector2) = true;   
              was_processed(x) = true;
          end
          to_process=xor(was_processed, is_in_subtree);
        end
        subtreeSizesAll(v, p) = sum(is_in_subtree);
    end
end

% get subtree sizes per level
for l = 2:max(level_vector)
    ix_subtree = (level_vector==l);
    num_subtrees = sum(ix_subtree);
    subtree_index = zeros(1, num_comments);
    subtree_index(ix_subtree) = 1:num_subtrees;
    for j=find(~ix_subtree & level_vector>l)
        if parent_vector(j) > numel(subtree_index)
            disp('f');
        end
        subtree_index(j) = subtree_index(parent_vector(j));          
    end
    subtreeSizesLevel{l,p} = hist(nonzeros(subtree_index),1:num_subtrees);
end

% get degrees per level
for l = 2:max(level_vector)
    ix_subtree = find(level_vector==l);
    num_cmnts_level = numel(ix_subtree);
    deg = zeros(1, num_cmnts_level);
    for j=1:num_cmnts_level
        deg(j) = sum(parent_vector == ix_subtree(j));
    end
    degrees{l,p} = deg+1;
end

subtreeSizesLevel{1,p} = numel(parent_vector);
degrees{1,p} = sum(parent_vector==0);
