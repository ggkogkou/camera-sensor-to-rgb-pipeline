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
            i_original = i * height_scale;
            j_original = j * width_scale;

            % Calculate the coordinates of neighbouring 4 pixels
            % Make sure not to go out of borders
            i_original_previous = ceil(i_original); j_original_previous = ceil(j_original);
            i_original_next = min(M0, ceil(i_original)+1); j_original_next = min(N0, ceil(j_original)+1);

            % Interpolate the missing pixels after sampling
            % Store the new R,G,B LAYERS in res_img variable
            % ---------------------------------------------
            % Check if pixel of initial image matches pixel of resized
            if i_original_next == i_original_previous && j_original_next == j_original_previous
                res_img(i, j, :) = img(i_original_previous, j_original_previous, :);
            % Check if the pixels are integer multiplier of the ratio
            elseif i_original_next == i_original_previous
                weight_1 = img(i_original_previous, j_original_previous, :);
				weight_2 = img(i_original_previous, j_original_next, :);

                % Assign the new resized rgb layers
				res_img(i, j, :) = weight_1*(j_original_next-j_original) + weight_2*(j_original-j_original_previous);
            elseif j_original_next == j_original_previous
                weight_1 = img(i_original_previous, j_original_previous, :);
				weight_2 = img(i_original_next, j_original_previous, :);

                % Assign the new resized rgb layers
				res_img(i, j, :) = (weight_1*(i_original_next-i_original)) + (weight_2*(i_original-i_original_previous));

            % Interpolate the rest of the inside pixels
            else
                up_left = img(i_original_previous, j_original_previous, :);
				down_left = img(i_original_next, j_original_previous, :);
				up_right = img(i_original_previous, j_original_next, :);
				down_right = img(i_original_next, j_original_next, :);
  
                weight_1 = up_left * (i_original_next-i_original) + down_left*(i_original-i_original_previous);
				weight_2 = up_right * (i_original_next-i_original) + down_right*(i_original-i_original_previous);

                % Assign the new resized rgb layers
				res_img(i, j, :) = weight_1 * (j_original_next-j_original) + weight_2*(j_original-j_original_previous);
            end
            
        end
    end
    
    % Print a message
    fprintf("Image was Resized Successfully...\n\n");

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%