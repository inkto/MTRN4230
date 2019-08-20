clear variables; close all; clc; % Take care to clear variables or else elements of L may not be overwritten correctly - maybe a Matlab optimiser problem.

I = imread('table__08_13_12_54_33.jpg');
paths = getPathsFromImage(I);
initRobot();

% dur = ones(1,3)*1.75;
% traj = mstraj(CartP(2:end,:), [], dur, CartP(1,:), 0.01, 0);
% 
% % Plot Cartesian coordinates
% f2 = figure(6);
% %s_cart = irb_120.fkine(traj);
% %two_link_locus = transl(s_cart);  % Just translational components
% plot(traj(:, 1), traj(:, 2)); axis equal; xlabel('X [m]'); ylabel('Y [m]'); grid on; title('Locus of Cartesian path');

figure();
imshow(I);
hold on

for i = 1:length(paths.thick)
    curPoints = paths.thick{i};
    pcshow(curPoints,'VerticalAxisDir','up','MarkerSize',40);
end

for i = 1:length(paths.thin)
    curPoints = paths.thin{i};
    pcshow(curPoints, 'VerticalAxisDir','up','MarkerSize',40);
end

    
function initRobot
    startup_rvc; dbstop if error;
    % Initialise all link kinematics

    L(1) = Link([0 0.290 0 pi/2]);  
    L(1).offset = pi;   % Offsets are needed so the home position matches what is defined on the robot
    L(2) = Link([0 0 0.270 0]); 
    L(2).offset = pi/2;
    L(3) = Link([0 0 0.07 -pi/2]); 
    L(3).offset = 0;
    L(4) = Link([0 0.302 0 pi/2]); 
    L(4).offset = 0;
    L(5) = Link([pi 0 0 pi/2]); 
    L(5).offset = pi;
    L(6) = Link([0 0.137 0 0]); 
    L(6).offset = 0;
    
    figure();
    irb_120 = SerialLink(L, 'name', 'irb120');

    qi = [0, 0, 0, 0, 0, 0];

    T = irb_120.fkine(qi);
    irb_120.plot(qi); % Try using clear all at the top if the 0 pose does not respect the joint offsets.

    hold on;
    %Create Table
    x = [0.129 ; 0.65 ; 0.65 ; 0.129 ];
    y = [-0.75 ; -0.75 ; 0.75 ; 0.75 ];
    z = [0.147 ; 0.147 ; 0.147 ; 0.147 ];
    fill3(x,y,z, [0.4 0.4 0.4]);

    T_r = rotx(0);
    T_t = r2t(T_r);
    T_t(1:3, 4) = [0.129 -0.75 0.147]';
    trplot(T_t, 'frame', 'T', 'rgb', 'length', 0.3, 'arrow');

end

