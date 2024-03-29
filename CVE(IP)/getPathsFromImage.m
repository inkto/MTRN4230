function points = getPathsFromImage(I)
    %image goes into here, image local pixel poitions come out
    %they will eed to be converted to world frame for path planning ect.
    colI = I;
    %points is a struct that returns to cell arrays ( thick and thin letter strokes (merged))
    roi = rgb2gray(imread("roi.png"));
    roi = roi < 50;

    grayI = rgb2gray(colI);
    grayI = (grayI < 150) & roi;
    %grayI = imerode(grayI,strel('disk',2));
    %Morphilogical opps
    grayI = imerode(grayI,strel('arbitrary',eye(4)));
    grayI = imclose(grayI,strel('square',3));
    %
    grayI = bwareafilt(grayI,[100, 10000]);
    %white siloute of tiles and text
    text = removeTiles(grayI);
    %remove white tiles (gets rid of squares)

    %bold letters thinner, and non bold letters dissapear
    thick = imerode(text,strel('disk',3,0));

    %morphological ops, clear light 
    thick = bwareafilt(thick,[100, 10000]);
    %converts letters to 1 pixel thick lines
    thick = bwmorph(thick, 'thin', Inf);

    %paint black over thick letters leaving only thin letters
    thin = imdilate(thick,strel('disk',16,0));
    thin = text & ~thin;
    thin = bwmorph(thin, 'thin', Inf);
    % now we have to images of both thin and thick letters skeletal
    % outlines

    thickPointsUnordered = getPoints(thick); % gets white pixel co-ords of BOLD, x and y unordered
    thinPointsUnordered = getPoints(thin);% gets white pixel co-ords of thin, x and y unordered
    %nearest neighbour ordering of each array
    points.thick = points2contour(thickPointsUnordered(:,1),thickPointsUnordered(:,2));
    points.thin = points2contour(thinPointsUnordered(:,1),thinPointsUnordered(:,2));

    load('cameraParams.mat');
    load('rotation.mat');
    load('translation.mat');
    
    table_height = 147;
    
    for i = 1:length(points.thick)
        points.thick{i} = [pointsToWorld(cameraParams,R,t,points.thick{i}),table_height.*ones(length(points.thick{i}),1)];
    end
    
    for i = 1:length(points.thin)
        points.thin{i} = [pointsToWorld(cameraParams,R,t,points.thin{i}),table_height.*ones(length(points.thin{i}),1)];
    end
    
    
    
end

function centroids = find_squares(props)
    centroids = [];
    for n = 1:length(props) % for all white regions (squares and leters) detected
           if props(n).Eccentricity < 0.6 % helps find tile not letter
               centroids = [centroids; props(n).Centroid]; %add centriods of each white square region
           end
    end
    centroids = round(centroids); %must be pixel coordinate for indexing
end

function coords = getPoints(I)
    %list co-ordinates of each outline into tracable pixel co=ordinates
    %
    [n,m] = size(I);
    j = max(n,m);
    %get first half of pixel cordinates
    noise = toeplitz(mod(1:j,2)); %creates the checkerborad image 
    noise = noise(1:n,1:m); 
    x = I & noise;
    %use region probs on every pixel to get all the co-ords
    r = regionprops(x,'Centroid');
    coords = cat(1,r.Centroid);
    
    %get second half of pixel co-ordinates
    noise = ~noise;
    x = I & noise;
    r = regionprops(x,'Centroid');
    coords = [coords;cat(1,r.Centroid)];
end

function cCell = points2contour(X,Y)
    %first pixel is matched with nearest neighbours and then all pixels are
    %store the coordinates of each stoke in a cell array.
    coord = cat(2,X,Y); 
    coord = unique(coord,'rows');

    x = coord(:,1); 
    y = coord(:,2);

    N=length(x); 
    x_=x(1,1); y_=y(1,1); 
    C = []; 
    cCell = {};
    coord_=coord;

    for i=1:N-1 
        id=any(coord_(:,1:2)~=[x_,y_],2); 
        coord_=coord_(id,1:2); 
        IDX = knnsearch(coord_,cat(2,x_,y_)); 
        temp_=coord_(IDX,:); 
        d = 20;
        % merge stroke cells if they fit pixel distance criteria
        if (norm(temp_-[x_,y_]) > d)
            if (length(cCell) > 0)
                flag = 0;
                for j = 1:length(cCell)
                    if norm(C(1,:)-cCell{j}(1,:)) <= d
                        cCell{j} = [flip(cCell{j}); C];
                        flag = 1;
                        break;
                    elseif norm(C(end,:)-cCell{j}(1,:)) <= d
                        cCell{j} = [C; cCell{j}];
                        flag = 1;
                        break;
                    elseif norm(C(1,:)-cCell{j}(end,:)) <= d
                        cCell{j} = [cCell{j}; C];
                        flag = 1;
                        break;
                    elseif norm(C(end,:)-cCell{j}(end,:)) <= d
                        cCell{j} = [flip(cCell{j}); C];
                        flag = 1;
                        break;
                    end
                end
                if flag == 0
                    cCell{end+1} = C;
                end
            else
                cCell{end+1} = C;
            end
            C = [];
        end
            
        x_= temp_(1,1);
        y_= temp_(1,2);
        C = [C;coord_(IDX,:)]; 
    end

    cCell{end+1} = C;
end
function I = removeTiles(I)
    %   find and remove white squares
    props = regionprops(I,'Centroid','Eccentricity');
    L = bwlabel(I,4);
    blockCentres = find_squares(props);
    for i = 1:length(blockCentres(:,1))
        I = I & (L(blockCentres(i,2),blockCentres(i,1)) ~= L);
    end
end
