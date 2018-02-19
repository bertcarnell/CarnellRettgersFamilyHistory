<!-- Copyright (c) 2018 Robert Carnell -->

# CarnellRettgersFamilyHistory

The family history of the Connell-Langston, Smith-Josey, Rettgers-Hartenstine, and Fett-Bechtel families.  See our progress [here](https://bertcarnell.github.io/CarnellRettgersFamilyHistory/).

## Book Outline

1. **Volume I** - Military History
2. **Volumne II** - Connell, Langston, Smith, Josey
    + Ancestors of William Connell
    + Ancestors of Nellie D Langston
    + Ancestors of Kendrick Smith
    + Ancestors of Jewel Norene Josey
3. **Volume III** - Rettgers, Hartenstine, Fett, Bechtel
    + Ancestors of Ithamar Benedict Rettgers
    + Ancestors of Laura Tyson Hartenstine
    + Ancestors of Floyd William Fett
    + Ancestors of Florence Ethel Bechtel
4. **Volume IV** - Carnell-Rettgers Genetic Ancestry
5. **Volume V** - Obituaries and News Articles
6. **Volume VI** - Connell-Langston and Smith-Josey Descendants For Living Family
    + Descendants of Connell-Langston
    + Descendants of Smith-Josey
7. **Volume VII** - Rettgers-Hartenstine and Fett-Bechtel Descendants for Living Family
    + Descendants of Rettgers-Hartenstine
    + Descendants of Fett-Bechtel

## Latex export process from [Gramps](https://gramps-project.org)

1. Sync [Family Tree Maker 2017](http://www.mackiev.com/ftm/index.html) with [Ancestry](https://www.ancestry.com/)
2. Export [GEDCOM](https://en.wikipedia.org/wiki/GEDCOM) from Family Tree Maker
    + File -> Export...
    + Entire File
    + Output format: GEDCOM 5.5
    + Privatize Living People: No
    + Include Private Facts: No
    + Include Private Notes: No
    + Include Media Files: No
    + OK
    + Destination: Other
    + Character Set: UTF-8
3. Modify `src/Makefile` to point to the correct GEDCOM output from #2
4. `sudo make mount` to mount the directory location on the Ubuntu VM
5. `make all` to run the process
    + `make help` to print the Makefile options
    + `make gramps` to export detailed ancestor reports
    + `make r` to find/replace and change formatting
    + `make tex` to build the pdf output files
    + `make clean-tex` to clean-up after the pdf process
