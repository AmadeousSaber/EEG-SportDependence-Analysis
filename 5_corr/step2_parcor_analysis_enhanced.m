%% 偏相关分析增强版 - 完整结果输出与报告生成
% 作者: 自动生成
% 日期: 2025-11-20
% 功能: 计算量表与脑网络指标的偏相关分析，控制性别和年龄，输出完整结果报告

clear; clc;

%% 1. 数据加载与预处理
fprintf('========================================\n');
fprintf('偏相关分析开始\n');
fprintf('========================================\n\n');

ctr_filename = '读取后顺序数据ctr.xlsx';
sd_filename = '读取后顺序数据sd.xlsx';

fprintf('正在加载数据文件...\n');
T_ctr = readtable(ctr_filename);
T_sd = readtable(sd_filename);
fprintf('数据加载完成。控制组样本量: %d, 依赖组样本量: %d\n\n', height(T_ctr), height(T_sd));

% 子量表的索引
score1_index = 4:9;
score2_index = 10:12;
score3_index = 13:15;
score4_index = 16:20;
score5_index = 21:23;

% 量表维度名称
score_names = {'维度1', '维度2', '维度3', '维度4', '维度5', '总分'};
indicator_names = {'GCC', 'S', 'Degree_Node30', 'Degree_Node86'};

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

%% 2. 准备分析数据
% 两组被试数据
for i = 1:6
    ctrscore(:,i) = T_ctr{:, i+23};
    sdscore(:,i) = T_sd{:, i+23};
end
allscore = vertcat(ctrscore, sdscore);

% 设置性别和年龄为控制变量
ctrvar_ctr = [T_ctr.Var2, T_ctr.Var3];
ctrvar_sd = [T_sd.Var2, T_sd.Var3];

var2_all = [T_ctr.Var2; T_sd.Var2];
var3_all = [T_ctr.Var3; T_sd.Var3];
ctrvar_all = [var2_all, var3_all];

%% 3. 全局指标偏相关分析
fprintf('正在进行全局指标偏相关分析...\n');
load('global_data_graph_aec.mat');

