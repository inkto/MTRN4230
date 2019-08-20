clear variables; close all; clc; % Take care to clear variables or else elements of L may not be overwritten correctly - maybe a Matlab optimiser problem.

I = imread('table__08_13_12_54_33.jpg');
paths = getPathsFromImage(I);
figure();
hold on


for i = 1:length(paths.thick)
    curPoints = paths.thick{i};
    pcshow(curPoints,'VerticalAxisDir','up','MarkerSize',40);
end

for i = 1:length(paths.thin)
    curPoints = paths.thin{i};
    pcshow(curPoints, 'VerticalAxisDir','up','MarkerSize',40);
end