%% 
% 提取所有被试的score4数据（第4个子量表）
y = allscore(:, 4); 

% 提取对应的全局gcc数据（合并后的ctr和sd）
gcc_all = vertcat(global_data.gcc{1, 1}', global_data.gcc{1, 2}');

% 控制变量：性别和年龄
ctrl_vars = ctrvar_all; % [var2_all, var3_all]

%% 
% 对y（score4）回归掉性别和年龄的影响
X = [ones(size(ctrl_vars,1),1), ctrl_vars]; % 设计矩阵（含截距）
beta_y = X \ y;
resid_y = y - X * beta_y;

% 对x（gcc）回归掉性别和年龄的影响
beta_x = X \ gcc_all;
resid_x = gcc_all - X * beta_x;

%% 
figure;
scatter(resid_x, resid_y, 'filled');
hold on;

% 添加拟合线（斜率直接来自偏相关系数）
p = polyfit(resid_x, resid_y, 1);
fit_y = polyval(p, resid_x);
plot(resid_x, fit_y, 'r', 'LineWidth', 2);

% 标注相关系数和p值
r = global_rvalue{1,3}(4,1); % 从global_rvalue获取r值
p_value = global_r{1,3}(4,1); % 从global_r获取p值
text(min(resid_x), max(resid_y), ...
    sprintf('r = %.3f\np = %.3f', r, p_value), ...
    'VerticalAlignment', 'top');

% 坐标轴标签
xlabel('Residuals of GCC (controlled for age & gender)');
ylabel('Residuals of Score4 (controlled for age & gender)');
title('Partial Correlation between Score4 and GCC');

hold off;