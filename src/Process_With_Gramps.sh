# process a gedcom file from FamilyTreeMaker with Gramps

if [ $(id -u) = "0" ]; then
	echo "superuser used"
	# ensure the right directory is mapped (mount -t vboxsf [Name in vbox mount] [path in linux]
	mount -t vboxsf Downloads ~/share/
fi

if [ $(id -u) != "0" ]; then
	echo "use sudo to create mount"
fi

echo "--------------------"

# Path to GEDCOM
gedcomFile=Carnell_2017-05-13_01.ged
gedcomPath=~/share

# output path
outputPath=~/Documents/repositories/CarnellRettgersFamilyHistory

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
GrampsPath=~/Documents/repositories/Gramps
GrampsCommand="python3 $GrampsPath/Gramps.py"

GrampsOptionsStart="-y -q -i $gedcomPath/$gedcomFile -a report -p"
GrampsOptionsReport="name=det_ancestor_report,listc=True,listc_spouses=True,fulldates=True,desref=True,incnotes=False,incattrs=False,incphotos=False,off=tex,of=$outputPath/tex_input/det_ancestor_report_"

$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Bechtel.tex,pid=$Bechtel,initial_sosa=1000
$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Connell.tex,pid=$Connell
$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Fett.tex,pid=$Fett
$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Hartenstine.tex,pid=$Hartenstine
$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Josey.tex,pid=$Josey
$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Langston.tex,pid=$Langston
$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Rettgers.tex,pid=$Rettgers
$GrampsCommand $GrampsOptionsStart "$GrampsOptionsReport"Smith.tex,pid=$Smith

