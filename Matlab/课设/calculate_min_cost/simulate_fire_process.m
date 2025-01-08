function simulate_fire_process(app)    
    % 获取输入参数
    x = app.edit_x.Value;
    beta = app.edit_beta.Value;
    lambda = app.edit_lambda.Value;
    
    % 检查是否消防员数量不足
    if beta > lambda * x
        uialert(app.fig, '消防员太少！无法终止森林大火，Game Over！', '警告');
        return;
    end
    
    t1 = app.edit_t1.Value;
    c1 = app.edit_c1.Value;
    c2 = app.edit_c2.Value;
    c3 = app.edit_c3.Value;
    
    
    % 计算灭火时间
    t2_solution = solve_t2(beta, lambda, x, t1);

    % 动态绘制火灾与灭火过程
    cla(app.ax);
    time = linspace(0, t2_solution, 100);  % 按默认方式生成时间点
    time = unique([time, t1]);   % 强制加入 t1，并确保没有重复的时间点
    time = sort(time);           % 对时间点进行排序

    situation = zeros(size(time));
    firing = zeros(size(time));
    
    for i = 1:length(time)
        if time(i) <= t1
            % 计算火灾蔓延程度和燃烧面积
            situation(i) = calculate_burning_degree(beta,t1,lambda,x,time(i));  % 火灾蔓延程度
            firing(i) = calculate_burning_area(beta,t1,lambda,x,time(i));       % 火灾燃烧面积
            area_burned_before = firing(i);
            % 计算总成本
            [loss_fee, rescue_fee, total_cost] = calculate_cost(area_burned_before, 0, c1, c2, c3, x);
            
            % 更新输出结果
            app.output_area_burned_before.Value = area_burned_before;
            app.output_loss_fee.Value = loss_fee;
            app.output_total_cost.Value = total_cost;
            app.text.Value = "火焰正在蔓延！！！！";
        else
            t_ext = time(i) - t1;
            % 计算火灾蔓延程度和燃烧面积
            situation(i) = calculate_burning_degree(beta,t1,lambda,x,time(i));
            firing(i) = calculate_burning_area(beta,t1,lambda,x,time(i));

            area_burned_total = firing(i);
            % 计算总成本
            [loss_fee, rescue_fee, total_cost] = calculate_cost(area_burned_total, t_ext, c1, c2, c3, x);
            
            % 更新输出结果
            app.output_total_area_burned.Value = area_burned_total;
            app.output_loss_fee.Value = loss_fee;
            app.output_rescue_fee.Value = rescue_fee;
            app.output_total_cost.Value = total_cost;
            app.text.Value = "消防员施救中！！！！";
        end
        
        % 绘制火灾与灭火过程的曲线
        plot(app.ax, time(1:i), firing(1:i), 'b*-');
        drawnow;

        % 更新火焰燃烧程度曲线
        plot(app.ax_burning_degree, time(1:i), situation(1:i), 'r*-');
        drawnow;
        
        % 动态调整图像尺寸（例如根据 fire_degree 进行调整）
        scale_factor = max(situation(i) / max(situation),1e-6);  % 根据火灾蔓延程度计算缩放因子
        
        if (scale_factor<0.2)  % 红色
            app.Lamp.Color = [0, 1, 0];  % 变为绿色
            app.UIAxes.Color = [0, 1, 0];
        elseif (scale_factor<0.8 )  % 绿色
            app.Lamp.Color = [1, 1, 0];  % 变为黄色
            app.UIAxes.Color = [1, 1, 0];
        else
            app.Lamp.Color = [1, 0, 0];  % 变为红色
            app.UIAxes.Color = [1, 0, 0];
        end
       
    end
    app.text.Value = "灭火成功";
    % 更新灭火完成时间
    app.output_t2.Value = t2_solution;
end

function t2_solution = solve_t2(beta, lambda, x, t1)
    % 解方程：beta * t1 + (beta - lambda * x) * (t2 - t1) = 0
    syms t2;
    equation = beta * t1 + (beta - lambda * x) * (t2 - t1) == 0;
    t2_solution = double(solve(equation, t2));  % 转化为数值解
end

% 计算火灾总成本
function [loss_fee, rescue_fee, total_cost] = calculate_cost(area_burned, t_ext, c1, c2, c3, x)
    loss_fee = area_burned * c1;
    rescue_fee = c2 * x * t_ext + c3 * x;
    total_cost = loss_fee + rescue_fee;
end

% 计算火灾燃烧面积
function burning_area = calculate_burning_area(beta,t1,lambda,x,time)
    if time<t1
        burning_area = 0.5 * beta * time^2;  % 火灾蔓延产生的燃烧面积
    else
        t_ext = time-t1;
        burning_area = 0.5 * beta * t1^2 + beta * t1 * t_ext + 0.5 * (beta - lambda * x) * (t_ext^2);

    end
end

% 计算火灾燃烧程度
function burning_degree = calculate_burning_degree(beta,t1,lambda,x,time)
    if time<t1
        burning_degree = beta * time;  % 火灾蔓延程度
    else
        t_ext = time-t1;
        burning_degree = beta * t1 + (beta - lambda * x) * t_ext;
    end
end
