# output path
#   Note:  OUTPUT_PATH cannot use ~/, it must use /home/carnellr to work with python3 open()
OUTPUT_PATH=/home/carnellr/Documents/repositories/CarnellRettgersFamilyHistory

# Path to GEDCOM
GEDCOM_FILE=Carnell_2017-12-20.ged
GEDCOM_PATH=~/share
VBOXSF_NAME=Family_Tree_Maker

# Ancestor ID numbers from Gramps
RETTGERS=I0115
HARTENSTINE=I0116
FETT=I0156
BECHTEL=I0157
CONNELL=I0075
LANGSTON=I0076
SMITH=I0022
JOSEY=I0023

# Gramps
GRAMPS_COMMAND=gramps

# Gramps Options
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
GRAMPSOPTIONSSTART=-y -q -i $(GEDCOM_PATH)/$(GEDCOM_FILE) -a report -p
GRAMPSOPTIONSREPORTPART1=name=det_ancestor_report,pageben=True,date_format=5,listc=True,listc_spouses=True,fulldates=True,desref=True,
GRAMPSOPTIONSREPORTPART2=incnotes=False,incattrs=False,incphotos=False,off=tex,of=$(OUTPUT_PATH)/tex_input/det_ancestor_report_
GRAMPSOPTIONSREPORT=$(GRAMPSOPTIONSREPORTPART1)$(GRAMPSOPTIONSREPORTPART2)

# R file
R_MODIFY_FILE=src/Modify_Gramps_Output.R
R_GEDCOM_FILE=src/Modify_GEDCOM.R

# LATEX
LATEX_COMMAND=latex -output-directory=$(OUTPUT_PATH)/pdf_output -output-format=pdf

.PHONY : gramps
gramps :
	# correct GEDCOM Errors
	Rscript --vanilla $(OUTPUT_PATH)/$(R_GEDCOM_FILE) $(GEDCOM_PATH)/$(GEDCOM_FILE)
	# process a gedcom file from FamilyTreeMaker with Gramps
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORT)Bechtel.tex,pid=$(BECHTEL)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORT)Connell.tex,pid=$(CONNELL)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORT)Fett.tex,pid=$(FETT)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORT)Hartenstine.tex,pid=$(HARTENSTINE)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORT)Josey.tex,pid=$(JOSEY)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORT)Langston.tex,pid=$(LANGSTON)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORT)Rettgers.tex,pid=$(RETTGERS)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORT)Smith.tex,pid=$(SMITH)"

.PHONY : r
r :
	# Process with R
	Rscript --vanilla $(OUTPUT_PATH)/$(R_MODIFY_FILE)

.PHONY : tex
tex :
	# Process with tex
	if [ ! -d "$(OUTPUT_PATH)/pdf_output" ]; then \
		mkdir $(OUTPUT_PATH)/pdf_output; \
	fi
	$(LATEX_COMMAND) $(OUTPUT_PATH)/tex_input/Volume1.tex
	$(LATEX_COMMAND) $(OUTPUT_PATH)/tex_input/Volume2.tex
	$(LATEX_COMMAND) $(OUTPUT_PATH)/tex_input/Volume3.tex
	$(LATEX_COMMAND) $(OUTPUT_PATH)/tex_input/Volume4.tex
	$(LATEX_COMMAND) $(OUTPUT_PATH)/tex_input/Volume5.tex

.PHONY : all
all : gramps r tex

.PHONY : mount
mount :
	# Ensure that the GEDCOM_PATH is mounted to windows if necessary
	# mount -t vboxsf [Name in vbox mount] [path in linux]
	mount -t vboxsf $(VBOXSF_NAME) $(GEDCOM_PATH)

.PHONY : clean
clean :
	rm -rf pdf_output
	rm -rf tex_output
