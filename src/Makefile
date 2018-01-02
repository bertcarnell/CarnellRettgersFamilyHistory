# output path
#   Note:  OUTPUT_PATH cannot use ~/, it must use /home/carnellr to work with 
#          python3 open()
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
GRAMPSOPTIONSSTART=-y -q -i $(GEDCOM_PATH)/$(GEDCOM_FILE) -a report -p

# Report Options
# -p options for the action
#    use this to get the action options
#    $GrampsCommand $GrampsOptionsStart "name=det_ancestor_report,show=all"
#    pageben = page break before endnotes
#    date_format = 0 (YYY-MM-DD), 1 (MM-DD-YY), 2 (Month Day, Year), 
#                  3 (MON DAY, YEAR), 4 (Day Month Year), 5 (DAY MON YEAR)
#    listc = list children
#    listc_spouses = list spouses of children
#    fulldates = use full dates
#    desref
#    incnotes = include notes
#    incattrs = include attributes
#    incphotos = include photos
#    off=output format
#    of = output file
#    gen = number of generations
#    living_people = how to handle living people = 0 (included) 
#                    1 (Full names, no data), 2 (given name omitted, no data),
#                    3 (no name, no data), 4 (not included)
#    name_format = 0 (Default), 1 (surname, given), 2 (given surname),
#                  3 (Given), 4 (main surname, given patronymic)

GRAMPSOPTIONSREPORT1=name=det_ancestor_report,pageben=True,date_format=5,
GRAMPSOPTIONSREPORT2=listc=True,listc_spouses=True,fulldates=True,desref=True,
GRAMPSOPTIONSREPORT3=gen=12,incnotes=False,incattrs=False,incphotos=False,
GRAMPSOPTIONSREPORT4=off=tex,living_people=2,name_format=2,incsources=True,
GRAMPSOPTIONSREPORT5=of=$(OUTPUT_PATH)/tex_input/det_ancestor_report_
GRAMPSOPTIONSREPORT=$(GRAMPSOPTIONSREPORT1)$(GRAMPSOPTIONSREPORT2)$(GRAMPSOPTIONSREPORT3)$(GRAMPSOPTIONSREPORT4)$(GRAMPSOPTIONSREPORT5)

GRAMPSOPTIONSREPORTDEC1=name=det_descendant_report,pageben=True,date_format=5,
GRAMPSOPTIONSREPORTDEC2=listc=True,listc_spouses=True,fulldates=True,desref=True,
GRAMPSOPTIONSREPORTDEC3=gen=12,incnotes=False,incattrs=False,incphotos=False,
GRAMPSOPTIONSREPORTDEC4=off=tex,living_people=0,name_format=2,incsources=True,
GRAMPSOPTIONSREPORTDEC5=of=$(OUTPUT_PATH)/tex_input_private/det_descendant_report_
GRAMPSOPTIONSREPORTDEC=$(GRAMPSOPTIONSREPORTDEC1)$(GRAMPSOPTIONSREPORTDEC2)$(GRAMPSOPTIONSREPORTDEC3)$(GRAMPSOPTIONSREPORTDEC4)$(GRAMPSOPTIONSREPORTDEC5)

# R file
R_MODIFY_FILE=src/Modify_Gramps_Output.R
R_GEDCOM_FILE=src/Modify_GEDCOM.R

# LATEX
# use the package "rubber" to handle multiple latex passes to make the TOC
#   sudo apt-get install rubber
#LATEX_COMMAND=latex -output-directory=$(OUTPUT_PATH)/pdf_output -output-format=pdf
LATEX_COMMAND=rubber --into=$(OUTPUT_PATH)/pdf_output --pdf
AUX=$(wildcard $(OUTPUT_PATH)/pdf_output/*.aux)
ENT=$(wildcard $(OUTPUT_PATH)/pdf_output/*.ent)
LOG=$(wildcard $(OUTPUT_PATH)/pdf_output/*.log)
TOC=$(wildcard $(OUTPUT_PATH)/pdf_output/*.toc)

.PHONY: gramps # 	Create Gramps detailed ancestor reports
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
	# Process private data
	if [ ! -d "$(OUTPUT_PATH)/tex_input_private" ]; then \
		mkdir $(OUTPUT_PATH)/tex_input_private; \
	fi
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORTDEC)Connell.tex,pid=$(CONNELL)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORTDEC)Fett.tex,pid=$(FETT)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORTDEC)Rettgers.tex,pid=$(RETTGERS)"
	$(GRAMPS_COMMAND) $(GRAMPSOPTIONSSTART) "$(GRAMPSOPTIONSREPORTDEC)Smith.tex,pid=$(SMITH)"

.PHONY: r # 	Modifies the Gramps output for the desired tex format
r :
	# Process with R
	Rscript --vanilla $(OUTPUT_PATH)/$(R_MODIFY_FILE)

.PHONY: tex # 	builds the pdf files
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
	$(LATEX_COMMAND) $(OUTPUT_PATH)/tex_input/Volume6.tex
	$(LATEX_COMMAND) $(OUTPUT_PATH)/tex_input/Volume7.tex

.PHONY: clean-tex # 	cleans-up after tex-ing
clean-tex :
	rm $(AUX) 
	rm $(ENT)
	rm $(LOG)
	rm $(TOC)

.PHONY: all # 	executes gramps, r, tex, and clean-tex
all : gramps r tex clean-tex

.PHONY: mount # 	mounts a windows file system where teh GEDCOM is kept
mount :
	# Ensure that the GEDCOM_PATH is mounted to windows if necessary
	# mount -t vboxsf [Name in vbox mount] [path in linux]
	mount -t vboxsf $(VBOXSF_NAME) $(GEDCOM_PATH)

.PHONY: clean # 	cleans up all non-repository files
clean :
	rm -rf pdf_output
	rm -rf tex_output

# This pattern is used for the help tags: [.]PHONY[:][ ]Target[ ][#][ ][tab]description
.PHONY: help # 	Generate list of targets with descriptions
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1 \2/' | expand -t20


