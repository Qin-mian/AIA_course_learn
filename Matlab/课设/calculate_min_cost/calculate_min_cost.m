function calculate_min_cost(app)
% 从编辑字段获取参数值
    beta = app.edit_beta.Value;
    lambda = app.edit_lambda.Value;
    t1 = app.edit_t1.Value;
    c1 = app.edit_c1.Value;
    c2 = app.edit_c2.Value;
    c3 = app.edit_c3.Value;

    % 调用优化求解函数
    [x_optimal, min_cost, t2] = solve_optimize_constrained(beta, lambda, t1, c1, c2, c3);

    % 更新输出结果
    app.output_min_cost.Value = min_cost;
    app.output_optimal_x.Value = x_optimal;
    app.optimal_t2.Value = t2;

    % 在最小点附近取20个点绘制曲线
    delta = round(x_optimal/10); % 确定取点的范围
    x_values = max(x_optimal - 10*max(delta,1), ceil(beta / lambda))  : 1 : x_optimal + 10 * max(delta,1);

    % 计算每个点的目标值
    Z = arrayfun(@(x) objective(x, t1, beta, lambda, c1, c2, c3), x_values);
    cla(app.ax_optimal);
    % 画图
    plot(app.ax_optimal, x_values, Z);

    % 标记最小点
    hold(app.ax_optimal, 'on');
    plot(app.ax_optimal, x_optimal, min_cost, 'r*', 'MarkerSize', 10);
    hold(app.ax_optimal, 'off');
end

function cost = objective(x, t1, beta, lambda, c1, c2, c3)
    % 目标函数，x 是优化变量，t1 是输入
    t2 = (lambda * x / (lambda * x - beta)) * t1;
    t_ext = t2 - t1;
    burned_area = ((beta * t1^2) / 2 + beta * t1 * t_ext + 0.5 * (beta - lambda * x) * (t_ext^2));
    
    % 计算成本
    cost = c1 * burned_area + c2 * x * t_ext + c3*x;
end

function [x_optimal, min_cost, t2] = solve_optimize_constrained(beta, lambda, t1, c1, c2, c3)
    % 目标函数
    objective_func = @(x) objective(x, t1, beta, lambda, c1, c2, c3);
    
    % 设置遗传算法选项
    options = optimoptions('ga', 'Display', 'iter', 'MaxGenerations', 100, 'MaxStallGenerations', 50, 'PopulationSize', 50, 'CrossoverFraction', 0.8, 'EliteCount', 2);

    % 设置遗传算法约束：x >= ceil(beta / lambda) + 1，并且 x 必须为整数
    lb = ceil(beta / lambda); % 最小值
    ub = 100; % 假设上限为 100，你可以根据实际情况调整

    % 求解：使用遗传算法
    [x_optimal, ~] = ga(objective_func, 1, [], [], [], [], lb, ub, [], options); % 1 代表我们优化的是一个变量 x
    
    % x四舍五入
    x_optimal = round(x_optimal);
    min_cost = objective(x_optimal, t1, beta, lambda, c1, c2, c3);

    % 计算 t2
    t2 = (lambda * x_optimal / (lambda * x_optimal - beta)) * t1;

    % 输出最优结果
    disp(['Optimal x: ', num2str(x_optimal)]);
    disp(['Minimum cost: ', num2str(min_cost)]);
end
