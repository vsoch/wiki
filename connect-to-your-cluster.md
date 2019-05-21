# Connect to your Cluster

 1. Download the F-Secure Shell (SSH) Client, or your free SSH client of choice. [Putty](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) is a good option!
 2. Log into your server with the correct username and password. The hostname should be something like "server.name.domain" and then you should have a username and password.
 3.  When you first log in, if you have just set up your account and want to change your password.  Type "passwd" to do so.  It will prompt you for your old password, and then a new one.  NOTE: When you are typing your password, it will NOT appear in the terminal, but it's there!  Keep typing and press enter.
 4. You're in!  In order for fsl and xterm to display properly, you need to set up the display.  You need to install win-32 (or whatever software that you choose to provide X11 tunneling) to handle the display. 
 5. For X-win 32 - run X-win 32 Configuration. Go to the security tab, click "Add" --> type in "localhost" and click OK
 6. Close the X-Config and run X-Win 32. An icon in the quick launch toolbar should tell you that it's running, and you should see the ugliest graphic known to man pop up on your screen.
 7. Back in the F Secure Shell Click on Edit --> Settings, and then Choose "Tunneling" from the menu on the left. Make sure the box that says "Tunnel X11 Connections" is checked. This makes the display work! If you are currently in a session, restart it.
 8. You can always type "xterm" to open up a terminal window.  You can use nedit / gedit / vi to edit files, and the follow commands for basic navigation:

<code bash>
# Go to a directory called directory
cd directory

# Go up a level
cd ..

# make a folder
mkdir name

# delete a file
rm *

# delete a directory
rmdir

# list files 
ls
# list files in one row
ls -1
</code>

You can also press the up and down arrows to cycle through previously used commands, and TAB to autocomplete.  You should browse around and get comfortable with command line stuff before you delve into anything huge, and I promise that you will get better with practice! Talk to whomever manages your cluster environment for information about connecting to nodes, data, and submitting jobs.
