# Dicom2Nifti Multiple Subjects

To run multiple subjects at once, we can use a python script with a .sh TEMPLATE.  You simply must fill in the correct variables at the top of dicom2nifti.py, and then it will submit multiple iterations of dicom2nifti_TEMPLATE.sh.  Be sure that the scripts are located under the same directory.  Many thanks to McKell Carter for introducing me to python and for backbone of all our python submission scripts!
  * To submit: 
```
python dicom2nifti.py 
```

## dicom2nifti.py

```python
#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

#------dicom2nifti.py---------------------------
#
# This script is used for converting dicom to nifti and correcting orientation for FSL.
# it works with dicom2nifti_TEMPLATE.sh to run multiple subjects
#

#########user section#########################
#user specific constants
username = "abc1"             #your cluster login name (use what shows up in qstatall)
useremail = "use@email.com"    #email to send job notices to
template_f = file("dicom2nifti_TEMPLATE.sh")  #job template location (on head node)
experiment = "NAME.01"    #experiment name for qsub
nodes = 400                   #number of nodes on cluster
maintain_n_jobs = 100         #leave one in q to keep them moving through
min_jobs = 5                 #minimum number of jobs to keep in q even when crowded
n_fake_jobs = 50               #during business hours, pretend there are extra jobs to try and leave a few spots open
sleep_time = 20              #pause time (sec) between job count checks
max_run_time = 720           #maximum time any job is allowed to run in minutes
max_run_hours=24	#maximum number of hours submission script can run
warning_time=18         #send out a warning after this many hours informing you that the deamon is still running
#make job files  these are the lists to be traversed
#all iterated items must be in "[ ]" separated by commas.  
subnums = [""] #should be entered in quotes, separated by commas, to be used as strings
runs = [1] #[ run01 ] range cuts the last number off any single runs should still be in [ ] or can be runs=range(1,2)
typevar = "Anat" #this is either going to be Anat or Func
folder = "series005" #this is the name of the folder to convert
outpre = "Anat" #this is the name that you want for the output
####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###############################################
 
def daemonize(stdin='/dev/null',stdout='/dev/null',stderr='/dev/null'):
	try:
		#try first fork
		pid=os.fork()
		if pid>0:
			sys.exit(0)
	except OSError, e:
		sys.stderr.write("for #1 failed: (%d) %sn" % (e.errno,e.strerror))
		sys.exit(1)
	os.chdir("/")
	os.umask(0)
	os.setsid()
	try:
		#try second fork
		pid=os.fork()
		if pid>0:
			sys.exit(0)
	except OSError, e:
			sys.stderr.write("for #2 failed: (%d) %sn" % (e.errno, e.strerror))
			sys.exit(1)
	for f in sys.stdout, sys.stderr: f.flush()
	si=file(stdin,'r')
	so=file(stdout,'a+')
	se=file(stderr,'a+',0)
	os.dup2(si.fileno(),sys.stdin.fileno())
	os.dup2(so.fileno(),sys.stdout.fileno())
	os.dup2(se.fileno(),sys.stderr.fileno())
	
 
 
start_dir = os.getcwd()
 
daemonize('/dev/null',os.path.join(start_dir,'daemon.log'),os.path.join(start_dir,'daemon.log'))
sys.stdout.close()
os.chdir(start_dir)
temp=time.localtime()
hour,minute,second=temp[3],temp[4],temp[5]
prev_hr=temp[3]
t0=str(hour)+':'+str(minute)+':'+str(second)
log_name=os.path.join(start_dir,'daemon.log')
log=file(log_name,'w')
log.write('Daemon started at %s with pid %dn' %(t0,os.getpid()))
log.write('To kill this process type "kill %s" at the head node command linen' % os.getpid())
log.close()
t0=time.time()
master_clock=0
 
#build allowed timedelta
kill_time_limit = datetime.timedelta(minutes=max_run_time)
 
 
def _check_jobs(username, kill_time_limit, n_fake_jobs):
#careful, looks like all vars are global
#see how many jobs we have  in
 
	#set number of jobs to maintain based on time of day.
	cur_time = datetime.datetime.now() #get current time  #time.localtime()  #get current time
	if (cur_time.weekday > 4) | (cur_time.hour < 8) | (cur_time.hour > 17):
		n_other_jobs = 0
	else: #its a weekday, fake an extra 6 jobs to leave 5 nodes open
		n_other_jobs = n_fake_jobs
 
	n_jobs = 0
        status = os.popen("qstat  -u '*'")
	status_list = status.readlines()
 
	for line in status_list:
		#are these active or q'd jobs?
		if (line.find(" r") > -1):
			running = 1
		elif (line.find(" qw") > -1):   #all following jobs are in queue not running
			running = 0
 
		#if job is mine
		if (line.find(username) > 0) & (line.find("interact.q") < 0):   #name is in the line, not including first spot
			n_jobs = n_jobs + 1
			if running == 1:   #if active job, check how long its been running and delete it if too long
				job_info = line.split()  #get job information
				start_date = job_info[5].split("/")  #split job start date
				start_time = job_info[6].split(":")  #split time from hours:minutes:seconds format
				started = datetime.datetime(int(start_date[2]), int(start_date[0]), int(start_date[1]),
							int(start_time[0]), int(start_time[1]), int(start_time[2]))
				if ((cur_time - started) > kill_time_limit) & (line.find("stalled") == -1):   #if the active job is over max run time, delete it
					os.system("qdel %s" % (job_info[0]))   #delete the run away job
					print("Job %s was deleted because it ran for more than the maximum time." % (job_info[0]))
 
		# if line starts " ###" and isnt an interactive job
		elif bool(re.match( "^d+", line )) & (line.find("interact") < 0) & (line.find("(Error)") < 0):
			n_other_jobs = n_other_jobs + 1
	return n_jobs, n_other_jobs
		
#make a directory to write job files to and store the start directory
tmp_dir = str(os.getpid())
os.mkdir(tmp_dir)
 
#read in template
template = template_f.read()
template_f.close()
os.chdir(tmp_dir)
 
#for each subject
for subnum in subnums:
	#for each run
	for run in runs:
		
		#Check for changes in user settings
		user_settings=("/home/%s/user_settings.txt") % (username)
		if os.path.isfile(user_settings):
			f=file(user_settings)
			settings=f.readlines()
			f.close()
			for line in settings:
				exec(line)
 
		#define substitutions, make them in template 
		runstr = "%05d" %(run)  
		tmp_job_file = template.replace( "SUB_USEREMAIL_SUB", useremail )
		tmp_job_file = tmp_job_file.replace( "SUB_SUBNUM_SUB", str(subnum) )
		tmp_job_file = tmp_job_file.replace( "SUB_TYPEVAR_SUB", str(typevar) )
 		tmp_job_file = tmp_job_file.replace( "SUB_FOLDER_SUB", str(folder) )
 		tmp_job_file = tmp_job_file.replace( "SUB_OUTPRE_SUB", str(outpre) )
 
		#make fname and write job file to cwd
		tmp_job_fname = "_".join( ["DICOM_NIFTI", subnum, runstr ] )
		tmp_job_fname = ".".join( [ tmp_job_fname, "job" ] )
		tmp_job_f = file( tmp_job_fname, "w" )
		tmp_job_f.write(tmp_job_file)
		tmp_job_f.close()
 
 
		#wait to submit the job until we have fewer than maintain in q
		n_jobs = maintain_n_jobs
		while n_jobs >= maintain_n_jobs: 
 
			#count jobs
			n_jobs, n_other_jobs = _check_jobs(username, kill_time_limit, n_fake_jobs)   #count jobs, delete jobs that are too old
 
			#adjust job submission by how may jobs are submitted
			#set to minimum number if all nodes are occupied
			#should still try to leave # open on weekdays
			if ((n_other_jobs+ n_jobs) > (nodes+1)): 
				n_jobs = maintain_n_jobs  - (min_jobs - n_jobs)
 
			if n_jobs >= maintain_n_jobs: 
				time.sleep(sleep_time)
			elif n_jobs < maintain_n_jobs:
				cmd = "qsub -v EXPERIMENT=%s %s"  % ( experiment, tmp_job_fname )
				dummy, f = os.popen2(cmd)
				time.sleep(sleep_time)
 
	#Check what how long daemon has been running
	t1=time.time()
	hour=(t1-t0)/3600
	log=file(log_name,'a+')
	log.write('Daemon has been running for %s hoursn' % hour)
	log.close()
	now_hr=time.localtime()[3]
	if now_hr>prev_hr:
		master_clock=master_clock+1
	prev_hr=now_hr
	serverURL="email.biac.duke.edu"
	if master_clock==warning_time:
		headers="From: %srnTo: %srnSubject: Daemon job still running!rnrn" % (useremail,useremail)
		text="""Your daemon job has been running for %d hours.  It will be killed after %d.
		To kill it now, log onto the head node and type kill %d""" % (warning_time,max_run_hours,os.getpid())
		message=headers+text
		mailServer=smtplib.SMTP(serverURL)
		mailServer.sendmail(useremail,useremail,message)
		mailServer.quit()
	elif master_clock==max_run_hours:
		headers="From: %srnTo: %srnSubject: Daemon job killed!rnrn" % (useremail,useremail)
		text="Your daemon job has been killed.  It has run for the maximum time alotted"
		message=headers+text
		mailServer=smtplib.SMTP(serverURL)
		mailServer.sendmail(useremail,useremail,message)
		mailServer.quit()
		ID=os.getpid()
		os.system('kill '+str(ID))
 
 
 
#wait for jobs to complete
#delete them if they run too long
n_jobs = 1
while n_jobs > 0:
	n_jobs, n_other_jobs = _check_jobs(username, kill_time_limit, n_fake_jobs)
	time.sleep(sleep_time)
 
 
#remove tmp job files move to start dir and delete tmpdir
#terminated jobs will prevent this from executing
#you will then have to clean up a "#####" directory with
# ".job" files written in it.
cmd = "rm *.job"
os.system(cmd)
os.chdir(start_dir)
os.rmdir(tmp_dir)
``` 


