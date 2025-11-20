%% 
ctr_filename = 'ctr_score.xlsx';
sd_filename = 'sd_score.xlsx';

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

%% 回归数据准备
% 两组被试数据
for i = 1:6
    ctrscore(:,i) = T_ctr{:, i+23};
    sdscore(:,i) = T_sd{:, i+23};
end
% 加入分组信息
ctrscore(:,7) = repmat(1, 44, 1);
sdscore(:,7) = repmat(2, 22, 1);
% 加入性别和年龄数据
ctrscore(:,[8 9]) = T_ctr{:, [2 3]};
sdscore(:,[8 9]) = T_sd{:, [2 3]};
% 加入神经数据
load('global_data_graph_aec.mat');
load('local_data_graph_aec.mat');  

ctrscore(:,10) = global_data.gcc{1, 1}';
ctrscore(:,11) = global_data.s{1, 1}';
ctrscore(:,12) = local_data.degree{2, 1}(:,30);
ctrscore(:,13) = local_data.degree{2, 1}(:,86);
sdscore(:,10) = global_data.gcc{1, 2}';
sdscore(:,11) = global_data.s{1, 2}';
sdscore(:,12) = local_data.degree{2, 2}(:,30);
sdscore(:,13) = local_data.degree{2, 2}(:,86);

allscore = vertcat(ctrscore, sdscore);


% 将矩阵转换为表格
allscore_table = array2table(allscore, 'VariableNames', {'Dim1', 'Dim2', 'Dim3', 'Dim4', 'Dim5', 'TotalScore', 'Group', 'Gender', 'Age', 'NeuralActivity_gcc', 'NeuralActivity_s' , 'degree_30' , 'degree_86'});

% 修改分类变量
allscore_table.Group = categorical(allscore_table.Group);
allscore_table.Gender = categorical(allscore_table.Gender);

%% 分层回归分析

% 准备
% 检查共线性
corr_matrix = corrcoef(table2array(allscore_table(:, {'NeuralActivity_gcc', 'NeuralActivity_s' , 'degree_30', 'degree_86'})));
disp('相关系数矩阵：');
disp(corr_matrix);

vif_values = diag(inv(corrcoef(table2array(allscore_table(:, {'NeuralActivity_gcc', 'NeuralActivity_s' , 'degree_30', 'degree_86'})))));
disp('VIF值：');
disp(vif_values);

% 对存在共线性的变量进行 PCA
NeuralActivity_global = table2array(allscore_table(:, {'NeuralActivity_gcc', 'NeuralActivity_s'}));
NeuralActivity_global_standardized = zscore(NeuralActivity_global);
[coeff_global, score_global, latent_global] = pca(NeuralActivity_global_standardized);

explained_variance = latent_global ./ sum(latent_global) * 100;
disp('主成分解释的方差比例：');
disp(explained_variance);

% 将第一个主成分得分加入数据表
allscore_table.PCA1 = score_global(:, 1);


% 步骤 1：仅引入控制变量
model1 = fitlm(allscore_table, 'TotalScore ~ Gender + Age');
disp('模型 1 结果:');
disp(model1);

% 步骤 2：分层引入神经活动变量
model2 = fitlm(allscore_table, 'TotalScore ~ Gender + Age + PCA1');
disp('模型 2 结果:');
disp(model2);

model3 = fitlm(allscore_table, 'TotalScore ~ Gender + Age + PCA1 + degree_30');
disp('模型 3 结果:');
disp(model3);


% 步骤 3：% 比较两个模型
% 使用 anova 比较模型;
% 提取模型 1 和模型 2 的残差平方和（SSR）和自由度（DF）
ssr2 = model2.SSE; % 模型 1 的残差平方和
ssr3 = model3.SSE; % 模型 2 的残差平方和

df2 = model2.DFE; % 模型 1 的自由度
df3 = model3.DFE; % 模型 2 的自由度

% 计算 F 统计量
n = size(allscore_table, 1); % 样本量
p2 = numel(model2.CoefficientNames); % 模型 1 的参数数量
p3 = numel(model3.CoefficientNames); % 模型 2 的参数数量

f_stat = ((ssr2 - ssr3) / (p3 - p2)) / (ssr3 / (n - p3));
p_value = 1 - fcdf(f_stat, p3 - p2, n - p3);

% 显示结果
disp(['F 统计量: ', num2str(f_stat)]);
disp(['p 值: ', num2str(p_value)]);


