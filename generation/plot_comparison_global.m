function plot_comparison_global(ms, ds, comb)

% ----------------------------------------------
% plot_comparison_global(args)

mark_data = [{'ko'}, {'bo'}, {'ro'}, {'go'},];
mark_model = [{'k-'}, {'b-'}, {'r-'}, {'g-'}];
% 
for f=1:5,
    hnd(f)=figure(f);clf;
%     set(hnd(f),'PaperType','A4'); 
%     set(hnd(f),'PaperOrientation','landscape');
%     set(hnd(f),'PaperUnits','centimeters');
%     set(hnd(f),'PaperPosition',[0 0 29.7 20 ]); 
end

% ----------------------------------------------
% filter groups from the data...
if isfield(ms, 'groups_compare')

    % select group
    groups_compare = ms.groups_compare;
    groups_data = get_group(ms.groups_total, ds.vsizes_data);
    
    % get cdf of post sizes
    useit = false(1,numel(ds.vprop_data));
    for g = groups_compare,
        useit = or(useit, groups_data == g);
    end

    ds.subtree_sizes_all_data(:,~useit)=[];
    ds.subtree_sizes_level_data(:,~useit)=[];
    ds.degrees_data(:,~useit)=[];
    ds.vdepths_data(~useit) = [];
    ds.vprop_data(~useit) = [];
    ds.vsizes_data(~useit) = [];
end

mark_data2 = [{'ko'}, {'k-'}, {'ro'}, {'go'}, {'mo'}];
mark_model2 = [{'b+'}, {'b--'}, {'r-'}, {'g-'}, {'m-'}];

%-------------------------------------------
% plot subtree sizes
ks2stat_subtree = zeros(1,size(ds.subtree_sizes_level_data,1));
for level = 1:size(ds.subtree_sizes_level_data,1),
    if level == 1, figure(1); else figure(2); end
    if level < 5
        % plot data
        subplot(2,2,1);
        [a,b]=hist([ds.subtree_sizes_level_data{level,:}],min([ds.subtree_sizes_level_data{level,:}]):max([ds.subtree_sizes_level_data{level,:}]));
        plot(b,a/sum(a), mark_data{level});hold on;    
        subplot(2,2,2);
        plot(b,cumsum(a)/sum(a), mark_data{level});hold on;    

        % plot model
        subplot(2,2,1);
        [a,b]=hist([ms.subtree_sizes_level_model{level,:}],min([ms.subtree_sizes_level_model{level,:}]):max([ms.subtree_sizes_level_model{level,:}]));
        plot(b,a/sum(a), mark_model{level});hold on;    
        subplot(2,2,2);
        plot(b,cumsum(a)/sum(a), mark_model{level});hold on;
    end
    
    if (size(ds.subtree_sizes_level_data,1) >= level) && (size(ms.subtree_sizes_level_model,1) >= level)
        if ~isempty([ms.subtree_sizes_level_model{level,:}]) && ~isempty([ds.subtree_sizes_level_data{level,:}])
            [h,p,ks2stat_subtree(level)] = kstest2([ms.subtree_sizes_level_model{level,:}],[ds.subtree_sizes_level_data{level,:}]);
            fprintf('KS test subtree_sizes level %d \t(%d %f %f)\n', level,h,p,ks2stat_subtree(level));
        end
    end
end

for f=1:2,
    figure(f);
    subplot(2,2,1);
    title(['pdf subtree sizes, N=' num2str(ms.N)]);
    set(gca, 'xscale', 'log');set(gca, 'yscale', 'log');grid on;
    set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');
    subplot(2,2,2);
    title(['cdf subtree sizes, KS=' num2str(ks2stat_subtree(1))]);
    
    set(gca, 'xscale', 'log');set(gca, 'yscale', 'log');grid on;
    set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');
end
figure(1);
legend( [ms.str_compact ' l1'], 'model l1', 'location', 'southeast');
figure(2);
legend( [ms.str_compact ' l2'], 'model l2',  ...
        [ms.str_compact ' l3'], 'model l3',  ...
        [ms.str_compact ' l4'], 'model l4',  ...
        'location','southeast');

figure(3);
subplot(2,2,1);
plot(1:size(ds.subtree_sizes_level_data,1), ks2stat_subtree, '.-k');
grid on;
xlabel('level');ylabel('KS statistic');
title(['subtree sizes ' comb]);