% 控制组
[ctr_r_gcc, ctr_p_gcc] = partialcorr(ctrscore, global_data.gcc{1, 1}', ctrvar_ctr);
[ctr_r_s, ctr_p_s] = partialcorr(ctrscore, global_data.s{1, 1}', ctrvar_ctr);

% 依赖组
[sd_r_gcc, sd_p_gcc] = partialcorr(sdscore, global_data.gcc{1, 2}', ctrvar_sd);
[sd_r_s, sd_p_s] = partialcorr(sdscore, global_data.s{1, 2}', ctrvar_sd);

% 全体
[all_r_gcc, all_p_gcc] = partialcorr(allscore, vertcat(global_data.gcc{1, 1}', global_data.gcc{1, 2}'), ctrvar_all);
[all_r_s, all_p_s] = partialcorr(allscore, vertcat(global_data.s{1, 1}', global_data.s{1, 2}'), ctrvar_all);

global_rvalue(1,:) = {ctr_r_gcc, sd_r_gcc, all_r_gcc};
global_rvalue(2,:) = {ctr_r_s, sd_r_s, all_r_s};

global_r(1,:) = {ctr_p_gcc, sd_p_gcc, all_p_gcc};
global_r(2,:) = {ctr_p_s, sd_p_s, all_p_s};

save('global_parrp_result.mat', 'global_rvalue', 'global_r');
fprintf('全局指标分析完成。\n\n');

%% 4. 局部指标偏相关分析
fprintf('正在进行局部指标偏相关分析...\n');
load('local_data_graph_aec.mat');  

% Node 30: Left_Limbic_TempPole_2
[ctr_r_degree, ctr_p_degree] = partialcorr(ctrscore, local_data.degree{2, 1}(:,30), ctrvar_ctr);
[ctr_r_cc, ctr_p_cc] = partialcorr(ctrscore, local_data.cc{2, 1}(:,30), ctrvar_ctr);

[sd_r_degree, sd_p_degree] = partialcorr(sdscore, local_data.degree{2, 2}(:,30), ctrvar_sd);
[sd_r_cc, sd_p_cc] = partialcorr(sdscore, local_data.cc{2, 2}(:,30), ctrvar_sd);

[all_r_degree, all_p_degree] = partialcorr(allscore, vertcat(local_data.degree{2, 1}(:,30), local_data.degree{2, 2}(:,30)), ctrvar_all);
[all_r_cc, all_p_cc] = partialcorr(allscore, vertcat(local_data.cc{2, 1}(:,30), local_data.cc{2, 2}(:,30)), ctrvar_all);

local_rvalue = {ctr_r_degree, sd_r_degree, all_r_degree};
local_r = {ctr_p_degree, sd_p_degree, all_p_degree};

save('local_parrp_result30.mat', 'local_rvalue', 'local_r');

% Node 86: Right_ContB_PFClv_1
[ctr_r_degree2, ctr_p_degree2] = partialcorr(ctrscore, local_data.degree{2, 1}(:,86), ctrvar_ctr);
[ctr_r_cc2, ctr_p_cc2] = partialcorr(ctrscore, local_data.cc{2, 1}(:,86), ctrvar_ctr);

[sd_r_degree2, sd_p_degree2] = partialcorr(sdscore, local_data.degree{2, 2}(:,86), ctrvar_sd);
[sd_r_cc2, sd_p_cc2] = partialcorr(sdscore, local_data.cc{2, 2}(:,86), ctrvar_sd);

[all_r_degree2, all_p_degree2] = partialcorr(allscore, vertcat(local_data.degree{2, 1}(:,86), local_data.degree{2, 2}(:,86)), ctrvar_all);
[all_r_cc2, all_p_cc2] = partialcorr(allscore, vertcat(local_data.cc{2, 1}(:,86), local_data.cc{2, 2}(:,86)), ctrvar_all);

local_r2value = {ctr_r_degree2, sd_r_degree2, all_r_degree2};
local_r2 = {ctr_p_degree2, sd_p_degree2, all_p_degree2};

save('local_parrp_result86.mat', 'local_r2value', 'local_r2');
fprintf('局部指标分析完成。\n\n');

%% 5. FDR校正
fprintf('正在进行FDR多重比较校正...\n');

% 全体被试FDR校正
for j = 1:6
    raw_p_all(j,:) = [global_r{1, 3}(j,1), global_r{2, 3}(j,1), local_r{1, 3}(j,1), local_r2{1, 3}(j,1)];
    fdr_var_all(j,:) = pval_adjust(raw_p_all(j,:), 'fdr');
end

% 依赖组FDR校正
for j = 1:6
    raw_p_sd(j,:) = [global_r{1, 2}(j,1), global_r{2, 2}(j,1), local_r{1, 2}(j,1), local_r2{1, 2}(j,1)];
    fdr_var_sd(j,:) = pval_adjust(raw_p_sd(j,:), 'fdr');
end

% 控制组FDR校正
for j = 1:6
    raw_p_ctr(j,:) = [global_r{1, 1}(j,1), global_r{2, 1}(j,1), local_r{1, 1}(j,1), local_r2{1, 1}(j,1)];
    fdr_var_ctr(j,:) = pval_adjust(raw_p_ctr(j,:), 'fdr');
end

% 相关系数矩阵
r_all = [global_rvalue{1, 3}, global_rvalue{2, 3}, local_rvalue{1, 3}, local_r2value{1, 3}];
r_sd = [global_rvalue{1, 2}, global_rvalue{2, 2}, local_rvalue{1, 2}, local_r2value{1, 2}];
r_ctr = [global_rvalue{1, 1}, global_rvalue{2, 1}, local_rvalue{1, 1}, local_r2value{1, 1}];

fprintf('FDR校正完成。\n\n');

%% 6. 查找显著结果
[row_all, col_all] = find(fdr_var_all < 0.05);
[row_sd, col_sd] = find(fdr_var_sd < 0.05);
[row_ctr, col_ctr] = find(fdr_var_ctr < 0.05);

fprintf('显著结果统计:\n');
fprintf('  全体被试: %d 个显著结果\n', length(row_all));
fprintf('  依赖组: %d 个显著结果\n', length(row_sd));
fprintf('  控制组: %d 个显著结果\n\n', length(row_ctr));

%% 7. 生成详细报告文件
fprintf('正在生成详细报告文件...\n');
report_filename = sprintf('偏相关分析详细报告_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
fid = fopen(report_filename, 'w', 'n', 'UTF-8');

% 报告头部
fprintf(fid, '========================================\n');
fprintf(fid, '偏相关分析详细报告\n');
fprintf(fid, '========================================\n');
fprintf(fid, '生成时间: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf(fid, '控制变量: 性别, 年龄\n');
fprintf(fid, '多重比较校正方法: FDR\n');
fprintf(fid, '显著性水平: α = 0.05\n\n');

% 样本信息
fprintf(fid, '样本信息:\n');
fprintf(fid, '  控制组样本量: %d\n', height(T_ctr));
fprintf(fid, '  依赖组样本量: %d\n', height(T_sd));
fprintf(fid, '  总样本量: %d\n\n', height(T_ctr) + height(T_sd));

% 量表描述统计
fprintf(fid, '========================================\n');
fprintf(fid, '一、量表描述统计\n');
fprintf(fid, '========================================\n\n');

for i = 1:6
    fprintf(fid, '%s:\n', score_names{i});
    fprintf(fid, '  控制组: M = %.2f, SD = %.2f\n', mean(ctrscore(:,i)), std(ctrscore(:,i)));
    fprintf(fid, '  依赖组: M = %.2f, SD = %.2f\n', mean(sdscore(:,i)), std(sdscore(:,i)));
    fprintf(fid, '  全体: M = %.2f, SD = %.2f\n\n', mean(allscore(:,i)), std(allscore(:,i)));
end

% 全体被试结果
fprintf(fid, '========================================\n');
fprintf(fid, '二、全体被试偏相关分析结果\n');
fprintf(fid, '========================================\n\n');

fprintf(fid, '(一) 原始p值与相关系数\n');
fprintf(fid, '%-10s', '量表维度');
for k = 1:4
    fprintf(fid, '%-15s', [indicator_names{k} '_r']);
    fprintf(fid, '%-15s', [indicator_names{k} '_p']);
end
fprintf(fid, '\n');
fprintf(fid, repmat('-', 1, 130));
fprintf(fid, '\n');

for i = 1:6
    fprintf(fid, '%-10s', score_names{i});
    for k = 1:4
        fprintf(fid, '%-15.4f', r_all(i,k));
        fprintf(fid, '%-15.4f', raw_p_all(i,k));
    end
    fprintf(fid, '\n');
end

fprintf(fid, '\n(二) FDR校正后p值\n');
fprintf(fid, '%-10s', '量表维度');
for k = 1:4
    fprintf(fid, '%-18s', [indicator_names{k} '_FDR']);
end
fprintf(fid, '\n');
fprintf(fid, repmat('-', 1, 82));
fprintf(fid, '\n');

for i = 1:6
    fprintf(fid, '%-10s', score_names{i});
    for k = 1:4
        if fdr_var_all(i,k) < 0.05
            fprintf(fid, '%-18s', sprintf('%.4f*', fdr_var_all(i,k)));
        else
            fprintf(fid, '%-18.4f', fdr_var_all(i,k));
        end
    end
    fprintf(fid, '\n');
end

fprintf(fid, '\n(三) 显著结果汇总 (FDR校正后 p < 0.05)\n');
if isempty(row_all)
    fprintf(fid, '  无显著结果\n\n');
else
    fprintf(fid, '%-10s %-18s %-12s %-12s %-12s\n', '量表维度', '脑网络指标', '相关系数', '原始p值', 'FDR_p值');
    fprintf(fid, repmat('-', 1, 64));
    fprintf(fid, '\n');
    for i = 1:length(row_all)
        fprintf(fid, '%-10s %-18s %-12.4f %-12.4f %-12.4f\n', ...
            score_names{row_all(i)}, indicator_names{col_all(i)}, ...
            r_all(row_all(i), col_all(i)), raw_p_all(row_all(i), col_all(i)), ...
            fdr_var_all(row_all(i), col_all(i)));
    end
    fprintf(fid, '\n');
end

% 依赖组结果
fprintf(fid, '========================================\n');
fprintf(fid, '三、依赖组偏相关分析结果\n');
fprintf(fid, '========================================\n\n');

fprintf(fid, '(一) 原始p值与相关系数\n');
fprintf(fid, '%-10s', '量表维度');
for k = 1:4
    fprintf(fid, '%-15s', [indicator_names{k} '_r']);
    fprintf(fid, '%-15s', [indicator_names{k} '_p']);
end
fprintf(fid, '\n');
fprintf(fid, repmat('-', 1, 130));
fprintf(fid, '\n');

for i = 1:6
    fprintf(fid, '%-10s', score_names{i});
    for k = 1:4
        fprintf(fid, '%-15.4f', r_sd(i,k));
        fprintf(fid, '%-15.4f', raw_p_sd(i,k));
    end
    fprintf(fid, '\n');
end

fprintf(fid, '\n(二) FDR校正后p值\n');
fprintf(fid, '%-10s', '量表维度');
for k = 1:4
    fprintf(fid, '%-18s', [indicator_names{k} '_FDR']);
end
fprintf(fid, '\n');
fprintf(fid, repmat('-', 1, 82));
fprintf(fid, '\n');

for i = 1:6
    fprintf(fid, '%-10s', score_names{i});
    for k = 1:4
        if fdr_var_sd(i,k) < 0.05
            fprintf(fid, '%-18s', sprintf('%.4f*', fdr_var_sd(i,k)));
        else
            fprintf(fid, '%-18.4f', fdr_var_sd(i,k));
        end
    end
    fprintf(fid, '\n');
end

fprintf(fid, '\n(三) 显著结果汇总 (FDR校正后 p < 0.05)\n');
if isempty(row_sd)
    fprintf(fid, '  无显著结果\n\n');
else
    fprintf(fid, '%-10s %-18s %-12s %-12s %-12s\n', '量表维度', '脑网络指标', '相关系数', '原始p值', 'FDR_p值');
    fprintf(fid, repmat('-', 1, 64));
    fprintf(fid, '\n');
    for i = 1:length(row_sd)
        fprintf(fid, '%-10s %-18s %-12.4f %-12.4f %-12.4f\n', ...
            score_names{row_sd(i)}, indicator_names{col_sd(i)}, ...
            r_sd(row_sd(i), col_sd(i)), raw_p_sd(row_sd(i), col_sd(i)), ...
            fdr_var_sd(row_sd(i), col_sd(i)));
    end
    fprintf(fid, '\n');
end

% 控制组结果
fprintf(fid, '========================================\n');
fprintf(fid, '四、控制组偏相关分析结果\n');
fprintf(fid, '========================================\n\n');

fprintf(fid, '(一) 原始p值与相关系数\n');
fprintf(fid, '%-10s', '量表维度');
for k = 1:4
    fprintf(fid, '%-15s', [indicator_names{k} '_r']);
    fprintf(fid, '%-15s', [indicator_names{k} '_p']);
end
fprintf(fid, '\n');
fprintf(fid, repmat('-', 1, 130));
fprintf(fid, '\n');

for i = 1:6
    fprintf(fid, '%-10s', score_names{i});
    for k = 1:4
        fprintf(fid, '%-15.4f', r_ctr(i,k));
        fprintf(fid, '%-15.4f', raw_p_ctr(i,k));
    end
    fprintf(fid, '\n');
end

fprintf(fid, '\n(二) FDR校正后p值\n');
fprintf(fid, '%-10s', '量表维度');
for k = 1:4
    fprintf(fid, '%-18s', [indicator_names{k} '_FDR']);
end
fprintf(fid, '\n');
fprintf(fid, repmat('-', 1, 82));
fprintf(fid, '\n');

for i = 1:6
    fprintf(fid, '%-10s', score_names{i});
    for k = 1:4
        if fdr_var_ctr(i,k) < 0.05
            fprintf(fid, '%-18s', sprintf('%.4f*', fdr_var_ctr(i,k)));
        else
            fprintf(fid, '%-18.4f', fdr_var_ctr(i,k));
        end
    end
    fprintf(fid, '\n');
end

fprintf(fid, '\n(三) 显著结果汇总 (FDR校正后 p < 0.05)\n');
if isempty(row_ctr)
    fprintf(fid, '  无显著结果\n\n');
else
    fprintf(fid, '%-10s %-18s %-12s %-12s %-12s\n', '量表维度', '脑网络指标', '相关系数', '原始p值', 'FDR_p值');
    fprintf(fid, repmat('-', 1, 64));
    fprintf(fid, '\n');
    for i = 1:length(row_ctr)
        fprintf(fid, '%-10s %-18s %-12.4f %-12.4f %-12.4f\n', ...
            score_names{row_ctr(i)}, indicator_names{col_ctr(i)}, ...
            r_ctr(row_ctr(i), col_ctr(i)), raw_p_ctr(row_ctr(i), col_ctr(i)), ...
            fdr_var_ctr(row_ctr(i), col_ctr(i)));
    end
    fprintf(fid, '\n');
end

% 报告尾部
fprintf(fid, '========================================\n');
fprintf(fid, '五、总结\n');
fprintf(fid, '========================================\n\n');
fprintf(fid, '显著结果统计:\n');
fprintf(fid, '  全体被试: %d 个显著相关\n', length(row_all));
fprintf(fid, '  依赖组: %d 个显著相关\n', length(row_sd));
fprintf(fid, '  控制组: %d 个显著相关\n\n', length(row_ctr));

fprintf(fid, '注释:\n');
fprintf(fid, '  * 表示 FDR 校正后 p < 0.05\n');
fprintf(fid, '  GCC: 全局聚类系数 (Global Clustering Coefficient)\n');
fprintf(fid, '  S: 特征路径长度 (Characteristic Path Length)\n');
fprintf(fid, '  Degree_Node30: 节点30度中心性 (Left_Limbic_TempPole_2)\n');
fprintf(fid, '  Degree_Node86: 节点86度中心性 (Right_ContB_PFClv_1)\n\n');

fprintf(fid, '报告生成完毕。\n');
fclose(fid);

fprintf('报告已保存至: %s\n', report_filename);

%% 8. 保存完整结果到MAT文件
results_data.raw_p_all = raw_p_all;
results_data.raw_p_sd = raw_p_sd;
results_data.raw_p_ctr = raw_p_ctr;
results_data.fdr_var_all = fdr_var_all;
results_data.fdr_var_sd = fdr_var_sd;
results_data.fdr_var_ctr = fdr_var_ctr;
results_data.r_all = r_all;
results_data.r_sd = r_sd;
results_data.r_ctr = r_ctr;
results_data.score_names = score_names;
results_data.indicator_names = indicator_names;
results_data.sig_all = [row_all, col_all];
results_data.sig_sd = [row_sd, col_sd];
results_data.sig_ctr = [row_ctr, col_ctr];

save('偏相关分析完整结果.mat', 'results_data');

fprintf('\n========================================\n');
fprintf('分析完成!\n');
fprintf('========================================\n');
fprintf('生成的文件:\n');
fprintf('  1. %s (详细文本报告)\n', report_filename);
fprintf('  2. 偏相关分析完整结果.mat (完整数据)\n');
fprintf('  3. global_parrp_result.mat (全局指标结果)\n');
fprintf('  4. local_parrp_result30.mat (节点30结果)\n');
fprintf('  5. local_parrp_result86.mat (节点86结果)\n');
fprintf('========================================\n\n');
