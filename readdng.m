function [rawim, XYZ2Cam, wbcoeffs] = readdng(filename)
    % Read the RAW image
    obj = Tiff(filename, 'r');
    offsets = getTag(obj, 'SubIFD');
    setSubDirectory(obj , offsets(1));
    rawim = read(obj);
    close(obj);

    % Read the metadata of the image
    meta_info = imfinfo(filename);
    y_origin = meta_info.SubIFDs{1}.ActiveArea(1) + 1;
    x_origin = meta_info.SubIFDs{1}.ActiveArea(2) + 1;

    % Get the width and height of the image
    width = meta_info.SubIFDs{1}.DefaultCropSize(1);
    height = meta_info.SubIFDs{1}.DefaultCropSize(2);

    % Get the black and white level
    blacklevel = meta_info.SubIFDs{1}.BlackLevel(1);
    whitelevel = meta_info . SubIFDs {1}. WhiteLevel ;

    



end

