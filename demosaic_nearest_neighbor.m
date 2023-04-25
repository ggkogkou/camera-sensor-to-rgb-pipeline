function [rgbim] = demosaic_nearest_neighbor(rawim, bayertype)

    % Perform demosaicing to the MxN raw image
    % Bayer CFA model is used
    %
    % @see https://wiki.apertus.org/index.php/OpenCine.Nearest_Neighbor_and_Bilinear_Interpolation
    %
    % @param rawim is the RAW formatted image
    % @param bayertype is the Bayer pattern of CFA
    %
    % @return rgb is the MxNx3 RGB image

    M = size(rawim, 1);
    N = size(rawim, 2);

    % Create masks to divide the RAW image into three channels R,G,B
    % --------------------------------------------------------------
    % RGGB pattern mask
    if bayertype == "rggb"
        red_mask = repmat([1 0; 0 0], M/2, N/2);
        green_mask = repmat([0 1; 1 0], M/2, N/2);
        blue_mask = repmat([0 0; 0 1], M/2, N/2);
    % BGGR pattern mask
    elseif bayertype == "bggr"
        red_mask = repmat([0 0; 0 1], M/2, N/2);
        green_mask = repmat([0 1; 1 0], M/2, N/2);
        blue_mask = repmat([1 0; 0 0], M/2, N/2);
    % GBRG pattern mask
    elseif bayertype == "gbrg"
        red_mask = repmat([0 0; 1 0], M/2, N/2);
        green_mask = repmat([1 0; 0 1], M/2, N/2);
        blue_mask = repmat([0 1; 0 0], M/2, N/2);
    % GRBG pattern mask
    elseif bayertype == "grbg"
        red_mask = repmat([0 1; 0 0], M/2, N/2);
        green_mask = repmat([1 0; 0 1], M/2, N/2);
        blue_mask = repmat([0 0; 1 0], M/2, N/2);
    % Invalid pattern 
    else
        fprintf("Invalid CFA pattern. Aborting...\n");
        rgbim = -1;
        return;
    end
    
    % Mask the RAW image and produce three separate R, G, B layers.
    % After that, apply interpolation to assign values to the missing
    % pixels.
    red_layer = rawim .* red_mask;
    green_layer = rawim .* green_mask;
    blue_layer = rawim .* blue_mask;

    % Perform Demosaicing by Interpolating the Missing R,G,B Pixels
    for i=1 : M
        for j=1 : N
            % Interpolate the GREEN missing corner pixels for all CFA petterns
            % ----------------------
            % RGGB and BGGR patterns
            if bayertype == "rggb" || bayertype == "bggr"
                if mod(i, 2) == 1 && mod(j, 2) == 1
                    green_layer(i, j) = green_layer(i, j+1);
                elseif mod(i, 2) == 0 && mod(j, 2) == 0
                    green_layer(i, j) = green_layer(i, j-1);
                end
            % GRBG and GBRG patterns
            elseif bayertype == "grbg" || bayertype == "gbrg"
                if mod(i, 2) == 1 && mod(j, 2) == 0
                    green_layer(i, j) = green_layer(i, j-1);
                elseif mod(i, 2) == 0 && mod(j, 2) == 1
                    green_layer(i, j) = green_layer(i, j+1);
                end
            end

            % Interpolate the RED and BLUE missing corner pixels for all CFA petterns
            if bayertype == "rggb" || bayertype == "bggr"
                if mod(i, 2) == 1 && mod(j, 2) == 0
                    red_layer(i, j) = red_layer(i, j-1);
                    blue_layer(i, j) = blue_layer(i+1, j);
                elseif mod(i, 2) == 0 && mod(j, 2) == 1
                    red_layer(i, j) = red_layer(i-1, j);
                    blue_layer(i, j) = blue_layer(i, j+1);
                elseif mod(i, 2) == 0 && mod(j, 2) == 0
                    red_layer(i, j) = red_layer(i-1, j-1);
                    blue_layer(i-1, j-1) = blue_layer(i, j);
                end
            elseif bayertype == "bggr" || bayertype == "gbrg"
                if mod(i, 2) == 1 && mod(j, 2) == 1
                    red_layer(i, j) = red_layer(i, j+1);
                    blue_layer(i, j) = blue_layer(i+1, j);
                elseif mod(i, 2) == 0 && mod(j, 2) == 0
                    red_layer(i, j) = red_layer(i-1, j);
                    blue_layer(i, j) = blue_layer(i, j-1);
                elseif mod(i, 2) == 0 && mod(j, 2) == 1
                    red_layer(i, j) = red_layer(i-1, j+1);
                    blue_layer(i-1, j+1) = blue_layer(i, j);
                end
            end
        end
    end

    % Return Demosaiced RGB Image
    % ---------------------------
    % RGGB and GRBG CFA
    if bayertype == "rggb" || bayertype == "grbg"
        rgbim(:,:,1) = red_layer; 
        rgbim(:,:,2) = green_layer;
        rgbim(:,:,3) = blue_layer;
    % BGGR and GBRG CFA
    elseif bayertype == "bggr" || bayertype == "gbrg"
        rgbim(:,:,1) = blue_layer; 
        rgbim(:,:,2) = green_layer;
        rgbim(:,:,3) = red_layer;
    end

    % Print a message
    fprintf("Bayer Encoded Image was Demosaiced Successfully\n\n");

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%