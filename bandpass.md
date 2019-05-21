# Bandpass

This top script is a wrapper to run bandpass.m  As the script mentions, it utilizes the Nifti Analyze toolbox for reading in the image, and calls bandpass.m (further down the page), which calls another script to do the actual filtering.  Bandpass.m utilizes getFiltCoeffs.m, which utilizes MATLABs signal processing toolbox.  You will need all of these things for it to work, and if you choose to compile them into an executable, make sure that you don't forget anything!

```matlab
function bandpass_fsl(nifti,outfile,TR,fl,fh)

% Usage:

% This is a wrapper for usage with bandpass.m!  
% It utilizes the Nifti Analyze Toolbox --> http://www.mathworks.com/matlabcentral/fileexchange/8797
% however you can read in the nifti file however you like!
% bandpass.m also requires the signal processing toolbox
% If you compile this script for execution, you need to include all these scripts!

% Bandpass filtering parameters
% TR = 2;         %TR
% fl = 0.008;     %Lower cutoff
% fh = 0.1;       %Upper cutoff
% nifti = 'filtered_data.nii'
% outfile = bandpass_filtered_data.nii' 

% bandpass_fsl(input.nii,outfilename,2.0,0.008,0.1)

% Check to make sure we have 3D data
    if  isempty(regexp(nifti,'.nii.gz','end'))==0
        error('Please use 3D nifti (.nii) data.  Exiting');
       
    else
       % Load in data using load_nii (part of Nifti for MATLAB package)
        data = load_nii(nifti); 

        % Convert to double precision
        timepoints = size(data.img,4);
        xdim = size(data.img,1);
        ydim = size(data.img,2);
        zdim = size(data.img,3);

        holder = zeros(xdim,ydim,zdim,timepoints);

        for t = 1:timepoints
            for x = 1:xdim
                for y = 1:ydim
                    for z = 1:zdim
                        holder(x,y,z,t) = double(data.img(x,y,z,t));
                    end
                end
            end
        end

        data.img = holder;

        % Perform bandpass filtering on nifti data.
        filtered_data = bandpass(data.img,TR,fl,fh);

        % To assure that we have the same origin, voxsize, and datatype of the
        % original image, we will simply copy the filtered_data into the old
        % data variable, and use that to write the new file.
        data.img = filtered_data;

        % Write new image to file, default output is .nii, so outside script
        % can convert to .nii.gz
        save_nii(data,[ outfile '.nii' ]);

    end


end
</code>

And bandpass.m does the actual filtering and returns data to bandpass_fsl to print a filtered nifti image.

```matlab
function X_filtered = bandpass(X,TR,fl,fh)

% Usage:

% This script utilizes the signal processing toolbox in matlab.
% You

% Bandpass filtering parameters
% TR = 2;         %TR
% fl = 0.008;     %Lower cutoff
% fh = 0.1;       %Upper cutoff

% bandpass(roi_ts,TR,fl,fh);

Fs = 1/TR;              %Sampling Frequency
%Fc = 0.5*(fh + fl);     %Center Frequency

%No = floor(Fs * 2/Fc); %Filter Order
No = 18;

X_filtered = X;
for ii = 1:size(X,2)
    y = X(:,ii);
    B = getFiltCoeffs(zeros(1,length(y)),Fs,fl,fh,0,No); %FIR filter Coefficients
    yf1 = filtfilt(B,1,y);              %Filter the data
    X_filtered(:,ii) = yf1;
end

end
</code>

Lastly, here is the filtering script that is called by bandpass.m that uses the signal processing toolbox to filter.  This is done by Kaustubh Supekar.

