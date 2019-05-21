I’ve had this need multiple times, so I’ve written a quick matlab script that will allow you to to dump the contents of an excel file into a MySQL database.  The call on command line should be as follows:

```matlab
xls_to_sql(input,sheet,outfile,database,table)
```

With the following variables defined as:

  - input: the full name of the input excel file —–’myfile.xls’ or ‘myfile.xlsx’
  - sheet: the name of the sheet to read from —– ‘Sheet1′
  - outfile: the name of your output file, which will be .txt by default
  - database: the full name of your database, usually something like ‘mysitecom_databasename’
  - table: the full name of the table —– ‘mytable’

The first row of the excel file, your column headers, are expected to be the corresponding field names, already created in your database.  You should be able to open the output text file and copy the code into the “SQL’ tab under phpMyAdmin.  In the case of an empty cell, this will be read as NaN, and the script checks for those, and prints an empty entry when it finds one.  The script was tested for simple string and numerical entities, entered into a database with standard INT, VARCHAR (255), and DOUBLE data types.  I’m sure there are some awkward types that you would want to translate from excel into a strangely formatted SQL command that the script can’t handle.  Feel free to modify as needed!

```matlab
function xls_to_sql(input,sheet,outfile,database,table)
 
% This script reads in an excel sheet and converts it into sql insert
% statements.  The first row is expected to be the titles for the tables,
% followed by rows of raw data.
%-------------------------------------------------------------------------
% INPUT
% input    ----- input excel file should be excel file, .xls or .xlsx
% sheet    ----- name of sheet to read from
% outfile  ----- name of output file (without extension)
% database ----- name of database to print to
% table    ----- name of table to print to
 
% Read in file with raw gm,wm,fa data
[~,~,DATA] = xlsread(input,sheet);
 
% Open file for writing
fid = fopen([ outfile '.txt' ],'w');
 
% Print the insert command
for i = 2:size(DATA,1)
    fprintf(fid,'%s%s%s%s%s','INSERT INTO  `',database,'`.`',table','` (');
 
    % Print the field names (the first row in the excel file)
    for t = 1:(size(DATA,2)-1); fprintf(fid,'%s','`',DATA{1,t},'`, '); end
    fprintf(fid,'%s%s%s\n','`',DATA{1,(size(DATA,2))},'`)');
    fprintf(fid,'%s\n','VALUES (');
     
    % Print the data values, and base the format string on the data type
    for j = 1:(size(DATA,2)-1); 
        if ~ischar(DATA{i,j}); 
            if ~isnan(DATA{i,j}); fprintf(fid,'%s%g%s','''',DATA{i,j},''', ');
            else  fprintf(fid,'%s',''''', '); end
        else fprintf(fid,'%s','''',DATA{i,j},''', '); end
    end
     
    % Print the last field followed by a ')' and a newline
    if ~ischar(DATA{i,j}); 
        if ~isnan(DATA{i,j}); fprintf(fid,'%s%g%s\n\n','''',DATA{i,(size(DATA,2)-1)},''');');
        else fprintf(fid,'%s\n\n',''''');'); end
    else fprintf(fid,'%s\n\n','''',DATA{i,(size(DATA,2))},''');'); end
     
end
 
% Close file for writing
fclose(fid);
 
end
```