%-------------------------------------------
% plot degrees
ks2stat_degree = zeros(1,size(ds.degrees_data,1));
for level = 1:size(ds.degrees_data,1),
    if level == 1, figure(1); else figure(2); end
    if level < 5
        % plot data
        subplot(2,2,3);
        [a,b]=hist([ds.degrees_data{level,:}],min([ds.degrees_data{level,:}]):max([ds.degrees_data{level,:}]));
        plot(b,a/sum(a), mark_data{level});hold on;    
        subplot(2,2,4);
        plot(b,cumsum(a)/sum(a), mark_data{level});hold on;    

        % plot model
        subplot(2,2,3);
        [a,b]=hist([ms.degrees_model{level,:}],min([ms.degrees_model{level,:}]):max([ms.degrees_model{level,:}]));
        plot(b,a/sum(a), mark_model{level});hold on;    
        subplot(2,2,4);
        plot(b,cumsum(a)/sum(a), mark_model{level});hold on;
    end
    
    if (size(ds.degrees_data,1) >= level) && (size(ms.degrees_model,1) >= level)
        if ~isempty([ms.degrees_model{level,:}]) && ~isempty([ds.degrees_data{level,:}])
            [h,p,ks2stat_degree(level)] = kstest2([ms.degrees_model{level,:}],[ds.degrees_data{level,:}]);
            fprintf('KS test degrees level %d \t(%d %f %f)\n', level,h,p,ks2stat_degree(level));    
        end
    end
end

for f=1:2,
    figure(f);
    subplot(2,2,3);
    title('pdf degrees');
    set(gca, 'xscale', 'linear');set(gca, 'yscale', 'log');grid on;
    set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');
    subplot(2,2,4);
    title(['cdf degrees, KS=' num2str(ks2stat_degree(1))]);
    set(gca, 'xscale', 'linear');set(gca, 'yscale', 'log');grid on;
    set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');
end

figure(1);
legend( [ms.str_compact ' l1'], 'model l1', 'location', 'southeast');
figure(2);
legend( [ms.str_compact ' l2'], 'model l2',  ...
        [ms.str_compact ' l3'], 'model l3',  ...
        [ms.str_compact ' l4'], 'model l4',  ...
        'location','southeast');

figure(3);
subplot(2,2,2);
plot(1:size(ds.degrees_data,1), ks2stat_degree, '.-k');
grid on;
xlabel('level');ylabel('KS statistic');
title(['degrees ' comb]);

%-------------------------------------------
% plot max depths and avg depth
[h,p,ks2stat] = kstest2(ds.vdepths_data, ms.vdepths_model);
fprintf('KS test depths \t\t\t(%d %f %f)\n', h,p,ks2stat);

figure(4);
subplot(2,2,1);
[a,b] = hist(ds.vdepths_data, min(ds.vdepths_data):max(ds.vdepths_data));
plot(b, a/sum(a), 'ok'); hold on;
[a,b] = hist(ms.vdepths_model, min(ms.vdepths_model):max(ms.vdepths_model));
plot(b, a/sum(a), '-k'); grid on;
xlabel('max depth')
title('pdf')
%legend(ms.str_compact, 'model');
set(gca,'yscale','log');%set(gca,'xscale','log');
set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');

subplot(2,2,2);
[a,b] = hist(ds.vdepths_data, min(ds.vdepths_data):max(ds.vdepths_data));
plot(b, 1-cumsum(a)/sum(a), 'ok'); hold on;
[a,b] = hist(ms.vdepths_model, min(ms.vdepths_model):max(ms.vdepths_model));
plot(b, 1-cumsum(a)/sum(a), '-k'); grid on;
xlabel('max depth')
[h,p,ks2stat] = kstest2(ms.vdepths_model,ds.vdepths_data);
disp(['KS test max depths ' num2str(ks2stat)]);
title(['cdf, KSstat = ' num2str(ks2stat)]);
legend(ms.str_compact, comb,'location','southeast');
set(gca,'yscale','linear');set(gca,'xscale','linear');
set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');

subplot(2,2,3);
[a,b] = hist(ds.vtotaldepths_data, min(ds.vtotaldepths_data):max(ds.vtotaldepths_data));
plot(b, a/sum(a), 'ok'); hold on;
[a,b] = hist(ms.vtotaldepths_model, min(ms.vtotaldepths_model):max(ms.vtotaldepths_model));
plot(b, a/sum(a), '-k'); grid on;
xlabel('mean depth')
title('pdf')
%legend(ms.str_compact, 'model');
set(gca,'yscale','log');set(gca,'xscale','linear');
set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');


subplot(2,2,4);
[a,b] = hist(ds.vtotaldepths_data, min(ds.vtotaldepths_data):max(ds.vtotaldepths_data));
plot(b, 1-cumsum(a)/sum(a), 'ok'); hold on;
[a,b] = hist(ms.vtotaldepths_model, min(ms.vtotaldepths_model):max(ms.vtotaldepths_model));
plot(b, 1-cumsum(a)/sum(a), '-k'); grid on;
xlabel('mean depth')
[h,p,ks2stat] = kstest2(ms.vtotaldepths_model,ds.vtotaldepths_data);
disp(['KS test all depths ' num2str(ks2stat)]);
title(['cdf, KSstat = ' num2str(ks2stat)]);
legend(ms.str_compact, comb,'location','southeast');
set(gca,'yscale','linear');set(gca,'xscale','linear');
set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');


