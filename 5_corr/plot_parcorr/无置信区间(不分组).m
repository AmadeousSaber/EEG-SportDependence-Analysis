%% 主程序
% 加载数据、计算分数等原有代码保持不变
load("r_value_plot.mat")

%% 绘制所有指定相关系数的图形
% 定义控制变量和全局数据
ctrl_all = ctrvar_all; % [性别, 年龄]
gcc_all = vertcat(global_data.gcc{1,1}', global_data.gcc{1,2}');
s_all = vertcat(global_data.s{1,1}', global_data.s{1,2}');
all_scores = allscore; % 所有分数列

%% 定义美观颜色方案（6种不同颜色）
colors = [
    0.00 0.45 0.74   % 蓝色
    0.85 0.33 0.10   % 橙色
    0.93 0.69 0.13   % 金色
    0.49 0.18 0.56   % 紫色
    0.47 0.67 0.19   % 绿色
    0.64 0.08 0.18   % 红色
];

%% 绘制所有指定相关系数的图形
% 案例0: 蓝色主题
plotPartialCorrWithColor(gcc_all, all_scores(:,4), ctrvar_all,...
    global_rvalue{1,3}(4,1), global_r{1,3}(4,1),...
    'Residual GCC', 'Residual Score4', colors(1,:));

% 案例1: 橙色主题
plotPartialCorrWithColor(gcc_all, all_scores(:,6), ctrl_all,...
    global_rvalue{1,3}(6,1), global_r{1,3}(6,1),...
    'Residual GCC', 'Residual Total Score', colors(2,:));

% 案例2: 金色主题
plotPartialCorrWithColor(s_all, all_scores(:,4), ctrl_all,...
    global_rvalue{2,3}(4,1), global_r{2,3}(4,1),...
    'Residual S', 'Residual Score4', colors(3,:));

% 案例3: 紫色主题
plotPartialCorrWithColor(s_all, all_scores(:,6), ctrl_all,...
    global_rvalue{2,3}(6,1), global_r{2,3}(6,1),...
    'Residual S', 'Residual Total Score', colors(4,:));

% 案例4: 绿色主题
load('local_parrp_result30.mat');
local_degree_all = vertcat(local_data.degree{2,1}(:,30), local_data.degree{2,2}(:,30));
plotPartialCorrWithColor(local_degree_all, all_scores(:,5), ctrl_all,...
    local_rvalue{1,3}(5,1), local_r{1,3}(5,1),...
    'Residual Degree (Region30)', 'Residual Score5', colors(5,:));

% 案例5: 红色主题
plotPartialCorrWithColor(local_degree_all, all_scores(:,6), ctrl_all,...
    local_rvalue{1,3}(6,1), local_r{1,3}(6,1),...
    'Residual Degree (Region30)', 'Residual Total Score', colors(6,:));