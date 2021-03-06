function confirmation_email(contactemail)

% CONFIRMATION_EMAIL
% Vanessa Sochat
%
% This script sends confirmation emails for imaging and battery appointments 
% added to the calendar the previous day.
%
% -------------------------------------------------------------------------
% VARIABLES:
% 
% contactemail: An email address that you want to be notified in 
% the case of error
%
% -------------------------------------------------------------------------
% DEPENDENCY:
% For the script to work, it must have access to each of the appointment 
% private calendars (URL's hard coded), and the data in the calendar must
% have the user email as the first thing in the Description field, like so
% 
% Name: Jane Doe 
% Phone: (999) 999-9999 
% E-mail: jane.doe@duke.edu 
%
% poozie.mat must be in the same folder it is running from
%
% schedule.csv: Downloaded by the batch script just before running
% the matlab script - this file contains all subject specific info that is
% used to look up an individual based on name.
%--------------------------------------------------------------------------
% OUTPUT:
% A log of confirmation email info is saved, and all files are located
% under:
%
% Y:/Scripts/Appointments
% -------------------------------------------------------------------------

%-------------------------------------------------------------------------- 
% Set up mail credentials
%--------------------------------------------------------------------------

load poozie.mat
email_count=0;

% Path to the reminder and directions sheet
reminder_directions = 'Y:/Scripts/Appointments/Reminder_and_Directions.pdf';
% Then this code will set up the preferences properly:
setpref('Internet','E_mail',poozie);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',poozie);
setpref('Internet','SMTP_Password',pooziepa);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');


%-------------------------------------------------------------------------- 
% Read in appointment file (schedule.csv) downloaded from server
%--------------------------------------------------------------------------

% If the file exists, read it in.  If it doesn't, exit with an error,
% record error to the log, and email Vanessa about error.

if exist('schedule.csv','file')
    fid = fopen('schedule.csv');
else
    % Initialize and print to file
    fid = fopen('ERROR_LOG.txt', 'a');
    fprintf(fid, 'Date: ');
    fprintf(fid,'%s\n', date');
    fprintf(fid, 'Schedule file does not exist! Check download.');
    fclose(fid);
    % If the user has provided an email, alert that email of the failure:
    if exist('contactemail','var')
        sendmail(contactemail,'Message from Rem_Email.m',[  'The script exited with error on ' date ' while sending out ' days ' day reminders for the ' calendar ' calendar. '],'');
    end
        error('Schedule file does not exist');
end

% READ APPOINTMENT INFORMATION FROM FILE

% First read in the header fields
H = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s \n', 'delimiter', ',');
% StartTime {H1}
% EndTime (H2)
% First Name (H3)
% Last Name (H4)
% Phone (H5)
% Email (H6)
% Type (H7)
% Calendar (H8)
% Duke Unique ID (H9)
% Text Message? (H10)
% Phone Carrier (H11)

% Then read the data from the rest of the file
C = textscan(fid, '%s %s %s %s %s %s %s %s %s %s %s %s %s', 'delimiter', ',');

% StartDate {C1}
% StartTime (C2)
% EndDate (C3)
% EndTime (C4)
% First Name (C5)
% Last Name (C6)
% Phone (C7)
% Email (C8)
% Appointment Type (C9)
% Clinician (C10)
% Unique ID (C11)
% Text Message? (C12)
% Phone Carrier (C13)

% Now we convert a cell array into an array of strings so we can read each
% one, only for the fields that we are interested in.
FirstNames = C{5};
LastNames = C{6};
Phones = C{7};
Emails = C{8};
Txt = C{12};
Carriers = C{13};

fclose(fid);
clear C H fid;

%-------------------------------------------------------------------------- 
% Download latest appointments from imaging and computer calendar to file
%--------------------------------------------------------------------------

% CD to directory for saving current appointment files
cd('Y:/Scripts/Appointments/');

% Download and save the calendar data, if it doesn't already exist in the
% folder (since the reminder emails are sent just before and haven't been
% deleted by the batch script, these files should already exist!)

if exist('imaging.txt','file')==0
    calie{1} = urlwrite(schmoogie,'imaging.txt','get',{});
else
    calie{1} = 'imaging.txt';
end
meetingloc{1} = 'Soc-Psych 07';
cal{1} = 'Imaging';

if exist('computer.txt','file')==0
    calie{2} = urlwrite(yebya,'computer.txt','get',{});
else
    calie{2} = 'computer.txt';
end
meetingloc{2} = 'LSRC B Lobby';
cal{2} = 'Computer';

%--------------------------------------------------------------------------
% Read appointments from the file and save to variable
%--------------------------------------------------------------------------

% Open the subject appointment file, which was an .ical file that we open as
% a text file

for v=1:2
    
fln = fopen(calie{v});

% Create a subject count variable
appt_count=0;

% Set the current appointment date to today, so we can stop reading the
% file when the appointments go into the past.
Appointment=date;

% Set today's date in a number format for easy comparison
today = datenum(date);

while ~feof(fln)
        
        % We need to make sure that we only read in appointments for today and
        % in the future, so we do a comparison between the current appointment
        % that is being read.  We use a do-->while loop so that the comparison
        % until after a subject has been
        
        % Read in line 
        currentline = fgetl(fln);
        
        % Look to see if we have a date line, which starts with 'DSTART'
        if regexp(currentline, 'DTSTART', 'once');
            %if yes, pull the date and time from this line, and format
            year = currentline(9:12);
            month = currentline(13:14);
            day = currentline(15:16);
            appointment = datestr([ year ' ' month ' ' day ]);
            time = currentline(18:21);
            time = str2double(time);
            
            % The time is 4 hours in the future, so we subtract 4:
            time = time - 400;
            
            % Convert military time to standard time
            if (time > 1259)
                time = time-1200;
                period = 'pm';
            else
                if (time >= 1200) && (time <= 1259)
                    period = 'pm';
                else
                    period = 'am';
                end
            end
            
            % Format time with a ":" by separating the last two characters 
            % from the first, and sticking them together with a ":"
            time = num2str(time);
            time_end = time(length(time)-1:length(time));
            time_beg = regexprep(time, time_end, '','once');
            
            % Put it all together into a user friendly format for printing
            time = [ time_beg ':' time_end ' ' period ];
                    
            % If the appointment is from before today, we don't want to do
            % anything.
            if(today > datenum(appointment))
                
            else
                %Add another subject to the array if they aren't from the past
                appt_count = appt_count +1;
                APPTS(appt_count)= struct('First','','Last','','Email', '','Phone','','Appointment', appointment, 'Time', time,'Text','','Carrier','','Created','');
            end
        end
        
        % Look to see if we have a date created line, which starts with 'CREATED'
        if regexp(currentline, 'CREATED', 'once');
            %if yes, pull the date and time from this line, and format
            create_year = currentline(9:12);
            create_month = currentline(13:14);
            create_day = currentline(15:16);
            created = datestr([ create_year ' ' create_month ' ' create_day ]);
                    
            % If the appointment is from before today, we don't want to do
            % anything.
            if(today > datenum(appointment))
                
            else
                APPTS(appt_count).Created = created;            
            end
        end
        
        % Look to see if we have a participant info line:
        if regexp(currentline, 'DESCRIPTION', 'once');
            % Only read the line if there is data there, meaning the length
            % is greater than 12 (the length of DESCRIPTION:)
            if length(currentline) > 12     
                % If the appointment is from the past, skip it, as we did
                % above
                if (today > datenum(appointment))
                    
                else
                    %if yes, first get rid of the 'DESCRIPTION:Name: ' section
                    currentline = regexprep(currentline, currentline(1:18), '','once');
                    % Put the first name into a variable by finding the end of it,
                    % marked by a space
                    marker = regexp(currentline, ' ', 'once');
                    name = currentline(1:marker-1);
                    currentline = regexprep(currentline, currentline(1:marker), '','once');
                    % Put the last name into a variable by finding the end,
                    % marked by a space
                    marker = regexp(currentline, ' ', 'once');
                    lastname = currentline(1:marker-1);
                    % Add name to the data structure
                    APPTS(appt_count).First = deblank(name);
                    APPTS(appt_count).Last = deblank(lastname);
            
                end
            end
        end
        % Take in the name from the summary field, in case we need it
        if regexp(currentline, 'SUMMARY', 'once');
            currentline = regexprep(currentline, currentline(1:8), '','once');
            % Put the first name into a variable by finding the end of it,
            % marked by a space
            marker = regexp(currentline, ' ', 'once');
            name = currentline(1:marker-1);
            currentline = regexprep(currentline, currentline(1:marker), '','once');
            % Put the last name into a variable by finding the end,
            % marked by a space
            marker = regexp(currentline, ' ', 'once');
                if isempty(marker)
                    lastname = currentline;
                else
                    lastname = currentline(1:marker-1);
                end
                
                % In the case that the name was not present in the
                % DESCRIPTION, we can get it from the Summary!
                if isempty(APPTS(appt_count).First)
                    APPTS(appt_count).First = deblank(name);
                end
                if isempty(APPTS(appt_count).Last)
                    APPTS(appt_count).Last = deblank(lastname);
                end
        end
end

%-------------------------------------------------------------------------- 
% Find rest of subject info by reading from Appointment file
%--------------------------------------------------------------------------
% Need to find a way to decrease search through appointment file! Right now
% we look at everyone and compare First and Last Name.  Since the 
% information on the calendar is equivalent to the online system,
% these fields should match for each subject.  If we have duplicates, then
% Vanessa can add phone number matching to the script.  We place the
% current first and last name in a deblanked variable instead of
% referencing them from the array each time so we can easily calculate the
% length without blank spaces.

for i=1:length(FirstNames)
    for k=1:length(APPTS)
        currentfirst = deblank(FirstNames{i});
        currentlast = deblank(LastNames{i});
        if length(APPTS(k).First) >= length(currentfirst)
            if strcmp(currentfirst,deblank(APPTS(k).First(1:length(currentfirst))))
                if length(APPTS(k).Last) >= length(currentlast)
                    if strcmp(currentlast,deblank(APPTS(k).Last(1:length(currentlast))))
                        APPTS(k).Phone = deblank(Phones{i});
                        APPTS(k).Text = Txt{i};
                        APPTS(k).Carrier = Carriers{i};
                        APPTS(k).Email = deblank(Emails{i});
                    end
                end
            end
        end
    end
end

clear currentfirst currentlast
        
%--------------------------------------------------------------------------
% Send confirmation emails
%--------------------------------------------------------------------------

% Cycle through the participants in the array, and if the appointment was 
% made the previous day (since this script runs in the wee hours of the
% morning) we want to send a confirmation email with directions attached.

yesterday = today -1;

for i=1:size(APPTS,2)
    if (datenum(APPTS(i).Created) == yesterday)
            % -------------------------------------------------------------
            % FIRST SEND EMAIL
            %--------------------------------------------------------------
            % If the subject has an email, we send a confirmation email    
            if isempty(APPTS(i).Email)==0
                    sendmail(APPTS(i).Email,[ 'Laboratory of Neurogenetics - ' cal{v} ' Appointment Confirmation' ],[ APPTS(i).First ', this is a confirmation of your ' cal{v} ' session appointment on ' datestr(APPTS(i).Appointment,'mmm dd, yyyy') ' at ' APPTS(i).Time '. For your appointment, please meet the experimenter at ' meetingloc{v} '. Appointment details and directions are attached.' ],reminder_directions);
            else
                    % We will want to know about this error, so we save the
                    % subject information to an array, to be emailed later.
                    APPT_ERRORS(email_count+1) = APPTS(i);
            end
    end
end

%-------------------------------------------------------------------------- 
% Update sending log
%--------------------------------------------------------------------------
% Initialize and print to file
    lid = fopen('CONFIRMATION_LOG.txt', 'a');
           
% List the headings if the file is just being created
if exist('CONFIRMATION_LOG.txt','file')==0
    fprintf(lid, 'Date,Calendar,Appt_Days_Away,First,Last,Email,Phone,Appointment,Time,Text,Carrier,');
end

for i=1:numel(APPTS)
    fprintf(lid,'\n%s', [ date ',' ]');
    fprintf(lid,'%s', [ cal{v} ',' ]');
    fprintf(lid,'%s', [ APPTS(i).First ',' ]');
    fprintf(lid,'%s', [ APPTS(i).Last ',' ]');
    fprintf(lid,'%s', [ APPTS(i).Email ',' ]');
    fprintf(lid,'%s', [ APPTS(i).Phone ',' ]');
    fprintf(lid,'%s', [ APPTS(i).Appointment ',' ]');
    fprintf(lid,'%s', [ APPTS(i).Time ',' ]');
    fprintf(lid,'%s', [ APPTS(i).Text ',' ]');
    fprintf(lid,'%s', APPTS(i).Carrier);
end
    fclose(lid);

end

clear i Phones Txt Carriers Emails FirstNames LastNames

%--------------------------------------------------------------------------
% Email to send if there are errors in reading the calendar or sending
% brains
%--------------------------------------------------------------------------

if exist('APPT_ERRORS','var')
    save('APPT_ERRORS','APPTS.mat');
    if exist('contactemail','var')
        sendmail(contactemail,'Message from Rem_Email.m',[  'The script had subjects with missing emails on ' date ' while sending out confirmation emails for the ' cal{v} ' calendar. The attached mat file contains these subjects!'],'APPTS.mat');
    end
end
    
% Exit from matlab to run the next script
exit

end
