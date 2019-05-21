# Qualtrics

## Overview
[Qualtrics](http://www.qualtrics.com) is a survey solution that is very powerful, easy to use, and very widely used amongst companies and research institutions.  It allows you to create surveys of just about every type with every sort of question / branching algorithm that you could imagine.  It allows for the manipulation and visualization of data within the browser, as well as custom export to your software of choice.  It even makes it easy to create surveys for mobile devices.  Qualtrics is the bomb diggity for administering surveys if you are at an institution with access!  The following notes pertain to the formatting of text files for importing questionnaires.

## Importing Surveys
Here are the formatting rules for importing a survey from a text file into Qualtrics.  I think that it is good practice to have some sort of data dictionary (such as in excel or your software of choice) that keeps track of question numbers, content, coding, and scoring.  A good practice would be to input each survey into your Data Dictionary, and then copy paste the questions into a plain .txt file, and formatting the file to the specifications below.


### Import Survey

There are two options for importing. 

  - .QSF - The Qualtrics Survey Format is a XML file, which is generated and exported when using the Export Survey feature. 
  - .TXT - This option can be created in Word, Notepad, or any word processor or text editor that can save as a Text file (.txt). 

The text file supports two different types of formatting: simple and advanced. 

#### Simple .TXT Format
Here are the basic instructions on how to set up the text file. 
  * A question begins with a number followed by a "." 
  * Choices are after the question text and a blank line 
  * Answers are after choices and a blank line 
  * Insert a page break by `[ [PageBreak] ]` (without the space between the brackets) 
  * Make question multiple answer by `[ [MultipleAnswer] ]` (without the space between the brackets) 

**Here is an example of a simple .txt formatted file**

```
1. This is a multiple choice question.  Every question starts with a 
number followed by a period. There should be a blank line between 
the question text and the choices. 

a 
b 
c 
d 

[[Block:My Block Name]]

2. This is a multiple choice multiple answer question. 

[[MultipleAnswer]]

a 
b 
c 
d 

[[PageBreak]]

3. This is a matrix question that has longer question text. 

It is a matrix question because it has two groups of choices. 
The question text is on two lines. 

ma 
mb 
mc 

m1 
m2 
m3 

4. This is a matrix multiple answer question. 

[[MultipleAnswer]]

ma 
mb 
mc 

m1 
m2 
m3 

[[Block]]

5. What is your gender? 
this is a test. 
How are you? 

Male 
Female 
```

#### Advanced .TXT Format
When using the advanced text format each part of the question must be explicitly defined using the `[[<tag>]]` tags. The tags begin with `[["` and end with `"]]` with no spaces in-between the brackets. 

The file must begin with the `[[AdvancedFormat]]` tag 

  * A question begins with `[[Question:<question type>]]` tag 
    * `<question type>` can be any one of the following: MC, Matrix, TE, CS, RO, DB 
  * Choices start with `[[Choices]]` tag and are one per line afterwards 
  * Answers start with `[[Answers]]` tag and are one per line afterwards 
  * Make question multiple answer by `[[MultipleAnswer]]`
  * Sets the id of the question (shown as the export tag after import) with `[[ID:<question id>]]` 
  * Insert a page break by `[[PageBreak]]` 
  * Insert a block by `[[Block]]` or `[[Block:<block name>]]` where `<block name>` is the name of the block.

Here is an example of an advanced .txt formatted file. 

```
[[AdvancedFormat]]`

[[Question:MC]]
[[ID:q1]]
This is a multiple choice question. 

[[Choices]]
a 
b 
c 
d 

[[Question:MC:MultipleAnswer]]
[[ID:q2]]

This is a multiple choice question multiple answer question. 

[[Choices]]
a 
b 
c 
d 

[[PageBreak]]

[[Question:Matrix]]
This question is a matrix question. 

It has lots of question text on multiple lines. 

[[Choices]]
ma 
mb 
mc 

[[Answers]]
m1 
m2 
m3 

[[Question:Matrix]]
[[MultipleAnswer]] 
This question is a matrix multiple answer question. 

It has lots of question text on multiple lines. 

[[Choices]]
ma 
mb 
mc 

[[Answers]] 
m1 
m2 
m3 
```

Here is a list of available tags for the advanced formatted file 
  * `[[AdvancedFormat]]` - specifies the file is an advanced formatted file. 
  * `[[SimpleFormat]]` - specifies the file is a simple formatted file. 
  * `[[Question:<question type>]]` - specifies a question with a specific type.  
  * `<question type>` is one of the following: MC, Matrix, TE, CS, RO, DB. 
  * `[[Choices]]` - specifies the choices for a question (one per line after the tag). 
  * `[[Answers]]` - specifies the answers for a question (one per line after the tag). 
  * `[[MultipleAnswers]]` - specifies that the question should be a multiple answer question. 
  * `[[ID:<question id>]]` - specifies question id and export tag. 
  * `[[PageBreak]]` - specifies a page break. 
  * `[[Block]]` - specifies a block should begin. 
  * `[[Block:<block name>]]` - specifies a block should begin with a specific name. 
