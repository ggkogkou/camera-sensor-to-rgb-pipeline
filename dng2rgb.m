function [Csrgb, Clinear, Cxyz, Ccam] = dng2rgb(rawim, XYZ2Cam, wbcoeffs, bayertype, method, M, N)
    
    % Convert RAW to RGB
    % @see https://rcsumner.net/raw_guide/RAWguide.pdf
    % @see https://www.mathworks.com/help/images/
    % end-to-end-implementation-of-digital-camera-processing-pipeline.html#CameraPipelineExample-8
    clc; clear;

    % @param rawim is the image in RAW Format
    % @param XYZ2Cam is the 2D Color Space of the Digital Camera
    % @param wbcoeffs  is the White Balancing Coefficients [R_scale, G_scale, B_scale]
    % @param bayertype can take values: 'rggb','gbrg','grbg','bggr'
    % @param method is the method of demosaicing of the Bayer CFA
    % @params M, N are the dimensions

    % RAW image filename
    filename = 'RawImage.tiff';

    % Read the RAW formatted image (DNG type)
    [rawim, XYZ2Cam, wbcoeffs] = readdng(filename);
    
    M = size(rawim, 1);
    N = size(rawim, 2);
    bayertype = "rggb";

    % Perform the White Balancing of the RAW Image
    % -----------------------------------------------------------------
    % Removing unrealistic color casts from a rendered image, 
    % such that it appears closer to how human eyes would see the subject.  
    % -----------------------------------------------------------------
    % Create a WB mask for easier manipulation
    wbmask = wbcoeffs(2) * ones(M,N); % Initialize with Green scales

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
    
    % Perform white balancing
    rawim = rawim .* wbmask;

    % Demosaicing
    % -----------------------------------------------------------------
    % Convert the Bayer-encoded CFA image into a truecolor image by demosaicing. 
    % The truecolor image is in linear camera space.
    %rawim = im2uint16(rawim);
    %rawim = demosaic(rawim, 'rggb');
    rawim = demosaic_bilinear(rawim, bayertype);

    % Convert from Camera Color Space to RGB Color Space
    % -----------------------------------------------------------------
    %cam2srgbMat = inv(XYZ2Cam);
    %imTransform = imapplymatrix(cam2srgbMat,rawim,"uint16");
    


    imshow(rawim)

end

%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%