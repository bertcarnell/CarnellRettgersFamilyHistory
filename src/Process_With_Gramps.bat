:: process a gedcom file from FamilyTreeMaker with Gramps

:: Path to GEDCOM
set gedcomFile=Carnell_2017-03-18.ged
set gedcomPath="s:\Family Tree Maker"

:: output path
set outputPath=c:\Users\Rob\Documents\Repositories\CarnellRettgersFamilyHistory

:: Ancestor ID numbers from Gramps
set Rettgers=I0115
set Hartenstine=I0116
set Fett=I0156
set Bechtel=I0157
set Connell=I0075
set Langston=I0076
set Smith=I0022
set Josey=I0023

:: Gramps Version and path
set GrampsVersion=GrampsAIO64-4.2.4
set GrampsPath="C:\Program Files\%GrampsVersion%\bin"
set GrampsCommand=%GrampsPath%\gramps.exe

set GrampsOptionsStart=-y -q -i %gedcomPath%\%gedcomFile% -a report -p
set GrampsOptionsReport=name=det_ancestor_report,off=tex,of=%outputPath%\tex_input\det_ancestor_report_

cd %GrampsPath%

%GrampsCommand% %GrampsOptionsStart% "%GrampsOptionsReport%Bechtel.tex,pid=%Bechtel%"
%GrampsCommand% %GrampsOptionsStart% "%GrampsOptionsReport%Connell.tex,pid=%Connell%"
%GrampsCommand% %GrampsOptionsStart% "%GrampsOptionsReport%Fett.tex,pid=%Fett%"
%GrampsCommand% %GrampsOptionsStart% "%GrampsOptionsReport%Hartenstine.tex,pid=%Hartenstine%"
%GrampsCommand% %GrampsOptionsStart% "%GrampsOptionsReport%Josey.tex,pid=%Josey%"
%GrampsCommand% %GrampsOptionsStart% "%GrampsOptionsReport%Langston.tex,pid=%Langston%"
%GrampsCommand% %GrampsOptionsStart% "%GrampsOptionsReport%Rettgers.tex,pid=%Rettgers%"
%GrampsCommand% %GrampsOptionsStart% "%GrampsOptionsReport%Smith.tex,pid=%Smith%"

cd %outputPath%\src
