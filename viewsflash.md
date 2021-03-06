# ViewsFlash

## Overview

[ViewsFlash](http://www.cogix.com/Home.html) is a survey solution provided by Cogix that used to be provided at Duke for survey administration.  ViewsFlash was replaced by [Qualtrics](qualtrics.md), a far better solution, however I would like to include documentation about ViewsFlash for anyone looking for it!

## Invite Lists
You can create a custom "invite list" of participants that are allowed to take your surveys by doing the following:
  * Log into the system.  At Duke we did this through a web portal, and I assume that your institutions login is custom to how/where it is installed.
  * Each set of surveys is associated with a "Polling Place," and each of these Polling Places can have questionnaires prepared to be connected with an invite list.

**To prepare a questionnaire for administering to participants**
  * go to Settings --> Security, and 
  * under 1) User Authentication: Choose an authentication method, pick option "Form"
  * under 2) Handling multiple entries: check the box "Using User Authentication, reject multiple responses"
  * also check the box that says "Questionnaire must use SSL (https://)"
  * under Save, make sure to check the box that says "Authenticated user ID specified in Security " to save the user ID in each survey
  * Click Submit to save for each section! (at the bottom)
  * Now we need to specify the study invite list is associated with the particular survey.  Click on "Invite" directly under "Security" and choose the appropriate Invite list that you created for the study.  This means that multiple assessments in your polling place will be associated with one invite list.
  * Also make sure to create a "Results" page for each survey that tells the user that the survey is complete, and he/she can close the browser window.

## Branching for YES/NO Questions
If you want to jump around depending on the response that a user provides, you must put a page break directly after the question, and the Script box should read "Script when=after" - this means that the code is executed after the user has filled in his/her choice and pressed "Next"

For the actual script content, you DON'T want to write

```
if (A2a == "NO"){
gotoquestion("B");
} 
```

A boolean statement expects an integer, and "NO" is a string.  

The code that we want to use for all the boolean statements is as follows:

```
if (isin (A1a, "NO")) { 
gotoquestion("B"); 
} 
```

the "isin" method basically looks at the specified question, the first argument, (A1a in this case) and is true if the string "NO" is listed as an answer. 

For more details refer to the code and where it says "Action, such as scripts" click on "Explain" next to it.  If you scroll down to "Utility Functions" it gives all the nitty gritty details.  The notes above were written in late 2009, and could very likely no longer be applicable, if Cogix has improved or changed their software!
