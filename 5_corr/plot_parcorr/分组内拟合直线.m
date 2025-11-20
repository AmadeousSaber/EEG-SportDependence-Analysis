%% 主程序 - 分组内拟合直线偏相关图
% 加载数据、计算分数等原有代码保持不变
load("r_value_plot.mat")

%% 绘制所有指定相关系数的图形（每组独立拟合）
% 定义控制变量和全局数据
ctrl_all = ctrvar_all; % [性别, 年龄]
gcc_all = vertcat(global_data.gcc{1,1}', global_data.gcc{1,2}');
s_all = vertcat(global_data.s{1,1}', global_data.s{1,2}');
all_scores = allscore; % 所有分数列

%% 定义双色分组方案（前44控制组/后22依赖组）
colorGroups = [0.00 0.45 0.74    % 前44点颜色（蓝色）
               0.8  0.3  0.4     % 后22点颜色（珊瑚红）
               0.49 0.18 0.56];  % 直线颜色（紫色）

%% 绘制所有图形（使用分组内独立拟合）
fprintf('开始绘制分组内拟合直线偏相关图...\n');

% 案例1: GCC vs Score4 (失控)
fprintf('绘制图1: 全局聚类系数 vs 失控...\n');
plotPartialCorrWithColor_group_separate(gcc_all, all_scores(:,4), ctrvar_all,...
    global_rvalue{1,3}(4,1), global_r{1,3}(4,1),...
    '全局聚类系数', '失控', colorGroups);

% 案例2: GCC vs Total (总分)
fprintf('绘制图2: 全局聚类系数 vs 总分...\n');
plotPartialCorrWithColor_group_separate(gcc_all, all_scores(:,6), ctrl_all,...
    global_rvalue{1,3}(6,1), global_r{1,3}(6,1),...
    '全局聚类系数', '总分', colorGroups);

% 案例3: S vs Score4 (失控)
fprintf('绘制图3: 小世界性 vs 失控...\n');
plotPartialCorrWithColor_group_separate(s_all, all_scores(:,4), ctrl_all,...
    global_rvalue{2,3}(4,1), global_r{2,3}(4,1),...
    '小世界性', '失控', colorGroups);

% 案例4: S vs Total (总分)
fprintf('绘制图4: 小世界性 vs 总分...\n');
plotPartialCorrWithColor_group_separate(s_all, all_scores(:,6), ctrl_all,...
    global_rvalue{2,3}(6,1), global_r{2,3}(6,1),...
    '小世界性', '总分', colorGroups);

% 案例5: Local vs Score5 (减少其他活动)
fprintf('绘制图5: 节点度（左侧颞极） vs 减少其他活动...\n');
load('local_parrp_result30.mat');
local_degree_all = vertcat(local_data.degree{2,1}(:,30), local_data.degree{2,2}(:,30));
plotPartialCorrWithColor_group_separate(local_degree_all, all_scores(:,5), ctrl_all,...
    local_rvalue{1,3}(5,1), local_r{1,3}(5,1),...
    '节点度（左侧颞极）', '减少其他活动', colorGroups);

% 案例6: Local vs Total (总分)
fprintf('绘制图6: 节点度（左侧颞极） vs 总分...\n');
plotPartialCorrWithColor_group_separate(local_degree_all, all_scores(:,6), ctrl_all,...
    local_rvalue{1,3}(6,1), local_r{1,3}(6,1),...
    '节点度（左侧颞极）', '总分', colorGroups);

fprintf('\n所有图形绘制完成！\n');
fprintf('说明: 每张图包含:\n');
fprintf('  - 控制组和依赖组的散点（不同颜色）\n');
fprintf('  - 各组独立的拟合直线\n');
fprintf('  - 整体偏相关系数（右上角）\n');
fprintf('  - 控制组偏相关系数（左下角）\n');
fprintf('  - 依赖组偏相关系数（左上角）\n');