=====dicom2nifti_TEMPLATE.sh=====
```
#!/bin/sh

# -------- DICOM 2 NIFTI TEMPLATE ---------

# This script is intended for converting raw dicom images into a 4D nifti file
# through use of the bxhtools and bxh header provided by BIAC
# This script is run with a python script, dicom2nifti.py

# There are 2 USER sections 
#  1. USER DIRECTIVE: If you want mail notifications when
#     your job is completed or fails you need to set the 
#     correct email address.
#		   
#  2. USER SCRIPT: Add the user script in this section.
#     Within this section you can access your experiment 
#     folder using $EXPERIMENT. All paths are relative to this variable
#     eg: $EXPERIMENT/Data $EXPERIMENT/Analysis	
#     By default all terminal output is routed to the " Analysis "
#     folder under the Experiment directory i.e. $EXPERIMENT/Analysis
#     To change this path, set the OUTDIR variable in this section
#     to another location under your experiment folder
#     eg: OUTDIR=$EXPERIMENT/Analysis/GridOut 	
#     By default on successful completion the job will return 0
#     If you need to set another return code, set the RETURNCODE
#     variable in this section. To avoid conflict with system return 
#     codes, set a RETURNCODE higher than 100.
#     eg: RETURNCODE=110
#     Arguments to the USER SCRIPT are accessible in the usual fashion
#     eg:  $1 $2 $3
# The remaining sections are setup related and don't require
# modifications for most scripts. They are critical for access
# to your data  	 
 
# --- BEGIN GLOBAL DIRECTIVE -- 
#$ -S /bin/sh
#$ -o $HOME/$JOB_NAME.$JOB_ID.out
#$ -e $HOME/$JOB_NAME.$JOB_ID.out
#$ -m ea
# -- END GLOBAL DIRECTIVE -- 
 
# -- BEGIN PRE-USER --
#Name of experiment whose data you want to access 
EXPERIMENT=${EXPERIMENT:?"Experiment not provided"}
 
source /etc/biac_sge.sh
 
EXPERIMENT=`biacmount $EXPERIMENT`
EXPERIMENT=${EXPERIMENT:?"Returned NULL Experiment"}
 
if [ $EXPERIMENT = "ERROR" ]
then
	exit 32
else 
#Timestamp
echo "----JOB [$JOB_NAME.$JOB_ID] START [`date`] on HOST [$HOSTNAME]----" 
# -- END PRE-USER --
# **********************************************************
 
# -- BEGIN USER DIRECTIVE --
# Send notifications to the following address
#$ -M SUB_USEREMAIL_SUB
 
# -- END USER DIRECTIVE --
 
# -- BEGIN USER SCRIPT --
# User script goes here

# --- LONG VARIABLE DEFINITIONS ---

TYPE=SUB_TYPEVAR_SUB     # this is either going to be "Anat" or "Func"
FOLDER=SUB_FOLDER_SUB   # this is the series folder name
OUTPRE=SUB_OUTPRE_SUB   # this is the name you want for the resulting nifti
SUBJECT=SUB_SUBNUM_SUB  # this is the subject ID

OUTDIR=$EXPERIMENT/Data/$TYPE/$SUBJECT/$FOLDER/
 
# ------- LONG SCRIPT ------------------

cd $OUTDIR
# here we navigate to the folder with the dicoms to run the command

bxhreorient --orientation=LAS $FOLDER.bxh LAS.bxh
# here we are changing the orientation from LPS to LAS, (TO Radiological) for use in FSL

OUTPUT=$OUTPRE"_LAS"
# Here we are appending "LAS" to the name of the output so that the orientation is clear   
                    
bxh2analyze --nii -b LAS.bxh $OUTPUT
# -nii indicates that we want an uncompressed nifti
# -b suppresses the output of a second bxh file 
 
 
# -- END USER SCRIPT -- #
 
# **********************************************************
# -- BEGIN POST-USER -- 
echo "----JOB [$JOB_NAME.$JOB_ID] STOP [`date`]----" 
OUTDIR=${OUTDIR:-$EXPERIMENT/Analysis}
mv $HOME/$JOB_NAME.$JOB_ID.out $OUTDIR/$JOB_NAME.$JOB_ID.out	 
RETURNCODE=${RETURNCODE:-0}
exit $RETURNCODE
fi
# -- END POST USER-- 
```
