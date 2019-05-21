```python
#!/usr/bin/env python
import sys,os,time,re,datetime,smtplib

#------VOX_MATRIX.py---------------------------
#
# This script is used for creating matrices from SPM preprocessed data
# with a mask
#

#########user section#########################
#user specific constants
username = "abc1"                               #your cluster login name (use what shows up in qstatall)
useremail = "email@place.com"                 #email to send job notices to
template_f = file("vox_matrix_TEMPLATE.sh")      #job template location (on head node)
experiment = "NAME.01"                           #experiment name for qsub
nodes = 24                                      #number of nodes on cluster
maintain_n_jobs = 25                            #leave one in q to keep them moving through
min_jobs = 5                                    #minimum number of jobs to keep in q even when crowded
n_fake_jobs = 10                                #during business hours, pretend there are extra jobs to try and leave a few spots open
sleep_time = 20                                 #pause time (sec) between job count checks
max_run_time = 720                              #maximum time any job is allowed to run in minutes
max_run_hours=24	                        #maximum number of hours submission script can run
warning_time=18                                 #send out a warning after this many hours informing you that the deamon is still running
                                                #make job files  these are the lists to be traversed
                                                #all iterated items must be in "[ ]" separated by commas.
#experiment variables 
subnums = ["123","234","234"] #should be entered in quotes, separated by commas, to be used as strings
runs = [1]               #[ run01 ] range cuts the last number off any single runs should still be in [ ] or can be runs=range(1,2)
spm = "SPM2"                    #spm version used to create preprocessed swu/swrf images (SPM2,SPM5,SPM8)
task = "Faces"                 #functional task (Faces, Cards, Rest)
outputname = "Grey_Matter_Mask" #The folder for output under Analysis/Matrices - must already exist!
imgprefix = "swrf"              #The image prefix of the preprocessed images (swrf or swu)
numimages = "195"               #This is the number of timepoints for the functional task

#Mask 1
masktype = "Standard"           #folder that contains mask under Analysis/ROI/Masks
maskfile = "rgray_SPM2.img"     #full name of the mask in the folder above
threshold = "0.12"              #This is the minimum threshold value for the mask

#Mask 2
twomasks = "yes"                #Specify "yes" if you have a second mask, "no" if not
masktwotype = "Standard"        #folder that contains mask under Analysis/ROI/Masks (blank if none)
masktwofile = "FIGSgr_108.img"  #full name of the mask in the folder above (blank if none)
thresholdtwo = "1"              #This is the minimum threshold value for the mask (blank if none)
####!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!###############################################
 
def daemonize(stdin='/dev/null',stdout='/dev/null',stderr='/dev/null'):
	try:
		#try first fork
		pid=os.fork()
		if pid>0:
			sys.exit(0)
	except OSError, e:
		sys.stderr.write("for #1 failed: (%d) %s\n" % (e.errno,e.strerror))
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
			sys.stderr.write("for #2 failed: (%d) %s\n" % (e.errno, e.strerror))
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
log.write('Daemon started at %s with pid %d\n' %(t0,os.getpid()))
log.write('To kill this process type "kill %s" at the head node command line\n' % os.getpid())
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
	status = os.popen("status -a")
	status_list = status.readlines()
 
	for line in status_list:
		#are these active or q'd jobs?
		if (line.find("Running") > -1):
			running = 1
		elif (line.find("Waiting") > -1):   #all following jobs are in queue not running
			running = 0
 
		#if job is mine
		if (line.find(username) > 0) & (line.find("interact.q") < 0):   #name is in the line, not including first spot
			n_jobs = n_jobs + 1
			if running == 1:   #if active job, check how long its been running and delete it if too long
				job_info = line.split()  #get job information
				start_date = job_info[4].split("/")  #split job start date
				start_time = job_info[5].split(":")  #split time from hours:minutes:seconds format
				started = datetime.datetime(int(start_date[2]), int(start_date[0]), int(start_date[1]),
							int(start_time[0]), int(start_time[1]), int(start_time[2]))
				if ((cur_time - started) > kill_time_limit) & (line.find("stalled") == -1):   #if the active job is over max run time, delete it
					os.system("qdel %s" % (job_info[0]))   #delete the run away job
					print("Job %s was deleted because it ran for more than the maximum time." % (job_info[0]))
 
		# if line starts " ###" and isnt an interactive job
		elif bool(re.match( "^\d+", line )) & (line.find("interact") < 0) & (line.find("(Error)") < 0):
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
		tmp_job_file = tmp_job_file.replace( "SUB_RUNNUM_SUB", str(run) )
		tmp_job_file = tmp_job_file.replace( "SUB_SPMVER_SUB", str(spm) )
 		tmp_job_file = tmp_job_file.replace( "SUB_TASKNAME_SUB", str(task) )
		tmp_job_file = tmp_job_file.replace( "SUB_MTYPE_SUB", str(masktype) )
		tmp_job_file = tmp_job_file.replace( "SUB_MASKFILE_SUB", str(maskfile) )
 		tmp_job_file = tmp_job_file.replace( "SUB_IMGPRE_SUB", str(imgprefix) )
		tmp_job_file = tmp_job_file.replace( "SUB_OUTPUTFOL_SUB", str(outputname) )
		tmp_job_file = tmp_job_file.replace( "SUB_NUM_IMAGES_SUB", str(numimages) )
		tmp_job_file = tmp_job_file.replace( "SUB_THRESHOLD_SUB", str(threshold) )
		tmp_job_file = tmp_job_file.replace( "SUB_YESTWOMASK_SUB", str(twomasks) )
		tmp_job_file = tmp_job_file.replace( "SUB_MTWOTYPE_SUB", str(masktwotype) )
		tmp_job_file = tmp_job_file.replace( "SUB_MASKTWOFILE_SUB", str(masktwofile) )
		tmp_job_file = tmp_job_file.replace( "SUB_THRESHOLDTWO_SUB", str(thresholdtwo) )
 		
				 
		#make fname and write job file to cwd
		tmp_job_fname = "_".join( ["MATRIX", subnum, runstr ] )
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
 
	#Check what how long daemon has been running
	t1=time.time()
	hour=(t1-t0)/3600
	log=file(log_name,'a+')
	log.write('Daemon has been running for %s hours\n' % hour)
	log.close()
	now_hr=time.localtime()[3]
	if now_hr>prev_hr:
		master_clock=master_clock+1
	prev_hr=now_hr
	serverURL="email.biac.duke.edu"
	if master_clock==warning_time:
		headers="From: %s\r\nTo: %s\r\nSubject: Daemon job still running!\r\n\r\n" % (useremail,useremail)
		text="""Your daemon job has been running for %d hours.  It will be killed after %d.
		To kill it now, log onto the head node and type kill %d""" % (warning_time,max_run_hours,os.getpid())
		message=headers+text
		mailServer=smtplib.SMTP(serverURL)
		mailServer.sendmail(useremail,useremail,message)
		mailServer.quit()
	elif master_clock==max_run_hours:
		headers="From: %s\r\nTo: %s\r\nSubject: Daemon job killed!\r\n\r\n" % (useremail,useremail)
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
