imgs = imread('./data/demo.png');
% 旋转
imgs = imrotate(imgs, 90);

% 提取各个颜色通道
imgs_red = imgs(:, :, 1);     % 红色通道
imgs_green = imgs(:, :, 2);    % 蓝色通道
imgs_blue = imgs(:, :, 3);    % 蓝色通道
bin_red = imbinarize(imgs_red, 0.9);
bin_green = imbinarize(imgs_green, 0.97);

colors = ['b', 'r'];
c = 1;
pos = zeros(2, 2);
% 1. 显示原图
figure;
imshow(imgs);
title('检测到的矩形区域');
hold on;
for bin =  {bin_red, bin_green}
    bin_img = bin{1};
    % 找矩形框
    stats = regionprops(bin_img, 'BoundingBox', 'Centroid');
    % 去除波动

    for i = numel(stats):-1:1
        radio = min([stats(i).BoundingBox(3), stats(i).BoundingBox(4)]) / max([stats(i).BoundingBox(3), stats(i).BoundingBox(4)]);
        if stats(i).BoundingBox(3) < 40 || radio < 0.9
            stats(i) = []; 
        end
    
    end

 
    for i = 1:numel(stats)
        bbox = stats(i).BoundingBox;
        centroid = stats(i).Centroid;  % [x, y]
        % 画框
        rectangle('Position', bbox, ...
                'EdgeColor', colors(c), ...       % 边框颜色设为红色
                'LineWidth', 2);            % 边框线宽设为2
    end
       
    pos(c, 1) = centroid(1);
    pos(c, 2) = centroid(2);
    c = c + 1;
   
end
plot(pos(:, 1), pos(:, 2),  'LineWidth', 2, 'Color', 'b');
% 中心点:绿色
% 目标点:红色
Vx = pos(2, 1);
Vy = pos(2, 2);

% 角度
target_angle = atan2d(pos(1,2) - Vy, pos(1,1) - Vx);

% 
if target_angle < 0
    theta = linspace(target_angle, 0, 50);
else
    theta = linspace(0, target_angle, 50);
end

% 扇形半径长度0.3
R = min([60, norm(pos(1,:) - pos(2,:)) * 0.3]); 

% 将极坐标转换为图像坐标
arc_x = Vx + R * cosd(theta);
arc_y = Vy + R * sind(theta);

% 闭合扇形
fan_x = [Vx, arc_x, Vx];
fan_y = [Vy, arc_y, Vy];

% 绘制并填充扇形
fill(fan_x, fan_y, 'b', 'FaceAlpha', 0, 'EdgeColor', 'b', 'LineWidth', 1.5);

% 8. 标注
text(Vx + R + 10, Vy, sprintf('%.1f°', abs(target_angle)), ...
     'Color', 'b', 'FontSize', 14, 'FontWeight', 'bold');
hold off;