%-------------------------------------------
% plot correlations
%[lens, prop, c, clog] = get_proportion_direct_replies_per_size(args.cpost, 1);

figure(3);

cd = corrcoef(ds.vsizes_data, ds.vprop_data);
lcd = corrcoef(log(ds.vsizes_data), ds.vprop_data);
cm = corrcoef(ms.vsizes_model, ms.vprop_model);
lcm = corrcoef(log(ms.vsizes_model), ms.vprop_model);

subplot(2,2,3);
plot(ds.vsizes_data, ds.vprop_data, '.k');
xlabel(['post size, N=' num2str(ms.N)]);
ylabel('proportion of direct comments');
stitle = sprintf('%s rho=%.3f rholog=%.3f', ms.str_compact, cd(1,2), lcd(1,2));
title(stitle);
axis tight;
set(gca,'xscale','log');
set(gca,'ylim',[0 1]);

subplot(2,2,4);
plot(ms.vsizes_model, ms.vprop_model, '.k');
xlabel('post size');
ylabel('proportion of direct comments');
stitle = sprintf('model rho=%.3f rholog=%.3f', cm(1,2), lcm(1,2));
title(stitle);
axis tight;
set(gca,'xscale','log');
set(gca,'ylim',[0 1]);

%-------------------------------------------
% plot total degrees and total subtree sizes


level0 = 1;

% degrees
m_degrees = [ms.degrees_model{level0:end,:}];
d_degrees = [ds.degrees_data{level0:end,:}];

% subtree sizes
m_subtree_sizes = [ms.subtree_sizes_level_model{level0:end,:}];
d_subtree_sizes = [ds.subtree_sizes_level_data{level0:end,:}];

hx= figure(5);clf;
subplot(2,2,1);
[a,b] = hist(d_degrees, min(d_degrees):max(d_degrees));
plot(b, a/sum(a), 'ok'); hold on;
[a,b] = hist(m_degrees, min(m_degrees):max(m_degrees));
plot(b, a/sum(a), '-k'); grid on;
xlabel('total degrees')
title('pdf')
set(gca,'yscale','log');set(gca,'xscale','linear');
set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');

subplot(2,2,2);
[a,b] = hist(d_degrees, min(d_degrees):max(d_degrees));
plot(b, cumsum(a)/sum(a), 'ok'); hold on;
[a,b] = hist(m_degrees, min(m_degrees):max(m_degrees));
plot(b, cumsum(a)/sum(a), '-k'); grid on;
xlabel('total degrees')
[h,p,ks2stat] = kstest2(m_degrees,d_degrees);
disp(['KS test all degrees ' num2str(ks2stat)]);
title(['cdf, KSstat = ' num2str(ks2stat)]);
legend(ms.str_compact, comb,'location','southeast');
set(gca,'yscale','log');set(gca,'xscale','log');
set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');

subplot(2,2,3);
[a,b] = hist(d_subtree_sizes, min(d_subtree_sizes):max(d_subtree_sizes));
plot(b, a/sum(a), 'ok'); hold on;
[a,b] = hist(m_subtree_sizes, min(m_subtree_sizes):max(m_subtree_sizes));
plot(b, a/sum(a), '-k'); grid on;
xlabel('total subtree sizes')
title('pdf')
%legend(ms.str_compact, 'model');
set(gca,'yscale','log');set(gca,'xscale','linear');
set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');

subplot(2,2,4);
[a,b] = hist(d_subtree_sizes, min(d_subtree_sizes):max(d_subtree_sizes));
plot(b, cumsum(a)/sum(a), 'ok'); hold on;
[a,b] = hist(m_subtree_sizes, min(m_subtree_sizes):max(m_subtree_sizes));
plot(b, cumsum(a)/sum(a), '-k'); grid on;
xlabel('total subtree sizes')
[h,p,ks2stat] = kstest2(m_subtree_sizes,d_subtree_sizes);
disp(['KS test all subtree_sizes ' num2str(ks2stat)]);
title(['cdf, KSstat = ' num2str(ks2stat)]);
legend(ms.str_compact, comb,'location','southeast');
set(gca,'yscale','log');set(gca,'xscale','linear');
set(gca,'xminorgrid','off');set(gca,'yminorgrid','off');

% for f=1:4
%     saveas(hnd(f),['model_comp' ms.str_compact '_global_' num2str(f) '.eps'],'psc2');
% end
