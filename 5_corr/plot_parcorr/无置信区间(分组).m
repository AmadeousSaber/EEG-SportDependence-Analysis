%% 主程序
% 加载数据、计算分数等原有代码保持不变
load("r_value_plot.mat")

%% 绘制所有指定相关系数的图形
% 定义控制变量和全局数据
ctrl_all = ctrvar_all; % [性别, 年龄]
gcc_all = vertcat(global_data.gcc{1,1}', global_data.gcc{1,2}');
s_all = vertcat(global_data.s{1,1}', global_data.s{1,2}');
all_scores = allscore; % 所有分数列

%% 定义双色分组方案（前44/后22）
colorGroups = [0.00 0.45 0.74    % 前44点颜色（绿色）
               0.8  0.3  0.4   % 后22点颜色（珊瑚红）
               0.49 0.18 0.56]; % 直线颜色（紫色）

%% 绘制所有图形（使用统一配色）
% 案例1: GCC vs Score4
plotPartialCorrWithColor_group(gcc_all, all_scores(:,4), ctrvar_all,...
    global_rvalue{1,3}(4,1), global_r{1,3}(4,1),...
    '全局聚类系数', '失控', colorGroups);

% 案例2: GCC vs Total
plotPartialCorrWithColor_group(gcc_all, all_scores(:,6), ctrl_all,...
    global_rvalue{1,3}(6,1), global_r{1,3}(6,1),...
    '全局聚类系数', '总分', colorGroups);

% 案例3: S vs Score4
plotPartialCorrWithColor_group(s_all, all_scores(:,4), ctrl_all,...
    global_rvalue{2,3}(4,1), global_r{2,3}(4,1),...
    '小世界性', '失控', colorGroups);

% 案例4: S vs Total
plotPartialCorrWithColor_group(s_all, all_scores(:,6), ctrl_all,...
    global_rvalue{2,3}(6,1), global_r{2,3}(6,1),...
    '小世界性', '总分', colorGroups);

% 案例5: Local vs Score5
load('local_parrp_result30.mat');
local_degree_all = vertcat(local_data.degree{2,1}(:,30), local_data.degree{2,2}(:,30));
plotPartialCorrWithColor_group(local_degree_all, all_scores(:,5), ctrl_all,...
    local_rvalue{1,3}(5,1), local_r{1,3}(5,1),...
    '节点度（左侧颞极）', '减少其他活动', colorGroups);

% 案例6: Local vs Total
plotPartialCorrWithColor_group(local_degree_all, all_scores(:,6), ctrl_all,...
    local_rvalue{1,3}(6,1), local_r{1,3}(6,1),...
    '节点度（左侧颞极）', '总分', colorGroups);

