function format_ID(file)
%-------------------------------------------------------------------------
% format_ID(): allows the user to input a saved text file of subject 
% IDs, and returns a formatted version of this list to be used in scripts.
% The user can either specify the file as an input argument, or select
% the file via a GUI.  For the sake of simplicity, it must be a text
% file, with one subject ID per line.
%-------------------------------------------------------------------------

fprintf('\n%s\n','FORMAT ID');
fprintf('%s\n','Vanessa Sochat');
fprintf('%s\n','October 2010');

%--------------------------------------------------------------------------
% Check user input
%--------------------------------------------------------------------------
if nargin == 1 
    % check to make sure that the user has input the correct file type.
    % Here we use regexp to find the .txt extension. If not found, we exit 
    % with an error.
    ext_markers=regexp(file, '.txt', 'once');
    if isempty(ext_markers)==1
        error('The first argument must be a .txt file');
    end   

elseif nargin == 0
    % Allow the user to select an input file:
    [filename, pathname] = uigetfile('*.txt', 'Select a .txt file');
    if isequal(filename,0) || isequal(pathname,0)
       disp('You pressed cancel!')
       error('You canceled out of the file selector.  Please run format_ID again!');
    else
       disp(['You have selected ', fullfile(pathname, filename) ' for your text file.'])
       file = fullfile(pathname,filename);
    end

    % check to make sure that the user has input the correct file type.
    % Here we use regexp to find the .txt extension. If not found, we exit 
    % with an error.
    ext_markers=regexp(file, '.txt', 'once');
    if isempty(ext_markers)==1
        error('The first argument must be a .txt file');
    end
else
    error('You can only input either one argument, a text file with a list of subjects, one per line, or no arguments.  Exiting.');
    
end

%--------------------------------------------------------------------------
% Read in subject ID's from file
%--------------------------------------------------------------------------

fid = fopen(file);

if isempty(file)
    error('Error: File selected is empty!')
end

% We put the first column of values (Gene ID) into C{1} and the second
% column (SNPs) into C{2} and ignore the rest
A = textscan(fid, '%s');
% Now we convert a cell array into a matrix of strings so we can read each
% one
B = A{1};
fclose(fid);
clear A;

%--------------------------------------------------------------------------
% Format subject IDs and present output
%--------------------------------------------------------------------------

output = 'subnums = [';

for i=1:length(B)
    if i ~= length(B)
    output = [ output '"' deblank(B{i}) '",' ];
    else
    output = [ output '"' deblank(B{i}) '"]' ];
    end
end
   
fprintf('\n%s\n','Your output string is as follows:');
fprintf('\n%s\n',output);

end