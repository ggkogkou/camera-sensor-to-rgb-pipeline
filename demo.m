% Implement Digital Camera Processing Pipeline
% --------------------------------------------
% Read RAW data from sensor and transform the image to RGB format
% ---------------------------------------------------------------
% A demo script to display the usage and results of the application
% -----------------------------------------------------------------
% Clear workspace and console
clc; clear;

% RAW image filename
filename = 'RawImage.tiff';

% Read the RAW formatted image (DNG type)
[rawim, XYZ2Cam, wbcoeffs] = readdng(filename);

% Specify Interpolation Method to be Performed -- Comment/Uncomment
method = "nearest";
%method = "bilinear";

% Specify Bayer CFA Type -- Comment/Uncomment
bayertype = "rggb";
%bayertype = "bggr";
%bayertype = "grbg";
%bayertype = "gbrg";

% Convert DNG to sRGB
M = size(rawim, 1);
N = size(rawim, 2);
M = 500; N = 200;
[Csrgb, Clinear, Cxyz, Ccam] = dng2rgb(rawim, XYZ2Cam, wbcoeffs, bayertype, method, M, N);

% Plot Results
figure(1)

subplot(2,2,1)
imshow(Ccam)
title('Subplot 1: Linear Camera Image')

subplot(2,2,2)
imshow(Cxyz)
title('Subplot 2: CIE XYZ Image')

subplot(2,2,3)
imshow(Clinear)
title('Subplot 3: Linear RGB Image')

subplot(2,2,4)
imshow(Csrgb)
title('Subplot 4: sRGB')








%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%