source Process_Base.sh

# process a gedcom file from FamilyTreeMaker with Gramps

if [ $(id -u) = "0" ]; then
	echo "superuser used"
	# ensure the right directory is mapped (mount -t vboxsf [Name in vbox mount] [path in linux]
	mount -t vboxsf Family_Tree_Maker ~/share/
fi

if [ $(id -u) != "0" ]; then
	echo "use sudo to create mount"
fi

echo "--------------------"

# Path to GEDCOM
gedcomFile=Carnell_2017-12-20.ged
gedcomPath=~/share

# Ancestor ID numbers from Gramps
Rettgers=I0115
Hartenstine=I0116
Fett=I0156
Bechtel=I0157
Connell=I0075
Langston=I0076
Smith=I0022
Josey=I0023

# Gramps Version and path
GrampsVersion=.
GrampsPath=~/Documents/repositories/gramps
GrampsCommand="python3 $GrampsPath/Gramps.py"

# -y Don't ask to confirm dangerous actions
# -q Suppress progress indication output
# -i import
# -a action
# -p options for the action
#    use this to get the action options
#    $GrampsCommand $GrampsOptionsStart "name=det_ancestor_report,show=all"
#    pageben = page break before endnotes
#    date_format = 0 (YYY-MM-DD), 1 (MM-DD-YY), 2 (Month Day, Year), 3 (MON DAY, YEAR), 4 (Day Month Year", 5 (DAY MON YEAR)
#    listc = list children
#    listc_spouses = list spouses of children
#    fulldates = use full dates
#    desref
#    incnotes = include notes
#    incattrs = include attributes
#    incphotos = include photos
#    off=output format
#    of = output file

GrampsOptionsStart="-y -q -i $gedcomPath/$gedcomFile -a report -p"
GrampsOptionsReport="name=det_ancestor_report,pageben=True,date_format=5,listc=True,listc_spouses=True,fulldates=True,desref=True,incnotes=False,incattrs=False,incphotos=False,off=tex,of=$outputPath/tex_input/det_ancestor_report_"

$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Bechtel.tex,pid=$Bechtel
#$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Connell.tex,pid=$Connell
#$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Fett.tex,pid=$Fett
#$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Hartenstine.tex,pid=$Hartenstine
#$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Josey.tex,pid=$Josey
#$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Langston.tex,pid=$Langston
#$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Rettgers.tex,pid=$Rettgers
#$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Smith.tex,pid=$Smith

# Process with R
#R -f $outputPath/src/Modify_Gramps_Output.R

# Process with tex
#if [ ! -d "$outputPath/pdf_output" ]; then
#	mkdir $outputPath/pdf_output
#fi
#latexCommand="latex -output-directory=$outputPath/pdf_output -output-format=pdf"
#$latexCommand tex_input/Volume1.tex
#$latexCommand tex_input/Volume2.tex
#$latexCommand tex_input/Volume3.tex
#$latexCommand tex_input/Volume4.tex
#$latexCommand tex_input/Volume5.tex


