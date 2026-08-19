clc;
clear;
imgs = imread('./data/demo_apriltag.png');

imgs = imrotate(imgs, 90);

tagFamily = 'tag25h9';  

% 转化为灰度图
if size(imgs, 3) == 3
    imgGray = im2gray(imgs);
else
    imgGray = imgs;
end

[ids, locs] = readAprilTag(imgGray, tagFamily);

if isempty(ids)
    error('没有检测到任何AprilTag，请检查tagFamily、图像清晰度和光照');
end

% 计算每个tag中心点
numTags = numel(ids);
centers = zeros(numTags, 2);
for i = 1:numTags
    corners = squeeze(locs(:, :, i));  
    centers(i, :) = mean(corners, 1);
end

% 按ID提取：
% ID = 0 对应原来的绿色块，作为中心点
% ID = 1 对应原来的红色块，作为目标点
id0_idx = find(ids == 0);
id1_idx = find(ids == 1);

if isempty(id0_idx) || isempty(id1_idx)
    error('未同时检测到ID=0和ID=1的AprilTag');
end

center_green = centers(id0_idx(1), :);   % ID 0
center_red   = centers(id1_idx(1), :);   % ID 1

% ------------------ 显示 ------------------
figure;
imshow(imgs);
title('检测到的AprilTag区域');
hold on;

% 画出所有检测到的tag边框和ID
for i = 1:numTags
    corners = squeeze(locs(:, :, i));
    cornersClosed = corners([1 2 3 4 1], :);
    
    if ids(i) == 0
        tagColor = 'b';
    elseif ids(i) == 1
        tagColor = 'b';
    else
        tagColor = 'y';
    end
    
    plot(cornersClosed(:, 1), cornersClosed(:, 2), ...
         'Color', tagColor, 'LineWidth', 2);
    text(centers(i, 1) + 5, centers(i, 2) + 5, ...
         sprintf('id=%d', ids(i)), ...
         'Color', 'r', 'FontSize', 12, 'FontWeight', 'bold');
end

% 连接ID=0和ID=1
plot([center_green(1) center_red(1)], ...
     [center_green(2) center_red(2)], ...
     'LineWidth', 2, 'Color', 'b');

% ------------------ 角度计算 ------------------
Vx = center_green(1);
Vy = center_green(2);

target_angle = atan2d(center_red(2) - Vy, center_red(1) - Vx);

% 画扇形
if target_angle < 0
    theta = linspace(target_angle, 0, 50);
else
    theta = linspace(0, target_angle, 50);
end

R = min([200, norm(center_red - center_green) * 0.8]);

arc_x = Vx + R * cosd(theta);
arc_y = Vy + R * sind(theta);

fan_x = [Vx, arc_x, Vx];
fan_y = [Vy, arc_y, Vy];

fill(fan_x, fan_y, 'r', 'FaceAlpha', 0, 'EdgeColor', 'b', 'LineWidth', 1.5);

text(Vx + R + 10, Vy, sprintf('%.1f°', abs(target_angle)), ...
     'Color', 'r', 'FontSize', 20, 'FontWeight', 'bold');

hold off;