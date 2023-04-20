function [rawim, XYZ2Cam, wbcoeffs] = readdng(filename)

    % Turn off LibTiff warnings
    warning('off','all');
    %warning;

    % Read the RAW image
    t = Tiff(filename, 'r');
    offsets = getTag(t, 'SubIFD');
    setSubDirectory(t , offsets(1));
    rawim = read(t);
    close(t);

    % Read the metadata of the image
    meta_info = imfinfo(filename);

    % Crop to only valid pixels
    x_origin = meta_info.SubIFDs{1}.ActiveArea(2) + 1;
    width = meta_info.SubIFDs{1}.DefaultCropSize(1);
    y_origin = meta_info.SubIFDs{1}.ActiveArea(1) + 1;
    height = meta_info.SubIFDs{1}.DefaultCropSize(2);

    rawim = double(rawim(y_origin:y_origin+height-1, x_origin:x_origin+width-1));

    % Check if rawim is a non-linear image and apply a transformation
    if isfield(meta_info.SubIFDs{1},  'LinearizationTable') == true
        ltab=meta_info.SubIFDs{1}.LinearizationTable;
        rawim = ltab(rawim+1);
    end

    % Get the black and white level
    blacklevel = meta_info.SubIFDs{1}.BlackLevel(1);
    whitelevel = meta_info.SubIFDs{1}.WhiteLevel;

    % If blacklevel and whitelevel values are stored non-linearly,
    % undo that mapping
    rawim = (rawim-blacklevel)/(whitelevel-blacklevel);
    
    % Blacklevel -> 0
    % Whitelevel -> 0
    rawim = rawim - blacklevel;

    % - Due to sensor noise, and despite the blacklevel and whitelevel
    % standards, rawim might have values outside [0,1] interval. 
    % - These values shall be cut off.
    rawim = max(0, min(rawim, 1));

    % Get the White Balance Coefficients [R_scale, G_scale, B_scale]
    wbcoeffs = meta_info.AsShotNeutral .^ (-1);
    wbcoeffs = wbcoeffs/wbcoeffs(2);

    % Get digital camera's color space matrix
    XYZ2Cam = meta_info.ColorMatrix2;
    XYZ2Cam = transpose(reshape(XYZ2Cam ,3 ,3));

end

%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%