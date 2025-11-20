function plotPartialCorrWithColor_group(x_data, y_data, ctrl_vars, r_value, p_value, x_label, y_label, colorGroups)
    % 参数说明：
    % colorGroups - 3x3矩阵，前两行为点颜色，第三行为直线颜色
    
    % 数据长度验证
    assert(length(x_data) == 66, '必须包含66个观测值');
    
    % 计算残差
    X = [ones(size(ctrl_vars,1),1) ctrl_vars];
    beta_y = X \ y_data;
    resid_y = y_data - X * beta_y;
    beta_x = X \ x_data;
    resid_x = x_data - X * beta_x;
    
    % 线性拟合
    p = polyfit(resid_x, resid_y, 1);
    y_fit = polyval(p, resid_x);
    
    % 创建图形
    figure;
    
    % 分组绘制散点
    scatter(resid_x(1:44), resid_y(1:44), 70, 'filled',...
        'MarkerFaceColor', colorGroups(1,:),...
        'MarkerEdgeColor', colorGroups(1,:)*0.6,...
        'LineWidth', 1.5);
    hold on;
    scatter(resid_x(45:66), resid_y(45:66), 70, 'filled',...
        'MarkerFaceColor', colorGroups(2,:),...
        'MarkerEdgeColor', colorGroups(2,:)*0.6,...
        'LineWidth', 1.5);
    
    % 绘制拟合线（使用第三组颜色）
    plot(resid_x, y_fit,...
        'Color', colorGroups(3,:)*0.8,...
        'LineWidth', 3,...
        'LineStyle', '-');
    
    % 注解文本
    annotationText = sprintf('r = %.2f\np = %.3f', r_value, p_value);
    text(max(resid_x)*0.95, max(resid_y)*0.95, annotationText,...
        'FontSize', 26,...
        'FontWeight', 'bold',...
        'Color', [0.3 0.3 0.3],...
        'VerticalAlignment', 'top',...
        'HorizontalAlignment', 'right',...
        'BackgroundColor', [1 1 1 0.7]);
    
    % 坐标轴标签
    xlabel(x_label, 'FontSize', 26, 'FontWeight', 'bold');
    ylabel(y_label, 'FontSize', 26, 'FontWeight', 'bold');
    title(sprintf('%s vs %s', strrep(y_label,'Residual ',''), strrep(x_label,'Residual ','')),...
        'FontSize', 26, 'FontWeight', 'bold');
    
    % 网格和样式
    grid on;
    set(gca, 'GridLineStyle', ':', 'GridColor', [0.5 0.5 0.5], 'GridAlpha', 0.4);
    box on;
    set(gca, 'LineWidth', 1.5);
    set(gca, 'FontSize', 26)  % 控制刻度数字大小
    
    % 计算坐标轴范围并添加边距
    x_min = min(resid_x);
    x_max = max(resid_x);
    y_min = min(resid_y);
    y_max = max(resid_y);
    
    padding_factor = 0.10; % 边距系数，可调整
    
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
    set(gcf, 'Position', [100 100 600 500]);
end