function conn_change_paths(mat_name,oldpath,newpath,slash)
%
% This function replaces portions of each path contained in REX.mat, and
% conn_name.mat, which contain the matrix variables "params" and CONN_x,
% respectively.  
%
% ----------INPUTS----------
% mat_name:  the name of the conn_XX folder and .mat with CONN_x variable
% oldpath:   the old path to be replaced
% newpath:   the new path to replace the old path.
% slash:     the direction of the slash

% This script was created to allow for someone to run a connectivity
% toolbox analysis using the toolbox from MIT in a cluster environment with
% temporary path names, and then easily change the paths to the path on
% a local machine to allow for second level analysis.
%
% ----------SYNTAX----------
%
%   conn_change_paths(mat_name,oldpath,newpath,slash) 
%                                        -> change automatically each path
%   conn_change_paths                    -> show paths and ask for paths to
%                                           be changed
%
% ---------IMPORTANT---------
%
%   - it works only if the portion of the path to be changed is located
%     at the beginning of the entire path
%   - Both .mat files must be located in the work directory
%   - oldpath is case sensitive
%   - slash defines what kind of slash (or backslash) is needed in the
%     new path (this is important when you are moving from a pc to a
%     server or viceversa)
%   - in order to avoid mistakes, it is better to change just essential
%     portions of the path, i.e. if you want to change
%     C:\Experiment\Example\...     in     G:\Test\Experiment\Example\...
%     you should write:
%                       spm_change_paths('C:','G:\Test','\')
%
% --------ATTENTION--------
%
%   Original *.mat will be overwritten, so it's better to make a copy,
%   for example SPM_oldpath.mat
%
% ------PATHS CHANGED------
%% REX.mat:
% params.sources
% params.VF.fnames
% params.rois
% params.ROIinfo.files{1}{1}
%% conn_rest.mat (The .mat with the same name as the analysis)
% CONN_x.filename
% CONN_x.folders.rois
% CONN_x.folders.data
% CONN_x.folders.firstlevel
% CONN_x.folders.secondlevel
% CONN_x.Setup.functional{subnum}{1}{1}
% CONN_x.Setup.structural{subnum}{1}
% CONN_x.Setup.rois.files{nsub}{nroi}{1}
% CONN_x.Setup.l1covariates.files{nsub}{1}{1}{1}
% CONN_x.Setup.functional{subnum}{1}{3}(1).fname
% CONN_x.Setup.functional{subnum}{1}{3}(1).private.dat.fname
% CONN_x.Setup.structural{subnum}{3}.fname
% CONN_x.Setup.structural{subnum}{3}.private.dat.fname
% CONN_x.Setup.structural{subnum}{2}{2}
% CONN_x.Setup.rois.files{subnum}{1}{2}{2}
% CONN_x.Setup.rois.files{subnum}{1}{3}.fname
% CONN_x.Setup.rois.files{subnum}{1}{3}.private.dat.fname
% CONN_x.Setup.l1covariates.files{subnum}{1}{1}{2}{2}
%
% ---------EXAMPLES--------
%
%   conn_change_paths
%   conn_change_paths('conn_rest.mat','/mnt/etc/','N:/DNS.01/','\')
%
% --
% Written by:        Vanessa Sochat
% Last modified:     11/24/2010


%% File Selection

if nargin == 0
    % Allow the user to select an input .mat file:
    [filename, pathname] = uigetfile('*.mat', 'Select your conn .mat file (not REX.mat)');
    if isequal(filename,0) || isequal(pathname,0)
       disp('You pressed cancel!')
       error('You canceled out of the file selector.  Please run script again!');
    else
       disp(['You have selected ', fullfile(pathname, filename) ' for your .mat file.'])
       mat_name = fullfile(pathname,filename);
    end

   load(mat_name);
   load('REX.mat','params');
   disp(' ');
   disp(' Path used in CONN_x is:');
   disp(CONN_x.filename);
   disp(' ');
   disp(' Path used in REX.mat is:');
   disp(params.sources(1,:));
   disp(' ');
   disp(' ');
   oldpath = input('Insert portion of path to be changed: ','s');
   newpath = input('Insert new portion of path: ','s');
   slash = input('Slash ''/'' or Backslash ''\\''?: ','s');
    if slash == '\'
       old_slash = '/';
    elseif slash == '/'
       old_slash = '\';
    else
       error('Incorrect slash or backslash, see ''help spm_change_paths''')
    end
   disp(' ');
   response1 = input(' Change CONN_x paths? Y/N [Y]: ','s');
    if isempty(response1) | response1 == 'Y' | response1 == 'y'
       change_conn(mat_name,oldpath,newpath,slash,old_slash);
    else
       disp(' ');
    end
   response2 = input(' Change REX.mat paths? (should be in same directory) Y/N [Y]: ','s');
    if isempty(response2) | response2 == 'Y' | response2 == 'y'
       change_rex(params,oldpath,newpath,slash,old_slash);    
    else
       disp(' ');
    end 
  
elseif nargin == 4
    if slash == '\'
       old_slash = '/';
    elseif slash == '/'
       old_slash = '\';
    else
       error('Incorrect slash or backslash, see ''help spm_change_paths''')
    end
   change_conn(mat_name,oldpath,newpath,slash,old_slash);
   load('REX.mat','params')
   change_rex(params,oldpath,newpath,slash,old_slash);
   
elseif nargin ~= 0 &  nargin ~= 4
   error('Incorrect number of input arguments, see ''help spm_change_paths''')
   
end

disp('Paths in modified as requested.');

%--------------------------------------------------------------------------
% CHANGE CONN_X PATHS
%--------------------------------------------------------------------------
function change_conn(mat_name,oldpath,newpath,slash,old_slash)
C = load(mat_name);
CONN_x=C.CONN_x;

% CONN_x.filename
size_filename = size(CONN_x.filename);
size_oldpath = length(oldpath);
size_newpath = length(newpath);
new_size_filename = size_filename(1,2) - size_oldpath + size_newpath;
for i = 1:new_size_filename
      if i <= size_newpath
          temp(i) = newpath(i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      else
          temp(i) = CONN_x.filename(size_oldpath-size_newpath+i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      end
end
CONN_x.filename = temp;
save(mat_name,'-append','CONN_x')
disp(' CONN_x.filename changed successfully.');
clear temp size_filename new_size_filename
  
% CONN_x.folders.rois
size_folder = size(CONN_x.folders.rois);
new_size_folder = size_folder(1,2) - size_oldpath + size_newpath;
for i = 1:new_size_folder
      if i <= size_newpath
          temp(i) = newpath(i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      else
          temp(i) = CONN_x.folders.rois(size_oldpath-size_newpath+i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      end
end
CONN_x.folders.rois = temp;
save(mat_name,'-append','CONN_x')
disp(' CONN_x.folders.rois changed successfully.');
clear temp size_folder new_size_folder

% CONN_x.folders.data
size_folder = size(CONN_x.folders.data);
new_size_folder = size_folder(1,2) - size_oldpath + size_newpath;
for i = 1:new_size_folder
      if i <= size_newpath
          temp(i) = newpath(i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      else
          temp(i) = CONN_x.folders.data(size_oldpath-size_newpath+i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      end
end
CONN_x.folders.data = temp;
save(mat_name,'-append','CONN_x')
disp(' CONN_x.folders.data changed successfully.');
clear temp size_folder new_size_folder

% CONN_x.folders.firstlevel
size_folder = size(CONN_x.folders.firstlevel);
new_size_folder = size_folder(1,2) - size_oldpath + size_newpath;
for i = 1:new_size_folder
      if i <= size_newpath
          temp(i) = newpath(i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      else
          temp(i) = CONN_x.folders.firstlevel(size_oldpath-size_newpath+i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      end
end
CONN_x.folders.firstlevel = temp;
save(mat_name,'-append','CONN_x')
disp(' CONN_x.folders.firstlevel changed successfully.');
clear temp size_folder new_size_folder

% CONN_x.folders.secondlevel
size_folder = size(CONN_x.folders.secondlevel);
new_size_folder = size_folder(1,2) - size_oldpath + size_newpath;
for i = 1:new_size_folder
      if i <= size_newpath
          temp(i) = newpath(i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      else
          temp(i) = CONN_x.folders.secondlevel(size_oldpath-size_newpath+i);
          if temp(i) == old_slash
              temp(i) = slash;
          end;
      end
end
CONN_x.folders.secondlevel = temp;
save(mat_name,'-append','CONN_x')
disp(' CONN_x.folders.secondlevel changed successfully.');
clear temp size_folder new_size_folder

% CONN_x.Setup.functional{subnum}{1}{3}(1).fname and
% CONN_x.Setup.functional{v}{1}{3}(1).private.dat.fname
% the image path in {x}{1}{3}{1} is the first image
% the image path in {x}{1}{3}{2} is the last image

% Pullthe number of subjects in the analysis:
subnums=CONN_x.Setup.nsubjects;
for v=1:subnums
    CONN_x.Setup.functional{v}{1}{3}(1).fname=strrep(CONN_x.Setup.functional{v}{1}{3}(1).fname,oldpath,newpath);
    CONN_x.Setup.functional{v}{1}{3}(1).fname=strrep(CONN_x.Setup.functional{v}{1}{3}(1).fname,old_slash,slash);
    CONN_x.Setup.functional{v}{1}{3}(2).fname=strrep(CONN_x.Setup.functional{v}{1}{3}(2).fname,oldpath,newpath);
    CONN_x.Setup.functional{v}{1}{3}(2).fname=strrep(CONN_x.Setup.functional{v}{1}{3}(2).fname,old_slash,slash);
    CONN_x.Setup.functional{v}{1}{3}(1).private.dat.fname=strrep(CONN_x.Setup.functional{v}{1}{3}(1).private.dat.fname,oldpath,newpath);
    CONN_x.Setup.functional{v}{1}{3}(1).private.dat.fname=strrep(CONN_x.Setup.functional{v}{1}{3}(1).private.dat.fname,old_slash,slash);
    CONN_x.Setup.functional{v}{1}{3}(2).private.dat.fname=strrep(CONN_x.Setup.functional{v}{1}{3}(2).private.dat.fname,oldpath,newpath);
    CONN_x.Setup.functional{v}{1}{3}(2).private.dat.fname=strrep(CONN_x.Setup.functional{v}{1}{3}(2).private.dat.fname,old_slash,slash);
end    

% CONN_x.Setup.structural{1}{3}.fname
for v=1:subnums
    CONN_x.Setup.structural{v}{3}.fname=strrep(CONN_x.Setup.structural{v}{3}.fname,oldpath,newpath);
    CONN_x.Setup.structural{v}{3}.fname=strrep(CONN_x.Setup.structural{v}{3}.fname,old_slash,slash);
    CONN_x.Setup.structural{v}{3}.private.dat.fname=strrep(CONN_x.Setup.structural{v}{3}.private.dat.fname,oldpath,newpath);
    CONN_x.Setup.structural{v}{3}.private.dat.fname=strrep(CONN_x.Setup.structural{v}{3}.private.dat.fname,old_slash,slash);
    CONN_x.Setup.structural{v}{2}{2}=strrep(CONN_x.Setup.structural{v}{2}{2},oldpath(1:4),newpath(1:4));
    CONN_x.Setup.structural{v}{2}{2}=strrep(CONN_x.Setup.structural{v}{2}{2},old_slash,slash);
end    

% CONN_x.Setup.functional{subnum}{1}{1}

for v=1:subnums
    size_functional = size(CONN_x.Setup.functional{v}{1}{1});
    if size_functional(1,2) == 1
        for i = 1:size_functional
            CONN_x.Setup.functional{v}{1}{1} = strrep(CONN_x.Setup.functional{v}{1}{1},oldpath,newpath);
            CONN_x.Setup.functional{v}{1}{1} = strrep(CONN_x.Setup.functional{v}{1}{1},old_slash,slash);
        end
    else
        new_size_functional = size_functional(1,2) - size_oldpath + size_newpath;
    for i=1:size_functional(1,1)
      for j = 1:new_size_functional
          if j <= size_newpath
              temp2(i,j) = newpath(j);
              if temp2(i,j) == old_slash
                temp2(i,j) = slash;
              end;
          else
              k = size_oldpath-size_newpath+j;
              temp2(i,j) = CONN_x.Setup.functional{v}{1}{1}(i,k);
              if temp2(i,j) == old_slash
                temp2(i,j) = slash;
              end;
          end
      end
    end
    CONN_x.Setup.functional{v}{1}{1} = temp2;
    end
end

 save(mat_name,'-append','CONN_x')
 disp(' CONN_x.Setup.functional paths changed successfully.');
 clear size_functional new_size_functional i j k v

% CONN_x.Setup.structural{subnum}{1}
for v=1:subnums
    size_structural = size(CONN_x.Setup.structural{v}{1});
    if size_structural(1,1) == 1
        for i = 1:size_structural(1,1)
            CONN_x.Setup.structural{v}{1} = strrep(CONN_x.Setup.structural{v}{1},oldpath,newpath);
            CONN_x.Setup.structural{v}{1} = strrep(CONN_x.Setup.structural{v}{1},old_slash,slash);
        end
    else
        new_size_structural = size_structural(1,2) - size_oldpath + size_newpath;
    for i=1:size_structural(1,1)
      for j = 1:new_size_structural
          if j <= size_newpath
              temp2(i,j) = newpath(j);
              if temp2(i,j) == old_slash
                temp2(i,j) = slash;
              end;
          else
              k = size_oldpath-size_newpath+j;
              temp2(i,j) = CONN_x.Setup.structural{v}{1}(i,k);
              if temp2(i,j) == old_slash
                temp2(i,j) = slash;
              end;
          end
      end
    end
    CONN_x.Setup.structural{v}{1} = temp2;
    end
end

 save(mat_name,'-append','CONN_x')
 disp(' CONN_x.Setup.structural paths changed successfully.');
 clear size_structural new_size_structural

% CONN_x.Setup.rois.files{nsub}{nroi}{1}
for v=1:subnums
    size_rois = size(CONN_x.Setup.rois.files{v},2);
        for i = 1:size_rois
            CONN_x.Setup.rois.files{v}{i}{1} = strrep(CONN_x.Setup.rois.files{v}{i}{1},oldpath,newpath);
            CONN_x.Setup.rois.files{v}{i}{1} = strrep(CONN_x.Setup.rois.files{v}{i}{1},old_slash,slash);
            CONN_x.Setup.rois.files{v}{i}{2}{2} = strrep(CONN_x.Setup.rois.files{v}{i}{2}{2},oldpath(1:4),newpath(1:4));
            CONN_x.Setup.rois.files{v}{i}{2}{2} = strrep(CONN_x.Setup.rois.files{v}{i}{2}{2},old_slash,slash);
            
            if isfield(CONN_x.Setup.rois.files{v}{i}{3},'fname')
                CONN_x.Setup.rois.files{v}{i}{3}.fname = strrep(CONN_x.Setup.rois.files{v}{i}{3}.fname,oldpath,newpath);
                CONN_x.Setup.rois.files{v}{i}{3}.fname = strrep(CONN_x.Setup.rois.files{v}{i}{3}.fname,old_slash,slash);
                CONN_x.Setup.rois.files{v}{i}{3}.private.dat.fname = strrep(CONN_x.Setup.rois.files{v}{i}{3}.private.dat.fname,oldpath,newpath);
                CONN_x.Setup.rois.files{v}{i}{3}.private.dat.fname = strrep(CONN_x.Setup.rois.files{v}{i}{3}.private.dat.fname,old_slash,slash);   
            end
        end
end

 save(mat_name,'-append','CONN_x')
 disp(' CONN_x.Setup.rois.files paths changed successfully.');
 clear size_rois


% CONN_x.Setup.l1covariates.files{nsub}{1}{1}{1}
for v=1:subnums
    size_covars = size(CONN_x.Setup.l1covariates.files{v},2);
        for i = 1:size_covars
            CONN_x.Setup.l1covariates.files{v}{i}{1}{1} = strrep(CONN_x.Setup.l1covariates.files{v}{i}{1}{1},oldpath,newpath);
            CONN_x.Setup.l1covariates.files{v}{i}{1}{1} = strrep(CONN_x.Setup.l1covariates.files{v}{i}{1}{1},old_slash,slash);
            CONN_x.Setup.l1covariates.files{v}{1}{1}{2}{2} = strrep(CONN_x.Setup.l1covariates.files{v}{1}{1}{2}{2},oldpath(1:4),newpath(1:4));
            CONN_x.Setup.l1covariates.files{v}{1}{1}{2}{2} = strrep(CONN_x.Setup.l1covariates.files{v}{1}{1}{2}{2},old_slash,slash);
        end
end

 save(mat_name,'-append','CONN_x')
 disp(' CONN_x.Setup.l1covariates.files paths changed successfully.');
 clear size_covars

end
%--------------------------------------------------------------------------
% CHANGE REX.mat PATHS
%--------------------------------------------------------------------------

function change_rex(params,oldpath,newpath,slash,old_slash)

disp( 'Changing params variable in REX.mat.' )

% params.sources
size_sources=length(params.sources);
for i = 1:size_sources
    temp{i} = strrep(params.sources(i,:),oldpath,newpath);
    temp(i) = strrep(temp(i),old_slash,slash);
end
  
string=('[temp{1}');
for j = 2:size_sources
    if j ~= size_sources
        string=horzcat(string,';temp{',num2str(j),'}');
    else
        string=horzcat(string,';temp{',num2str(j),'}]');
    end 
end
  
params.sources=eval(string);
save('REX.mat','-append','params')
disp(' params.sources paths changed successfully.');
clear string size_sources temp i j
  
% params.VF.fnames
size_fnames=length(params.VF);
for i = 1:size_fnames
    params.VF(i).fname = strrep(params.VF(i).fname,oldpath,newpath);
    params.VF(i).fname = strrep(params.VF(i).fname,old_slash,slash);
end
    
save('REX.mat','-append','params')
disp(' params.VF paths changed successfully.');
clear size_fnames

% params.rois
params.rois = strrep(params.rois,oldpath,newpath);
params.rois = strrep(params.rois,old_slash,slash);
save('REX.mat','-append','params')
disp(' params.rois changed successfully.');

% params.ROIinfo.files{1}{1}
% This path has an additional /ram in front of /mnt
params.ROIinfo.files{1}{1} = strrep(params.ROIinfo.files{1}{1},[ '/ram' oldpath ],newpath);
params.ROIinfo.files{1}{1} = strrep(params.ROIinfo.files{1}{1},old_slash,slash);

save('REX.mat','-append','params')
disp(' params.ROIinfo.files path changed successfully.');
end

end

% EOF
