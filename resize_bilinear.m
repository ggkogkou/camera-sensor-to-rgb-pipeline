function [res_img] = resize_bilinear(img, M, N)

    % Resize the given demosaiced image
    % --------------------------
    % @param img is the image
    % @param M is the new height
    % @param N is the new width
    %
    % @return rgb is the MxNx3 RGB image

    % Initial Height and Width
    M0 = size(img, 1);
    N0 = size(img, 2);

    % Initialize the new resized image array
    res_img = zeros(M, N, 3);

    % Calculate scaling factor for both horizontal and vertical orientation
    % Also, check whether inputs M, N are valid (non-negatives)
    if M ~= 0 && N ~=0
        height_scale = M0 / M;
        width_scale = N0 / N;
    else 
        fprintf("Invalid new dimensions. Aborting...\n");
        res_img = -1;
        return;
    end

    % Perform bilinear interpolation
    for i=1 : M
        for j=1 : N
            % Kep track of the pixels of the initial image
            i_init = i * height_scale;
            j_init = j * width_scale;

            % Calculate the coordinates of neighbouring 4 pixels
            % Make sure not to go out of borders
            i_init_previous = floor(i_init); j_init_previous = floor(j_init);
            i_init_next = min(M0, ceil(i_init)); j_init_next = min(N0, ceil(j_init));

            % Interpolate the missing pixels after sampling
            % Store the new R,G,B LAYERS in res_img variable
            % ---------------------------------------------
            % Check if pixel of initial image matches pixel of resized
            if i_init_next == i_init_previous && j_init_next == j_init_previous
                res_img(i, j, :) = img(i_init_previous, j_init_previous, :);
            % Check if the pixels are integer multiplier of the ratio
            elseif i_init_next == i_init_previous
                weight_1 = img(i_init_previous, j_init_previous, :);
				weight_2 = img(i_init_previous, j_init_next, :);

                % Assign the new resized rgb layers
				res_img(i, j, :) = weight_1*(j_init_next-j_init) + weight_2*(j_init-j_init_previous);
            elseif j_init_next == j_init_previous
                weight_1 = img(i_init_previous, j_init_previous, :);
				weight_2 = img(i_init_next, j_init_previous, :);

                % Assign the new resized rgb layers
				res_img(i, j, :) = (weight_1*(i_init_next-i_init)) + (weight_2*(i_init-i_init_previous));

            % Interpolate the rest of the inside pixels
            else
                up_left = img(i_init_previous, j_init_previous, :);
				down_left = img(i_init_next, j_init_previous, :);
				up_right = img(i_init_previous, j_init_next, :);
				down_right = img(i_init_next, j_init_next, :);
  
                weight_1 = up_left * (i_init_next-i_init) + down_left*(i_init-i_init_previous);
				weight_2 = up_right * (i_init_next-i_init) + down_right*(i_init-i_init_previous);

                % Assign the new resized rgb layers
				res_img(i, j, :) = weight_1 * (j_init_next-j_init) + weight_2*(j_init-j_init_previous);
            end
            
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%