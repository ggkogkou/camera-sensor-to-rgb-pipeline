function [Csrgb, Clinear, Cxyz, Ccam] = dng2rgb(rawim, XYZ2Cam, wbcoeffs, bayertype, method, M, N)
    
    % Convert RAW to RGB pipeline
    %
    % ---------------------------
    %
    % @see https://rcsumner.net/raw_guide/RAWguide.pdf
    % @see https://www.mathworks.com/help/images/
    % end-to-end-implementation-of-digital-camera-processing-pipeline.html#CameraPipelineExample-8
    %
    % ---------------------------------------
    %
    % @param rawim is the image in RAW Format
    % @param XYZ2Cam is the 2D Color Space of the Digital Camera
    % @param wbcoeffs  is the White Balancing Coefficients [R_scale, G_scale, B_scale]
    % @param bayertype can take values: 'rggb','gbrg','grbg','bggr'
    % @param method is the method of demosaicing of the Bayer CFA
    % @params M, N are the dimensions  
    %
    % ---------------------------------------
    
    % get default DNG image height and width
    M0 = size(rawim, 1);
    N0 = size(rawim, 2);

    % Perform the White Balancing of the RAW Image
    % -----------------------------------------------------------------
    % Removing unrealistic color casts from a rendered image, 
    % such that it appears closer to how human eyes would see the subject.  
    % -----------------------------------------------------------------
    % Create a WB mask for easier manipulation
    wbmask = wbcoeffs(2) * ones(M0, N0); % Initialize with Green scales

    % Replace Red and Blue boxes according to the corresponding Bayer
    % pattern
    if bayertype == "bggr"
        wbmask(2:2:end, 2:2:end) = wbcoeffs(1);
        wbmask(1:2:end, 1:2:end) = wbcoeffs(3);
    elseif bayertype == "gbrg"
        wbmask(2:2:end, 1:2:end) = wbcoeffs(1);
        wbmask(1:2:end, 2:2:end) = wbcoeffs(3);
    elseif bayertype == "grbg"
        wbmask(1:2:end, 2:2:end) = wbcoeffs(1);
        wbmask(1:2:end, 2:2:end) = wbcoeffs(3);
    elseif bayertype == "rggb"
        wbmask(1:2:end, 1:2:end) = wbcoeffs(1);
        wbmask(2:2:end, 2:2:end) = wbcoeffs(3);
    else
        fprintf("Invalid Bayer pattern. Aborting...\n");
        Csrgb = -1; Clinear = -1; Cxyz = -1; Ccam = -1;
        return;
    end
    
    % Mask Image Pixels
    rawim = rawim .* wbmask;

    % Demosaicing
    % -----------------------------------------------------------------
    % Convert the Bayer-encoded CFA image into a truecolor image by demosaicing. 
    % The truecolor image is in linear camera space.
    % -----------------------------------------------------------------
    if method == "nearest"
        demosaiced_image = demosaic_nearest_neighbor(rawim, bayertype);
    elseif method == "bilinear"
        demosaiced_image = demosaic_bilinear(rawim, bayertype);
    else
        fprintf("Invalid Interpolation Method Specified. Aborting...\n");
        Csrgb = -1; Clinear = -1; Cxyz = -1; Ccam = -1;
        return;
    end

    % Resizing
    % -----------------------------------------------------------------
    % Resize the demosaiced image to the given M, N inputs. 
    % -----------------------------------------------------------------
    if method == "nearest"
        demosaiced_image = resize_nearest_neighbor(demosaiced_image, M, N);
    elseif method == "bilinear"
        demosaiced_image = resize_bilinear(demosaiced_image, M, N);
    else
        fprintf("Invalid Interpolation Method Specified. Aborting...\n");
        Csrgb = -1; Clinear = -1; Cxyz = -1; Ccam = -1;
        return;
    end

    % Convert from linear Camera Color Space to linear RGB Color Space
    % -----------------------------------------------------------------
    % CIE standard T_{xyz->rgb}
    XYZ2rgb = [3.2404542, -1.5371385, -0.4985314;
               -0.9692660, 1.8760108, 0.0415560;
               0.0556434, -0.2040259, 1.0572252];

    % Calculate Camera to linear RGB transformation T_{Cam->RGB}
    rgb2cam  = XYZ2Cam / XYZ2rgb;
    rgb2cam  = rgb2cam ./ repmat(sum(rgb2cam, 2), 1, 3);
    cam2rgb  = inv(rgb2cam);

    linear_rgb(:,:,1) = (cam2rgb(1,1).*(demosaiced_image(:,:,1)) + cam2rgb(1,2).*(demosaiced_image(:,:,2)) + cam2rgb(1,3).*(demosaiced_image(:,:,3)));
    linear_rgb(:,:,2) = (cam2rgb(2,1).*(demosaiced_image(:,:,1)) + cam2rgb(2,2).*(demosaiced_image(:,:,2)) + cam2rgb(2,3).*(demosaiced_image(:,:,3)));
    linear_rgb(:,:,3) = (cam2rgb(3,1).*(demosaiced_image(:,:,1)) + cam2rgb(3,2).*(demosaiced_image(:,:,2)) + cam2rgb(3,3).*(demosaiced_image(:,:,3)));

    % Crop values outside [0, 1] interval
    linear_rgb = max(0, min(linear_rgb, 1));

    % Calculate XYZ CIE standard image
    rgb2XYZ = inv(XYZ2rgb);
    Cxyz(:,:,1) = (rgb2XYZ(1,1).*(linear_rgb(:,:,1)) + rgb2XYZ(1,2).*(linear_rgb(:,:,2)) + rgb2XYZ(1,3).*(linear_rgb(:,:,3)));
    Cxyz(:,:,2) = (rgb2XYZ(2,1).*(linear_rgb(:,:,1)) + rgb2XYZ(2,2).*(linear_rgb(:,:,2)) + rgb2XYZ(2,3).*(linear_rgb(:,:,3)));
    Cxyz(:,:,3) = (rgb2XYZ(3,1).*(linear_rgb(:,:,1)) + rgb2XYZ(3,2).*(linear_rgb(:,:,2)) + rgb2XYZ(3,3).*(linear_rgb(:,:,3)));

    % Convert image to sRGB, by applying a non-linear transformation
    % (gamma correction)
    % --------------------------------------------------------------
    % Colors shall appear brighter and colors are easier to distinguish
    grayim = rgb2gray(linear_rgb);
    grayscale = 4 * mean(grayim(:));
    grayscale = grayscale^(-1);
    bright_srgb = min(1, linear_rgb*grayscale);

    % Return sRGB Image
    Csrgb = double(bright_srgb).^(1/2.2);

    % Return linear RGB and Camera Images
    Ccam = demosaiced_image;
    Clinear = linear_rgb;

    imshow(Csrgb);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%