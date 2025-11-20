%% 主程序
% 加载数据、计算分数等原有代码保持不变（此处省略重复部分）
load("r_value_plot.mat")

%% 绘制所有指定相关系数的图形
% 定义控制变量和全局数据
ctrl_all = ctrvar_all; % [性别, 年龄]
gcc_all = vertcat(global_data.gcc{1,1}', global_data.gcc{1,2}');
s_all = vertcat(global_data.s{1,1}', global_data.s{1,2}');
all_scores = allscore; % 所有分数列

% 案例1: global_r{1,3}(6,1) - GCC vs Total
plotPartialCorrWithCI(gcc_all, all_scores(:,6), ctrl_all, ...
    global_rvalue{1,3}(6,1), global_r{1,3}(6,1), ...
    'Residual GCC', 'Residual Total Score');

% 案例2: global_r{2,3}(4,1) - S vs Score4
plotPartialCorrWithCI(s_all, all_scores(:,4), ctrl_all, ...
    global_rvalue{2,3}(4,1), global_r{2,3}(4,1), ...
    'Residual S', 'Residual Score4');

% 案例3: global_r{2,3}(6,1) - S vs Total
plotPartialCorrWithCI(s_all, all_scores(:,6), ctrl_all, ...
    global_rvalue{2,3}(6,1), global_r{2,3}(6,1), ...
    'Residual S', 'Residual Total Score');

% 案例4: local_r{1,3}(5,1) - 脑区30的Degree vs Score5
load('local_parrp_result30.mat'); % 确保已加载局部数据
local_degree_all = vertcat(local_data.degree{2,1}(:,30), local_data.degree{2,2}(:,30));
plotPartialCorrWithCI(local_degree_all, all_scores(:,5), ctrl_all, ...
    local_rvalue{1,3}(5,1), local_r{1,3}(5,1), ...
    'Residual Degree (Region30)', 'Residual Score5');

% 案例5: local_r{1,3}(6,1) - 脑区30的Degree vs Total
plotPartialCorrWithCI(local_degree_all, all_scores(:,6), ctrl_all, ...
    local_rvalue{1,3}(6,1), local_r{1,3}(6,1), ...
    'Residual Degree (Region30)', 'Residual Total Score');

%% 嵌套函数定义（放在脚本末尾）
function plotPartialCorrWithCI(x_data, y_data, ctrl_vars, r_value, p_value, x_label, y_label)
    % 计算残差
    X = [ones(size(ctrl_vars,1),1), ctrl_vars]; 
    beta_y = X \ y_data;
    resid_y = y_data - X * beta_y;
    beta_x = X \ x_data;
    resid_x = x_data - X * beta_x;
    
    % 拟合及置信区间
    [p, S] = polyfit(resid_x, resid_y, 1);
    [y_fit, delta] = polyconf(p, resid_x, S, 'predopt', 'curve', 'alpha', 0.05);
    
    % 绘图
    figure;
    scatter(resid_x, resid_y, 40, 'filled', 'MarkerFaceColor', [0.2 0.4 0.6]);
    hold on;
    plot(resid_x, y_fit, 'r-', 'LineWidth', 2);
    plot(resid_x, y_fit + delta, 'r--', 'LineWidth', 1.5);
    plot(resid_x, y_fit - delta, 'r--', 'LineWidth', 1.5);
    text(min(resid_x), max(resid_y), ...
        sprintf('r = %.3f\np = %.3f', r_value, p_value), ...
        'VerticalAlignment', 'top', 'FontSize', 10);
    xlabel(x_label);
    ylabel(y_label);
    title(sprintf('%s vs %s', y_label, x_label));
    grid on;
    hold off;
end