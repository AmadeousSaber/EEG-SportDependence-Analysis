%% 
ctr_filename = '读取后顺序数据ctr.xlsx';
sd_filename = '读取后顺序数据sd.xlsx';

T_ctr = readtable(ctr_filename);
T_sd = readtable(sd_filename);

% 子量表的索引
score1_index = 4:9;
score2_index = 10:12;
score3_index = 13:15;
score4_index = 16:20;
score5_index = 21:23;

% 计算ctr中指定列的和
T_ctr.score1 = sum(T_ctr{:, score1_index}, 2);
T_ctr.score2 = sum(T_ctr{:, score2_index}, 2);
T_ctr.score3 = sum(T_ctr{:, score3_index}, 2);
T_ctr.score4 = sum(T_ctr{:, score4_index}, 2);
T_ctr.score5 = sum(T_ctr{:, score5_index}, 2);

T_ctr.total = sum(T_ctr{:, 4:23}, 2);

% 计算sd中指定列的和
T_sd.score1 = sum(T_sd{:, score1_index}, 2);
T_sd.score2 = sum(T_sd{:, score2_index}, 2);
T_sd.score3 = sum(T_sd{:, score3_index}, 2);
T_sd.score4 = sum(T_sd{:, score4_index}, 2);
T_sd.score5 = sum(T_sd{:, score5_index}, 2);

T_sd.total = sum(T_sd{:, 4:23}, 2);


%% 计算两组被试各子维度得分差异
% 进行 t 检验
for c=1:6
    [h, p, ci, stats] = ttest2(T_ctr{:,c+23}, T_sd{:,c+23});

    % 计算每组的均值和标准差
    mean1 = mean(T_ctr{:,c+23});
    std1 = std(T_ctr{:,c+23});
    mean2 = mean(T_sd{:,c+23});
    std2 = std(T_sd{:,c+23});

    fprintf('第 %d 维度 ', c);
    fprintf('  控制组: 均值 = %.4f, 标准差 = %.4f\n', mean1, std1);
    fprintf('  依赖组: 均值 = %.4f, 标准差 = %.4f\n', mean2, std2);
    fprintf('  h = %d\n', h);        % 是否拒绝原假设
    fprintf('  p = %.4f\n', p);      % p 值
    fprintf('  CI = [%.4f, %.4f]\n', ci(1), ci(2));  % 置信区间
    fprintf('  t-stat = %.4f\n', stats.tstat);       % t 统计量
    fprintf('  df = %d\n\n', stats.df);              % 自由度
end


%% 计算相关值
% 两组被试数据
for i = 1:6
    ctrscore(:,i) = T_ctr{:, i+23};
    sdscore(:,i) = T_sd{:, i+23};
end
allscore = vertcat(ctrscore, sdscore);


% global
load('global_data_graph_aec.mat');

