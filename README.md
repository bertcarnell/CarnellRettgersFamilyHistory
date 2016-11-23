# CarnellRettgersFamilyHistory

The family history of the Connell-Langston, Smith-Josey, Rettgers-Hartenstine, and Fett-Bechtel families

## Book Outline

1. Volume I - Military History
2. Volumne II - Connell, Langston, Smith, Josey
    + Ancestors of William Connell
    + Ancestors of Nellie D Langston
    + Ancestors of Kendrick Smith
    + Ancestors of Jewel Norene Josey
3. Volume III - Rettgers, Hartenstine, Fett, Bechtel
    + Ancestors of Ithamar Benedict Rettgers
    + Ancestors of Laura Tyson Hartenstine
    + Ancestors of Floyd William Fett
    + Ancestors of Florence Ethel Bechtel
4. Volume IV - Connell-Langston and Smith-Josey Descendants For Living Family
    + Descendants of Connell-Langston
    + Descendants of Smith-Josey
5. Volume V - Rettgers-Hartenstine and Fett-Bechtel Descendants for Living Family
    + Descendants of Rettgers-Hartenstine
    + Descendants of Fett-Bechtel

## Latex export process

1. Sync Family Tree Maker 2014 with Ancestry
2. Export GEDCOM from Family Tree Maker
    + File -> Export...
    + Entire File
    + Output format: GEDCOM 5.5
    + Privatize Living People: Yes
    + Include Private Facts: No
    + Include Private Notes: No
    + Include Media Files: No
    + OK
    + Destination: Other
    + Character Set: UTF-8
3. Open GRAMPS
    + Delete the old tree and create a new one
    + Family Trees -> Import... (Choose the latest GEDCOM file)
4. Create Ancestral Reports
    + Reports -> Text Reports -> Detailed Ancestral Report
    + Report Options
        + Select a Different Person -> show all
            + Ithamar Rettgers
        + Number: 1000
        + Given Surname Suffix
        + Include Data Marked Private: No
        + Generations: 20
        + Page Break between generations: No
        + Page Break before end notes: yes
        + Translation: Default
    + Content
        + All no except:  "Use Full dates instead of only the year", "List children", "Add descendant reference in child list"
    + Include
        + All no except:  "Include Sources"
    + Missing Information:
        + All no
    + Choose the Filename
    + Repeat Reports
        + Laura Hartenstine
        + Floyd Fett
        + Florence Bechtel
5. Run R scripts for find/replace and to change formatting
6. Open up Volume3.tex in TexWorks.  Tex it.
7. Open up Volume2.tex in TexWorks.  Tex it.


