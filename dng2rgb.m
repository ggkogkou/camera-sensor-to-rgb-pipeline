function [Csrgb, Clinear, Cxyz, Ccam] = dng2rgb(rawim, XYZ2Cam, wbcoeffs, bayertype, method)
    

    %cfa = rawread("RawImage.tiff", "VisibleImageOnly", true);
    %[rawim, XYZ2Cam, wbcoeffs] = readdng('RawImage.tiff')

    t = Tiff('RawImage.tiff','r');
    imageData = read(t);
    imshow(imageData);
    title('Peppers Image (RGB)')



end

