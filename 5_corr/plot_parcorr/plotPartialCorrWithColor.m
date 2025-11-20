%% 美化版绘图函数
function plotPartialCorrWithColor(x_data, y_data, ctrl_vars, r_value, p_value, x_label, y_label, color)
    % 计算残差
    X = [ones(size(ctrl_vars,1),1) ctrl_vars];
    beta_y = X \ y_data;
    resid_y = y_data - X * beta_y;
    beta_x = X \ x_data;
    resid_x = x_data - X * beta_x;
    
    % 线性拟合与预测
    p = polyfit(resid_x, resid_y, 1);
    y_fit = polyval(p, resid_x);
    
    % 创建图形
    figure;
    
    % 绘制散点图（带边缘线）
    scatter(resid_x, resid_y, 50, 'filled',...
        'MarkerFaceColor', color,...
        'MarkerEdgeColor', color*0.6,...
        'LineWidth', 1.5);
    
    % 绘制拟合线（更粗的线宽）
    hold on;
    plot(resid_x, y_fit,...
        'Color', color*0.8,...
        'LineWidth', 3,...
        'LineStyle', '-');
    
    % 美化标注
    annotationText = sprintf('r = %.2f\np = %.3f', r_value, p_value);
    text(max(resid_x)*0.95, max(resid_y)*0.95, annotationText,...
        'FontSize', 12,...
        'FontWeight', 'bold',...
        'Color', [0.3 0.3 0.3],...
        'VerticalAlignment', 'top',...
        'HorizontalAlignment', 'right',...
        'BackgroundColor', [1 1 1 0.7]); % 半透明背景
    
    % 坐标轴美化
    xlabel(x_label, 'FontSize', 14, 'FontWeight', 'bold');
    ylabel(y_label, 'FontSize', 14, 'FontWeight', 'bold');
    title(sprintf('%s vs %s', strrep(y_label,'Residual ',''), strrep(x_label,'Residual ','')),...
        'FontSize', 16, 'FontWeight', 'bold');
    
    % 网格和框线
    grid on;
    set(gca, 'GridLineStyle', ':', 'GridColor', [0.5 0.5 0.5], 'GridAlpha', 0.4);
    box on;
    set(gca, 'LineWidth', 1.5);
    
    % 设置坐标区边距
    axis tight
    padding = 0.1*(max(resid_x)-min(resid_x));
    xlim([min(resid_x)-padding max(resid_x)+padding])
    
    % 统一图形尺寸
    set(gcf, 'Position', [100 100 600 500]); % 统一图片尺寸为600x500像素
end