```matlab
% eegfilt() -  (high|low|band)-iass filter data using two-way least-squares 
%              FIR filtering. Multiple data channels and epochs supported.
%              Requires the MATLAB Signal Processing Toolbox.
% Usage:
%  >> [smoothdata] = eegfilt(data,srate,locutoff,hicutoff);
%  >> [smoothdata,filtwts] = eegfilt(data,srate,locutoff,hicutoff, ...
%                                             epochframes,filtorder);
% Inputs:
%   data        = (channels,frames*epochs) data to filter
%   srate       = data sampling rate (Hz)
%   locutoff    = low-edge frequency in pass band (Hz)  {0 -> lowpass}
%   hicutoff    = high-edge frequency in pass band (Hz) {0 -> highpass}
%   epochframes = frames per epoch (filter each epoch separately {def/0: data is 1 epoch}
%   filtorder   = length of the filter in points {default 3*fix(srate/locutoff)}
%   revfilt     = [0|1] reverse filter (i.e. bandpass filter to notch filter). {0}
%
% Outputs:
%    smoothdata = smoothed data
%    filtwts    = filter coefficients [smoothdata <- filtfilt(filtwts,1,data)]
%
% See also: firls(), filtfilt()
%

% Author: Scott Makeig, Arnaud Delorme, SCCN/INC/UCSD, La Jolla, 1997 

% Copyright (C) 4-22-97 from bandpass.m Scott Makeig, SCCN/INC/UCSD, scott@sccn.ucsd.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: eegfilt.m,v $
% Revision 1.19  2004/11/19 23:28:11  arno
% same
%
% Revision 1.18  2004/11/19 23:27:27  arno
% better error messsage
%
% Revision 1.17  2004/08/31 02:12:56  arno
% typo
%
% Revision 1.16  2004/02/12 23:09:19  scott
% same
%
% Revision 1.15  2004/02/12 23:08:02  scott
% text output edit
%
% Revision 1.14  2004/02/12 22:51:30  scott
% text output edits
%
% Revision 1.13  2003/07/28 17:38:53  arno
% updating error messages
%
% Revision 1.12  2003/07/20 19:17:07  scott
% added channels-processed info if epochs==1 (continuous data)
%
% Revision 1.11  2003/04/11 15:03:46  arno
% nothing
%
% Revision 1.10  2003/03/16 01:00:48  scott
% header and error msgs -sm
%
% Revision 1.9  2003/01/24 03:59:19  scott
% header edit -sm
%
% Revision 1.8  2003/01/24 00:23:33  arno
% print information about transition bands
%
% Revision 1.7  2003/01/23 23:53:25  arno
% change text
%
% Revision 1.6  2003/01/23 23:47:26  arno
% same
%
% Revision 1.5  2003/01/23 23:40:59  arno
% implementing notch filter
%
% Revision 1.4  2002/08/09 14:55:36  arno
% update transition band
%
% Revision 1.3  2002/08/09 02:06:27  arno
% updating transition
%
% Revision 1.2  2002/08/09 02:04:34  arno
% debugging
%
% Revision 1.1  2002/04/05 17:36:45  jorn
% Initial revision
%

% 5-08-97 fixed frequency bound computation -sm
% 10-22-97 added MINFREQ tests -sm
% 12-05-00 added error() calls -sm
% 01-25-02 reformated help & license, added links -ad 

function filtwts = getFiltCoeffs(data,srate,locutoff,hicutoff,epochframes,filtorder, revfilt)

if nargin<4
    fprintf('');
    help eegfilt
    return
end

if ~exist('firls')
   error('*** eegfilt() requires the signal processing toolbox. ***');
end

[chans frames] = size(data);
if chans > 1 & frames == 1,
    help eegfilt
    error('input data should be a row vector.');
end
nyq            = srate*0.5;  % Nyquist frequency
%MINFREQ = 0.1/nyq;
MINFREQ = 0;

minfac         = 3;    % this many (lo)cutoff-freq cycles in filter 
min_filtorder  = 15;   % minimum filter length
trans          = 0.15; % fractional width of transition zones

if locutoff>0 & hicutoff > 0 & locutoff > hicutoff,
    error('locutoff > hicutoff ???\n');
end
if locutoff < 0 | hicutoff < 0,
   error('locutoff | hicutoff < 0 ???\n');
end

if locutoff>nyq,
    error('Low cutoff frequency cannot be > srate/2');
end

if hicutoff>nyq
    error('High cutoff frequency cannot be > srate/2');
end

if nargin<6
   filtorder = 0;
end
if nargin<7
   revfilt = 0;
end

if isempty(filtorder) | filtorder==0,
   if locutoff>0,
     filtorder = minfac*fix(srate/locutoff);
   elseif hicutoff>0,
     filtorder = minfac*fix(srate/hicutoff);
   end
     
   if filtorder < min_filtorder
        filtorder = min_filtorder;
    end
end

if nargin<5
	epochframes = 0;
end
if epochframes ==0,
    epochframes = frames;    % default
end
epochs = fix(frames/epochframes);
if epochs*epochframes ~= frames,
    error('epochframes does not divide frames.\n');
end

if filtorder*3 > epochframes,   % Matlab filtfilt() restriction
    fprintf('eegfilt(): filter order is %d. ',filtorder);
    error('epochframes must be at least 3 times the filtorder.');
end
if (1+trans)*hicutoff/nyq > 1
	error('high cutoff frequency too close to Nyquist frequency');
end;

if locutoff > 0 & hicutoff > 0,    % bandpass filter
    if revfilt
         fprintf('eegfilt() - performing %d-point notch filtering.\n',filtorder);
    else 
         %fprintf('eegfilt() - performing %d-point bandpass filtering.\n',filtorder);
    end; 
    %fprintf('            If a message, ''Matrix is close to singular or badly scaled,'' appears,\n');
    %fprintf('            then Matlab has failed to design a good filter. As a workaround, \n');
    %fprintf('            for band-pass filtering, first highpass the data, then lowpass it.\n');

    f=[MINFREQ (1-trans)*locutoff/nyq locutoff/nyq hicutoff/nyq (1+trans)*hicutoff/nyq 1]; 
    %fprintf('eegfilt() - low transition band width is %1.1g Hz; high trans. band width, %1.1g Hz.\n',(f(3)-f(2))*srate, (f(5)-f(4))*srate/2);
    m=[0       0                      1            1            0                      0]; 
elseif locutoff > 0                % highpass filter
 if locutoff/nyq < MINFREQ
    error(sprintf('eegfilt() - highpass cutoff freq must be > %g Hz\n\n',MINFREQ*nyq));
 end
 %fprintf('eegfilt() - performing %d-point highpass filtering.\n',filtorder);
 f=[MINFREQ locutoff*(1-trans)/nyq locutoff/nyq 1]; 
 %fprintf('eegfilt() - highpass transition band width is %1.1g Hz.\n',(f(3)-f(2))*srate/2);
 m=[   0             0                   1      1];
elseif hicutoff > 0                %  lowpass filter
 if hicutoff/nyq < MINFREQ
    error(sprintf('eegfilt() - lowpass cutoff freq must be > %g Hz',MINFREQ*nyq));
 end
 %fprintf('eegfilt() - performing %d-point lowpass filtering.\n',filtorder);
 f=[MINFREQ hicutoff/nyq hicutoff*(1+trans)/nyq 1]; 
 %fprintf('eegfilt() - lowpass transition band width is %1.1g Hz.\n',(f(3)-f(2))*srate/2);
 m=[     1           1              0                 0];
else
    error('You must provide a non-0 low or high cut-off frequency');
end
if revfilt
    m = ~m;
end;
filtwts = firls(filtorder,f,m); % get FIR filter coefficients
```