[ctr_r_gcc, ctr_p_gcc] = corr(ctrscore, global_data.gcc{1, 1}');
[ctr_r_s, ctr_p_s] = corr(ctrscore, global_data.s{1, 1}');

[sd_r_gcc, sd_p_gcc] = corr(sdscore, global_data.gcc{1, 2}');
[sd_r_s, sd_p_s] = corr(sdscore, global_data.s{1, 2}');

[all_r_gcc, all_p_gcc] = corr(allscore, vertcat(global_data.gcc{1, 1}', global_data.gcc{1, 2}'));
[all_r_s, all_p_s] = corr(allscore, vertcat(global_data.s{1, 1}', global_data.s{1, 2}'));

global_r(1,:) = {ctr_p_gcc,sd_p_gcc,all_p_gcc};
global_r(2,:) = {ctr_p_s,sd_p_s,all_p_s};

save('global_rp_result.mat','global_r');


% local
load('local_data_graph_aec.mat');  

% 30:Left_Limbic_TempPole_2
[ctr_r_degree, ctr_p_degree] = corr(ctrscore, local_data.degree{2, 1}(:,30));
[ctr_r_cc, ctr_p_cc] = corr(ctrscore, local_data.cc{2, 1}(:,30));

[sd_r_degree, sd_p_degree] = corr(sdscore, local_data.degree{2, 2}(:,30));
[sd_r_cc, sd_p_cc] = corr(sdscore, local_data.cc{2, 2}(:,30));

[all_r_degree, all_p_degree] = corr(allscore, vertcat(local_data.degree{2, 1}(:,30),local_data.degree{2, 2}(:,30)));
[all_r_cc, all_p_cc] = corr(allscore, vertcat(local_data.cc{2, 1}(:,30),local_data.cc{2, 2}(:,30)));

local_r = {ctr_p_degree,sd_p_degree,all_p_degree};
% local_r = {ctr_p_cc,sd_p_cc};

save('local_rp_result30.mat','local_r');

% 86:Right_ContB_PFClv_1
[ctr_r_degree2, ctr_p_degree2] = corr(ctrscore, local_data.degree{2, 1}(:,86));
[ctr_r_cc2, ctr_p_cc2] = corr(ctrscore, local_data.cc{2, 1}(:,86));

[sd_r_degree2, sd_p_degree2] = corr(sdscore, local_data.degree{2, 2}(:,86));
[sd_r_cc2, sd_p_cc2] = corr(sdscore, local_data.cc{2, 2}(:,86));

[all_r_degree2, all_p_degree2] = corr(allscore, vertcat(local_data.degree{2, 1}(:,86),local_data.degree{2, 2}(:,86)));
[all_r_cc2, all_p_cc2] = corr(allscore, vertcat(local_data.cc{2, 1}(:,86),local_data.cc{2, 2}(:,86)));

local_r2 = {ctr_p_degree2,sd_p_degree2,all_p_degree2};

save('local_rp_result86.mat','local_r2');

% %%  
% % local
% load('local_data_graph_aec.mat');  
% 
% for i=1:length(local_data.cc{2, 2}(1,:))
% 
%     % 30:Left_Limbic_TempPole_2
%     [ctr_r_degree(:,i), ctr_p_degree(:,i)] = corr(ctrscore, local_data.degree{2, 1}(:,i));
%     [ctr_r_cc(:,i), ctr_p_cc(:,i)] = corr(ctrscore, local_data.cc{2, 1}(:,i));
% 
%     [sd_r_degree(:,i), sd_p_degree(:,i)] = corr(sdscore, local_data.degree{2, 2}(:,i));
%     [sd_r_cc(:,i), sd_p_cc(:,i)] = corr(sdscore, local_data.cc{2, 2}(:,i));
% 
% end



%     searchp = pval_adjust(ctr_p_degree(5,:), 'fdr'); 仅量表第五个维度控制组degree有结果
%     [row, col] = find(searchp < 0.05);
% 
% % 显示结果
% disp('小于 0.05 的元素的位置:');
% for i = 1:length(row)
%     disp(['行: ', num2str(row(i)), ', 列: ', num2str(col(i))]);
% end
% 
% % 获取这些位置的值
% values = searchp(searchp < 0.05);
% disp('小于 0.05 的元素的值:');
% disp(values);



% %% fdr
% % global
% fdr_ctr_gcc = pval_adjust(global_r{1, 1}, 'fdr');
% fdr_sd_gcc = pval_adjust(global_r{1, 2}, 'fdr');
% fdr_all_gcc = pval_adjust(global_r{1, 3}, 'fdr');
% 
% fdr_ctr_s = pval_adjust(global_r{2, 1}, 'fdr');
% fdr_sd_s = pval_adjust(global_r{2, 2}, 'fdr');
% fdr_all_s = pval_adjust(global_r{2, 3}, 'fdr');
% 
% 
% % local
% fdr_ctr_degree = pval_adjust(local_r{1, 1}, 'fdr');
% fdr_sd_degree = pval_adjust(local_r{1, 2}, 'fdr');
% fdr_all_degree = pval_adjust(local_r{1, 3}, 'fdr');
% 
% fdr_ctr_degree2 = pval_adjust(local_r2{1, 1}, 'fdr');
% fdr_sd_degree2 = pval_adjust(local_r2{1, 2}, 'fdr');
% fdr_all_degree2 = pval_adjust(local_r2{1, 3}, 'fdr');


% 按子量表
% all
for j =1:6
    fdr_var_all(j,:) = pval_adjust([global_r{1, 3}(j,1), global_r{2, 3}(j,1), local_r{1, 3}(j,1), local_r2{1, 3}(j,1)], 'fdr');
end

[row1, col1] = find(fdr_var_all < 0.05);

% sd
for j =1:6
    % raw_sd_p(j,:) = [global_r{1, 2}(j,1), global_r{2, 2}(j,1), local_r{1, 2}(j,1), local_r2{1, 2}(j,1)];
    fdr_var_sd(j,:) = pval_adjust([global_r{1, 2}(j,1), global_r{2, 2}(j,1), local_r{1, 2}(j,1), local_r2{1, 2}(j,1)], 'fdr');
end

[row2, col2] = find(fdr_var_sd < 0.05);

% ctr
for j =1:6
    fdr_var_ctr(j,:) = pval_adjust([global_r{1, 1}(j,1), global_r{2, 1}(j,1), local_r{1, 1}(j,1), local_r2{1, 1}(j,1)], 'fdr');
end

[row3, col3] = find(fdr_var_ctr < 0.05);

