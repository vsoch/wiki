# Reminder Email and Text Messages
I wrote a combination of batch and matlab scripts to send out automatic reminder and confirmation emails and text messages.  Everything is run via a master batch script, which can be set up to run automatically on a nightly basis with a scheduled task.  You could also use a cron job if you want something like this to run in a server environment. This could be run from anywhere that has access to the batch script and an "Appointments" folder with the various other files and scripts required, and of course the computer needs an installation of matlab.  This Appointments Folder contains scripts and files necessary for sending out automatic, nightly reminder emails, text reminders, and email confirmations for imaging and computer battery data.  This documentation will explain the contents of the folder, as well as the workings
of the various scripts.  This solution was never implemented in my lab, and it is an imperfect solution in that someone will not receive a reminder email or text message if their email is missing from the google calendar, but it was a good solution given the limited access to the information needed.  However, if I created another reminder system, I would likely not use matlab at all, and go with something run with databases and possibly php or python, or anything that works with sqlite3!

## Overview of Files

**rem_email.bat**
This batch script is responsible for downloading necessary appointment data from a secure server, and running the matlab scripts to send out reminder and confirmation notifications.  The script would have been run nightly at 4:00am to ensure that new files have been downloaded and we have the most up to date information.  It basically maps a drive to download new data, runs the matlab scripts to send out reminders, deletes temporary files
produced by the scripts, and then closes the mapped drive.  The script is as follows:

```batch
rem Reminder Email and Text Message Script

rem Maps drive to server using login and password already setup on server
net use /user:usernamegoeshere L: servernamehere passhere

rem get updated appointment schedule and save to folder
CD /D L:/webspace/
COPY schedulename.csv Y:PathtoAppointmentsfolder

rem Run matlab send reminder email script for imaging 72 hours away, behavioral battery / imaging 24 hours away
CD /D Y:PathtoAppointmentsfolder
matlab -nosplash -nodesktop -r rem_email(1,'Computer','yes','yes','contactaddress')
matlab -nosplash -nodesktop -r rem_email(3,'Imaging','no','yes','contactaddress')
matlab -nosplash -nodesktop -r rem_email(1,'Imaging','yes','yes','contactaddress')

rem Run matlab confirmation email script for appointments made yesterday
matlab -nosplash -nodesktop -r confirmation_email('contactaddress')

rem delete imaging and computer text files, if they exist.  The matlab script will delete the schedulename.csv
ECHO Y | DEL imaging.txt
ECHO Y | DEL computer.txt
ECHO Y | DEL schedulename.csv

rem Close mapping of drive
CD /D C:/
net use /delete L:
```


**schedulename.csv:**  Is scheduling information for people that make clinic appointments.  Since everyone who is signed up for a battery or imaging appointment has had a clinical appointment, this is a reliable source to extract participant info (Name, Email, Phone, permission to text, phone carrier) for the imaging and computer appointments. We download this from our appointment system with a Sikuli script, and it gets saved onto another server, which we map to to download an up to date copy before running the reminder scripts

**somename.mat** must be in the same folder these scripts run from, as it includes sending credentials that are loaded on spot as opposed to being hardcoded into the file.

### REMINDER EMAIL
[rem_email.m](scripts/rem_email.m)
Takes in the following arguments:  rem_email(days,cal,sendtxt,sendemail,contactemail)
  * days: This is the number of days in advance that the reminder emails will be sent. (1 = 24 hrs, 2 = 48 hrs, etc)
  * calendars: This is the calendar name that the reminders will be sent to, for each of the times indicated.  This can currently be "Computer" or "Imaging."
  * sendtxt: 'yes' indicates we want to send a text message, no means no!
  * sendemail: 'yes' indicates we want to send an email, no means no!
  * contactemail:(optional) An email address that you want to be notified in the case of error
 
This script depends on the imaging and computer calendars to be formatted with the participant first and last name in the Title (Summary) field, and the appointment information copied from the clinical calendar into the description field the following format:
```
Name: Jane Doe
Phone: (999) 999-9999
E-mail: jane.doe@duke.edu
```

