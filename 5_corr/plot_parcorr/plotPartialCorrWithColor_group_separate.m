function plotPartialCorrWithColor_group_separate(x_data, y_data, ctrl_vars, r_value, p_value, x_label, y_label, colorGroups)
    % 绘制分组偏相关散点图，每组有各自的拟合直线
    % 参数说明：
    % x_data - 自变量数据（66x1）
    % y_data - 因变量数据（66x1）
    % ctrl_vars - 控制变量矩阵（66x2，性别和年龄）
    % r_value - 整体偏相关系数
    % p_value - 整体p值
    % x_label - X轴标签
    % y_label - Y轴标签
    % colorGroups - 3x3矩阵，第1行为控制组颜色，第2行为依赖组颜色，第3行备用
    
    % 数据长度验证
    assert(length(x_data) == 66, '必须包含66个观测值');
    
    % 分组索引
    group1_idx = 1:44;   % 控制组
    group2_idx = 45:66;  % 依赖组
    
    % 计算残差（控制性别和年龄）
    X = [ones(size(ctrl_vars,1),1) ctrl_vars];
    beta_y = X \ y_data;
    resid_y = y_data - X * beta_y;
    beta_x = X \ x_data;
    resid_x = x_data - X * beta_x;
    
    % 分组数据
    resid_x_group1 = resid_x(group1_idx);
    resid_y_group1 = resid_y(group1_idx);
    resid_x_group2 = resid_x(group2_idx);
    resid_y_group2 = resid_y(group2_idx);
    
    % 分组拟合直线
    p1 = polyfit(resid_x_group1, resid_y_group1, 1);
    y_fit_group1 = polyval(p1, resid_x_group1);
    
    p2 = polyfit(resid_x_group2, resid_y_group2, 1);
    y_fit_group2 = polyval(p2, resid_x_group2);
    
    % 计算分组偏相关系数
    [r_group1, p_group1] = partialcorr(x_data(group1_idx), y_data(group1_idx), ctrl_vars(group1_idx,:));
    [r_group2, p_group2] = partialcorr(x_data(group2_idx), y_data(group2_idx), ctrl_vars(group2_idx,:));
    
    % 创建图形
    figure;
    
    % 绘制控制组散点
    scatter(resid_x_group1, resid_y_group1, 70, 'filled',...
        'MarkerFaceColor', colorGroups(1,:),...
        'MarkerEdgeColor', colorGroups(1,:)*0.6,...
        'LineWidth', 1.5);
    hold on;
    
    % 绘制依赖组散点
    scatter(resid_x_group2, resid_y_group2, 70, 'filled',...
        'MarkerFaceColor', colorGroups(2,:),...
        'MarkerEdgeColor', colorGroups(2,:)*0.6,...
        'LineWidth', 1.5);
    
    % 绘制控制组拟合线
    plot(resid_x_group1, y_fit_group1,...
        'Color', colorGroups(1,:)*0.7,...
        'LineWidth', 3,...
        'LineStyle', '-');
    
    % 绘制依赖组拟合线
    plot(resid_x_group2, y_fit_group2,...
        'Color', colorGroups(2,:)*0.7,...
        'LineWidth', 3,...
        'LineStyle', '-');
    
    % 整体注解文本（右上角）
    annotationText_overall = sprintf('整体: r = %.2f, p = %.3f', r_value, p_value);
    text(max(resid_x)*0.95, max(resid_y)*0.95, annotationText_overall,...
        'FontSize', 22,...
        'FontWeight', 'bold',...
        'Color', [0.3 0.3 0.3],...
        'VerticalAlignment', 'top',...
        'HorizontalAlignment', 'right',...
        'BackgroundColor', [1 1 1 0.7]);
    
    % 控制组注解文本（左下角）
    annotationText_group1 = sprintf('控制组: r = %.2f, p = %.3f', r_group1, p_group1);
    text(min(resid_x)*0.95, min(resid_y)*0.95, annotationText_group1,...
        'FontSize', 20,...
        'FontWeight', 'bold',...
        'Color', colorGroups(1,:)*0.7,...
        'VerticalAlignment', 'bottom',...
        'HorizontalAlignment', 'left',...
        'BackgroundColor', [1 1 1 0.7]);
    
    % 依赖组注解文本（左上角）
    annotationText_group2 = sprintf('依赖组: r = %.2f, p = %.3f', r_group2, p_group2);
    text(min(resid_x)*0.95, max(resid_y)*0.85, annotationText_group2,...
        'FontSize', 20,...
        'FontWeight', 'bold',...
        'Color', colorGroups(2,:)*0.7,...
        'VerticalAlignment', 'top',...
        'HorizontalAlignment', 'left',...
        'BackgroundColor', [1 1 1 0.7]);
    
    % 坐标轴标签
    xlabel(x_label, 'FontSize', 26, 'FontWeight', 'bold');
    ylabel(y_label, 'FontSize', 26, 'FontWeight', 'bold');
    title(sprintf('%s vs %s (分组拟合)', strrep(y_label,'Residual ',''), strrep(x_label,'Residual ','')),...
        'FontSize', 26, 'FontWeight', 'bold');
    
    % 添加图例
    legend({'控制组', '依赖组', '控制组拟合', '依赖组拟合'},...
        'Location', 'best',...
        'FontSize', 18,...
        'Box', 'on');
    
    % 网格和样式
    grid on;
    set(gca, 'GridLineStyle', ':', 'GridColor', [0.5 0.5 0.5], 'GridAlpha', 0.4);
    box on;
    set(gca, 'LineWidth', 1.5);
    set(gca, 'FontSize', 26);  % 控制刻度数字大小
    
    % 计算坐标轴范围并添加边距
    x_min = min(resid_x);
    x_max = max(resid_x);
    y_min = min(resid_y);
    y_max = max(resid_y);
    
    padding_factor = 0.15; % 边距系数，增大以容纳注解
    
    padding_x = padding_factor * (x_max - x_min);
    padding_y = padding_factor * (y_max - y_min);
    
    % 处理全零数据情况
    if padding_x == 0
        padding_x = 0.5 * max(abs(resid_x));
    end
    if padding_y == 0
        padding_y = 0.5 * max(abs(resid_y));
    end
    
    % 设置坐标轴范围
    xlim([x_min - padding_x, x_max + padding_x]);
    ylim([y_min - padding_y, y_max + padding_y]);
    
    % 统一尺寸
    set(gcf, 'Position', [100 100 700 600]);
end
