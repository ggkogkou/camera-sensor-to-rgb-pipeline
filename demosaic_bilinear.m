function [rgbim] = demosaic_bilinear(rawim, bayertype)

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
                if i == 1 && j == 1
                    green_layer(i, j) = 0.5*(green_layer(i+1, j)+green_layer(i, j+1));
                elseif i == M && j == N
                    green_layer(i, j) = 0.5*(green_layer(i-1, j)+green_layer(i, j-1));
                end
            % GRBG and GBRG patterns
            elseif bayertype == "grbg" || bayertype == "gbrg"
                if i == 1 && j == N
                    green_layer(i, j) = 0.5*(green_layer(i+1, j)+green_layer(i, j-1));
                elseif i == M && j == 1
                    green_layer(i, j) = 0.5*(green_layer(i-1, j)+green_layer(i, j+1));
                end
            end

            % Interpolate the GREEN missing border pixels
            % -------------------------------------------
            % RGGB, BGGR, GRBG and GBRG patterns
            if j == 1 && green_layer(i, j) == 0
                green_layer(i, j) = (green_layer(i+1, j)+green_layer(i-1, j)+green_layer(i, j+1))/3;
            elseif j == N && green_layer(i, j) == 0
                green_layer(i, j) = (green_layer(i+1, j)+green_layer(i-1, j)+green_layer(i, j-1))/3;
            elseif i == 1 && green_layer(i, j) == 0
                green_layer(i, j) = (green_layer(i+1, j)+green_layer(i, j-1)+green_layer(i, j+1))/3;
            elseif i == M && green_layer(i, j) == 0
                green_layer(i, j) = (green_layer(i-1, j)+green_layer(i, j-1)+green_layer(i, j+1))/3;
            end

            % Fill the rest of the inside missing GREEN pixels
            if green_layer(i, j) == 0
                green_layer(i, j) = (green_layer(i+1, j)+green_layer(i-1, j)+green_layer(i, j-1)+green_layer(i, j+1))/4;
            end

            % Interpolate both RED and BLUE missing pixels for all CFA petterns
            %
            % ----------------------
            % RGGB pattern (+ BGGR)
            %
            % The following if-statement impelents RGGB.
            %
            % For the BGGR pattern we just interchange red_layer and blue_layer
            if bayertype == "rggb" || bayertype == "bggr" 
                
                % Horizontal RED and BLUE Interpolation
                if mod(i, 2) == 1 && mod(j, 2) == 0
                    % Inside columns pixels
                    if i == 1 && j < N
                        red_layer(i, j) = (red_layer(i, j-1)+red_layer(i, j+1))/2;
                        blue_layer(i, j) = blue_layer(i+1, j);
                    elseif j < N
                        red_layer(i, j) = (red_layer(i, j-1)+red_layer(i, j+1))/2;
                        blue_layer(i, j) = (blue_layer(i+1, j)+blue_layer(i-1, j))/2;
                    % Last column pixels: copy the value of the nearest pixel
                    elseif i == 1 && j == N
                        red_layer(i, j) = red_layer(i, j-1);
                        blue_layer(i, j) = blue_layer(i+1, j);
                    elseif j == N
                        red_layer(i, j) = red_layer(i, j-1);
                        blue_layer(i, j) = (blue_layer(i+1, j)+blue_layer(i-1, j))/2;
                    end

                % Vertical RED and BLUE Interpolation
                elseif mod(i, 2) == 0 && mod(j, 2) == 1
                    % Inside rows pixels
                    if i < M && j == 1
                        red_layer(i, j) = (red_layer(i-1, j)+red_layer(i+1, j))/2;
                        blue_layer(i, j) = blue_layer(i, j+1);
                    elseif i < M
                        red_layer(i, j) = (red_layer(i-1, j)+red_layer(i+1, j))/2;
                        blue_layer(i, j) = (blue_layer(i, j+1)+blue_layer(i, j-1))/2;
                    % Last row pixels: copy the value of the nearest pixel
                    elseif i == M && j == 1
                        red_layer(i, j) = red_layer(i-1, j);
                        blue_layer(i, j) = blue_layer(i, j+1);
                    elseif i == M
                        red_layer(i, j) = red_layer(i-1, j);
                        blue_layer(i, j) = (blue_layer(i, j+1)+blue_layer(i, j-1))/2;
                    end

                % Diagonal Interpolation for RED
                elseif mod(i, 2) == 0 && mod(j, 2) == 0
                    % Inside columns pixels
                    if j < N && i < M
                        red_layer(i, j) = (red_layer(i-1, j-1)+...
                            red_layer(i+1, j+1)+red_layer(i-1, j+1)+...
                            red_layer(i+1, j-1))/4;
                    % Last column pixels
                    elseif j == N && i < M
                        red_layer(i, j) = (red_layer(i+1, j-1)+red_layer(i-1, j-1))/2;
                    % Last row pixels
                    elseif j < N && i == M
                        red_layer(i, j) = (red_layer(i-1, j-1)+red_layer(i-1, j+1))/2;
                    % Last pixel
                    elseif j == N && i == M
                        red_layer(i, j) = red_layer(i-1, j-1);
                    end

                % Diagonal Interpolation for BLUE
                elseif mod(i, 2) == 1 && mod(j, 2) == 1
                    % Inside columns pixels
                    if i == 1 && j == 1
                        blue_layer(i, j) = blue_layer(i+1, j+1);
                    elseif j == 1
                        blue_layer(i, j) = (blue_layer(i+1, j+1)+blue_layer(i-1, j+1))/2;
                    elseif i == 1
                        blue_layer(i, j) = (blue_layer(i+1, j-1)+blue_layer(i+1, j+1))/2;
                    elseif j < N && i < M
                        blue_layer(i, j) = (blue_layer(i-1, j-1)+...
                            blue_layer(i+1, j+1)+blue_layer(i-1, j+1)+...
                            blue_layer(i+1, j-1))/4;
                    end
                end
            end

            % Interpolate both RED and BLUE missing pixels for all CFA petterns
            %
            % ----------------------
            % GRBG pattern (+ GBRG)
            %
            % The following if-statement impelents GRBG.
            %
            % For the GBRG pattern we just interchange red_layer and blue_layer
            if bayertype == "grbg" || bayertype == "gbrg" 
                
                % Horizontal RED and BLUE Interpolation
                if mod(i, 2) == 1 && mod(j, 2) == 1
                    % Inside columns pixels
                    if i == 1 && j == 1
                        red_layer(i, j) = red_layer(i, j+1);
                        blue_layer(i, j) = blue_layer(i+1, j);
                    elseif i == 1
                        red_layer(i, j) = (red_layer(i, j-1)+red_layer(i, j+1))/2;
                        blue_layer(i, j) = blue_layer(i+1, j);
                    % Last column pixels: copy the value of the nearest pixel
                    elseif j == 1
                        red_layer(i, j) = red_layer(i, j+1);
                        blue_layer(i, j) = (blue_layer(i+1, j)+blue_layer(i-1, j))/2;
                    elseif i < M && j < N
                        red_layer(i, j) = (red_layer(i, j-1)+red_layer(i, j+1))/2;
                        blue_layer(i, j) = (blue_layer(i+1, j)+blue_layer(i-1, j))/2;
                    end

                % Vertical RED and BLUE Interpolation
                elseif mod(i, 2) == 0 && mod(j, 2) == 0
                    % Inside rows pixels
                    if i < M && j == N
                        red_layer(i, j) = (red_layer(i-1, j)+red_layer(i+1, j))/2;
                        blue_layer(i, j) = blue_layer(i, j-1);
                    elseif i < M
                        red_layer(i, j) = (red_layer(i-1, j)+red_layer(i+1, j))/2;
                        blue_layer(i, j) = (blue_layer(i, j+1)+blue_layer(i, j-1))/2;
                    % Last row pixels: copy the value of the nearest pixel
                    elseif i == M && j == N
                        red_layer(i, j) = red_layer(i-1, j);
                        blue_layer(i, j) = blue_layer(i, j-1);
                    elseif i == M
                        red_layer(i, j) = red_layer(i-1, j);
                        blue_layer(i, j) = (blue_layer(i, j+1)+blue_layer(i, j-1))/2;
                    end

                % Diagonal Interpolation for RED
                elseif mod(i, 2) == 0 && mod(j, 2) == 1
                    % Inside columns pixels
                    if i < M && j == 1
                        red_layer(i, j) = (red_layer(i-1, j+1)+red_layer(i+1, j+1))/2;
                    elseif i == M && j == 1
                        red_layer(i, j) = red_layer(i-1, j+1);
                    elseif i == M
                        red_layer(i, j) = (red_layer(i-1, j-1)+red_layer(i-1, j+1))/2;
                    elseif i < M && j < N
                        red_layer(i, j) = (red_layer(i-1, j-1)+...
                            red_layer(i+1, j+1)+red_layer(i-1, j+1)+...
                            red_layer(i+1, j-1))/4;
                    end

                % Diagonal Interpolation for BLUE
                elseif mod(i, 2) == 1 && mod(j, 2) == 0
                    % Inside columns pixels
                    if i == 1 && j < N
                        blue_layer(i, j) = (blue_layer(i+1, j+1)+blue_layer(i+1, j-1))/2;
                    elseif i == 1
                        blue_layer(i, j) = blue_layer(i+1, j-1);
                    elseif j == N
                        blue_layer(i, j) = (blue_layer(i-1, j-1)+blue_layer(i+1, j-1))/2;
                    elseif i < M && j < N
                        blue_layer(i, j) = (blue_layer(i-1, j-1)+...
                            blue_layer(i+1, j+1)+blue_layer(i-1, j+1)+...
                            blue_layer(i+1, j-1))/4;                      
                    end
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

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%