% 步骤 4：手动计算模型比较指标
r2_model1 = model1.Rsquared.Ordinary;
r2_model2 = model2.Rsquared.Ordinary;
r2_model3 = model3.Rsquared.Ordinary;

aic_model1 = model1.ModelCriterion.AIC;
aic_model2 = model2.ModelCriterion.AIC;
aic_model3 = model3.ModelCriterion.AIC;

bic_model1 = model1.ModelCriterion.BIC;
bic_model2 = model2.ModelCriterion.BIC;
bic_model3 = model3.ModelCriterion.BIC;

% 显示结果
disp(['模型 1 的 R²: ', num2str(r2_model1)]);
disp(['模型 2 的 R²: ', num2str(r2_model2)]);
disp(['模型 3 的 R²: ', num2str(r2_model3)]);
disp(['模型 1 的 AIC: ', num2str(aic_model1)]);
disp(['模型 2 的 AIC: ', num2str(aic_model2)]);
disp(['模型 3 的 AIC: ', num2str(aic_model3)]);
disp(['模型 1 的 BIC: ', num2str(bic_model1)]);
disp(['模型 2 的 BIC: ', num2str(bic_model2)]);
disp(['模型 3 的 BIC: ', num2str(bic_model3)]);


% 绘制模型拟合图
plot(model1);
plot(model2);
plot(model3);


% %% 考察第四个维度
% model4 = fitlm(allscore_table, 'Dim4 ~ Gender + Age');
% disp('模型 4 结果:');
% disp(model4);
% 
% % 步骤 2：分层引入神经活动变量
% model5 = fitlm(allscore_table, 'Dim4 ~ Gender + Age + degree_30');
% disp('模型 5 结果:');
% disp(model5);
% 
% model6 = fitlm(allscore_table, 'Dim4 ~ Gender + Age + degree_30 + PCA1');
% disp('模型 6 结果:');
% disp(model6);
% 
% % 步骤 3：% 比较两个模型
% % 使用 anova 比较模型;
% % 提取模型 1 和模型 2 的残差平方和（SSR）和自由度（DF）
% ssr2 = model5.SSE; % 模型 1 的残差平方和
% ssr3 = model6.SSE; % 模型 2 的残差平方和
% 
% df2 = model5.DFE; % 模型 1 的自由度
% df3 = model6.DFE; % 模型 2 的自由度
% 
% % 计算 F 统计量
% n = size(allscore_table, 1); % 样本量
% p2 = numel(model5.CoefficientNames); % 模型 1 的参数数量
% p3 = numel(model6.CoefficientNames); % 模型 2 的参数数量
% 
% f_stat = ((ssr2 - ssr3) / (p3 - p2)) / (ssr3 / (n - p3));
% p_value = 1 - fcdf(f_stat, p3 - p2, n - p3);
% 
% % 显示结果
% disp(['F 统计量: ', num2str(f_stat)]);
% disp(['p 值: ', num2str(p_value)]);
% 
% 
% %% 考察第五个维度
% model4 = fitlm(allscore_table, 'Dim5 ~ Gender + Age');
% disp('模型 4 结果:');
% disp(model4);
% 
% % 步骤 2：分层引入神经活动变量
% model5 = fitlm(allscore_table, 'Dim5 ~ Gender + Age + PCA1');
% disp('模型 5 结果:');
% disp(model5);
% 
% model6 = fitlm(allscore_table, 'Dim5 ~ Gender + Age + PCA1 + degree_30');
% disp('模型 6 结果:');
% disp(model6);
% 
% % 步骤 3：% 比较两个模型
% % 使用 anova 比较模型;
% % 提取模型 1 和模型 2 的残差平方和（SSR）和自由度（DF）
% ssr2 = model5.SSE; % 模型 1 的残差平方和
% ssr3 = model6.SSE; % 模型 2 的残差平方和
% 
% df2 = model5.DFE; % 模型 1 的自由度
% df3 = model6.DFE; % 模型 2 的自由度
% 
% % 计算 F 统计量
% n = size(allscore_table, 1); % 样本量
% p2 = numel(model5.CoefficientNames); % 模型 1 的参数数量
% p3 = numel(model6.CoefficientNames); % 模型 2 的参数数量
% 
% f_stat = ((ssr2 - ssr3) / (p3 - p2)) / (ssr3 / (n - p3));
% p_value = 1 - fcdf(f_stat, p3 - p2, n - p3);
% 
% % 显示结果
% disp(['F 统计量: ', num2str(f_stat)]);
% disp(['p 值: ', num2str(p_value)]);