**The script works as follows:** 
  - Downloads the latest computer or imaging calendar based on a private ical address, and saves the data as either 'imaging.txt' or 'computer.txt.' 
  - Reads schedulename.csv (just downloaded) into matlab.  In the case that this file doesn't exist (due to a download error, etc) it records this into the error log, and contacts the 'contactemail' about the error. 
  - While reading in information from the calendar file, the script places the participant name, and appointment date and time into a structure called APPTS for ONLY appointments in the future.  All of this data is read in from particular locations in the calendar file, and formatted between numbers and strings so we can both do calculations (numbers) and print the variables (strings) into text in reminder emails, etc. 
  - Important Notes about the formatting of the calendar:  In the case that the script cannot find the person's name as the first field under "Description" - it extracts it from the "SUMMARY" field - which is like the Title of the event on the calendar.  If both these locations are missing the participant name, the script will exit with error. 
  - The script next uses the fields from the schedulename.csv file as a lookup table, and finds participants by first and last name to match with individuals with future appointments only.  Currently, we have no third check, so if two people have the exact same name, the script will find 
the one that appears earliest in the file.  This hasn't been an issue thus far, but if it becomes an issue Vanessa will troubleshoot a solution. 
  - As the script matches participants in the structure (read in from the calendar file) with additional information read from the schedule.csv (phone, email, text permission, and carrier), it updates the structure, so at the end of this process we have a complete structure with information 
for all subjects with future imaging or computer appointments.  Since these are scheduled always  within a week of the clinical appointment and never greater than a week apart, this structure should never get greater than perhaps 30.  Even if it did, it wouldn't be an issue. 
  - Once we have a complete structure of participant names, emails, phones, appointment dates and times, permission to contact by cell, and cell carrier, we then need to figure out who to contact. 
  - The script looks at the "days" variable, specified by the user, which is the number of days in advance to send the reminder for.  It converts the date of the present date into a number, adds the "days" variable to that, and creates a "compare_date" variable. 
  - We then cycle through the structural array of participants, and convert each person's appointment date to a number, and then compare this number to the comparedate.  In the case that we have a  match (meaning that the participants appointment is indeed X (days) away, then we send the email. 
  - If the person has indicated that it's OK to text message them, and the script is set to send text reminders (determined by the sendtxt variable) then we also use the script send_text_messages to send the text reminders. 
  - Depending on whether we are doing the imaging or computer calendar, the email message varies in telling the participant the appointment type ("Imaging" or "Computer") and the location to meet the experimenter. 
  - We then record all participants contacted to LOG.txt, and exit matlab to prepare for the next script. 

So the rem_email.bat file can send out different combinations of reminder emails and texts simply by running this script multiple times with various configuations, as is done if you look at the batch code above.

### CONFIRMATION EMAIL
[confirmation_email.m](scripts/confirmation_email.m)
Takes in the following arguments: confirmation_email(contactemail)

This script works in the same basic manner as rem_email.m, except that it is hard coded to download the imaging and computer calendar, and then send out only reminder emails to subjects with appointments that were just created in the past 24 hours (new appointments that should be confirmed).  It figures out this detail by reading in the CREATED field from the calendar text files, which contains the date and time of when the event was created on the calendar. Output goes to CONFIRMATION_LOG.txt, and in case of error, the contactemail is notified.
  * **imaging.txt:**  Is a temporary file created in an ical format (saved as a text for easy readability) that contains all information from our imaging calendar on Gmail.  This file is created by the script (if it doesn't exist) and deleted at the end of the batch job by rem_email.bat
  * **computer.txt:**  Is the equivalent temporary file, but for the computer battery calendar.
  * **LOG.txt:**  Is an output log of all reminder emails and texts sent.  It is updated upon each script run.
  * **CONFIRMATION_LOG.txt:**  Is the equivalent log, but for the confirmation_email script.
  * **ERROR_LOG.txt** is written to in the case that the script cannot find the .csv file and exist with error
  * **REMINDER_AND_DIRECTIONS.pdf** is simply in this folder so the scripts can find it and attach it to all confirmation and reminder emails.

These are new scripts, of course, and should be checked regularly for successful runs, and in the case of error, troubleshooted!  In the long run I am hoping these will provide an easy and reliable toolset for sending reminder emails and text messages to participants, and doing away with missed appointments!
