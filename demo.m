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

% Count the figures
fig_num = 1;

% Path to save the figures
current_project = pwd;

% Select ehat task to be executed
task_num = 1;

% TASK 1: ORIGINAL IMAGE
if task_num == 1
    M = size(rawim, 1);
    N = size(rawim, 2);
% TASK 2: SHRINK IMAGE
elseif task_num == 2
    M = 400;
    N = 400;
% TASK 3: UPSCALE IMAGE
elseif task_num == 3
    M = size(rawim, 1) + 500;
    N = size(rawim, 2) + 200;
% TASK 4: BOTH
elseif task_num == 4
    M = size(rawim, 1) + 400; % increase height
    N = size(rawim, 2) - 1000; % decrease width
end

[Csrgb, Clinear, Cxyz, Ccam] = dng2rgb(rawim, XYZ2Cam, wbcoeffs, bayertype, method, M, N);

% Plot Results
figure(fig_num)
fig_num = fig_num + 1;
imshow(Ccam)
title("Linear Camera Image")

figure(fig_num)
fig_num = fig_num + 1;
imshow(Cxyz)
title("CIE XYZ Image")

figure(fig_num)
fig_num = fig_num + 1;
imshow(Clinear)
title("Linear RGB Image")

figure(fig_num)
fig_num = fig_num + 1;
imshow(Csrgb)
title("sRGB Image")

figure(fig_num)

subplot(2,2,1)
imhist(Ccam)
title('Subplot 1: Linear Camera Image Histogram')

subplot(2,2,2)
imhist(Cxyz)
title('Subplot 2: CIE XYZ Image Histogram')

subplot(2,2,3)
imhist(Clinear)
title('Subplot 3: Linear RGB Image Histogram')

subplot(2,2,4)
imhist(Csrgb)
title('Subplot 4: sRGB Histogram')

% Save all plots
current_path = pwd;
for i=1 : fig_num
    file_dest = strcat(current_path, '/plots/task_', task_num, '_gig_num_', fig_num, '.png');
    saveas(figure(figure_count), file_dest);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% END OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%