clear variables; close all; clc; % Take care to clear variables or else elements of L may not be overwritten correctly - maybe a Matlab optimiser problem.

I = imread('table__08_13_12_54_33.jpg');
paths = getPathsFromImage(I);
initRobot();

figure();
imshow(I);
hold on

for i = 1:length(paths.thick)
    curPoints = paths.thick{i};
    plot(curPoints(:,1),curPoints(:,2),'linewidth',5);
    ZaWarudo = convertPoints(curPoints(:,1),curPoints(:,2));
    pause(0.2);
end

for i = 1:length(paths.thin)
    curPoints = paths.thin{i};
    plot(curPoints(:,1),curPoints(:,2),'linewidth',3);
    pause(0.2);
end


function worldPoints = convertPoints(X,Y)
    pixels = 585;
    mm = 373.6;
    factor = mm/pixels;
    for i = 1:length(X)
        x(i) = (Y(i) - 10) * factor;
        y(i) = (X(i) - 799) * factor;
        z(i) = 197;
    end
    worldPoints = [x' y' z'];
    
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

