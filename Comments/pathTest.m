I = imread("table__08_13_12_54_33.jpg");
paths = getPathsFromImage(I);
figure
imshow(I);
hold on

for i = 1:length(paths.thick)
    curPoints = paths.thick{i};
    plot(curPoints(:,1),curPoints(:,2),'linewidth',5);
end

for i = 1:length(paths.thin)
    curPoints = paths.thin{i};
    plot(curPoints(:,1),curPoints(:,2),'linewidth',3);
end