% 展示散点图和拟合线
figure;
scatter(allscore_table.NeuralActivity_gcc, allscore_table.TotalScore, 'filled');
hold on;
x_values = linspace(min(allscore_table.NeuralActivity_gcc), max(allscore_table.NeuralActivity_gcc), 100);
y_values = model3.Coefficients.Estimate(1) + model3.Coefficients.Estimate(4) * x_values;
plot(x_values, y_values, 'r', 'LineWidth', 2);
title('NeuralActivity\_gcc 与 TotalScore 的关系');
xlabel('NeuralActivity\_gcc');
ylabel('TotalScore');
legend('数据点', '拟合线');
hold off;
saveas(gcf, 'scatter_plot_with_fit.png');

% % 展示残差图
% figure;
% plotResiduals(model2, 'fitted');
% title('模型 2 的残差图');
% xlabel('拟合值');
% ylabel('残差');
% saveas(gcf, 'residual_plot.png');

% 展示模型比较结果
model_names = {'模型 1', '模型 2', '模型 3'};
r_squared = [model1.Rsquared.Adjusted; model2.Rsquared.Adjusted; model3.Rsquared.Adjusted];
p_values = [coefTest(model1); coefTest(model2); coefTest(model3)];
results_table = table(model_names', r_squared, p_values, 'VariableNames', {'模型', '调整R²', 'p值'});
disp(results_table);
writetable(results_table, 'model_comparison_results.csv');

