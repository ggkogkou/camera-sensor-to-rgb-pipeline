function [res_img] = resize_nearest_neighbor(img, M, N)

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

    % Perform nearest neighbor interpolation
    for i=1 : M
        for j=1 : N
            % Keep track of the pixels of the initial image
            i_init = i * height_scale;
            j_init = j * width_scale;

            % Interpolate the missing pixels by finding the nearest
            % neighbor
            i_nearest = min(M0, round(i_init));
            j_nearest = min(N0, round(j_init));
            
            % Assign the new resized rgb layers
			res_img(i, j, :) = img(i_nearest, j_nearest, :);
        end
    end

    % Print a message
    fprintf("Image was Resized Successfully...\n\n");

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%