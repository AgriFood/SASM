#### SASM (Swedish Agricultural Sector Model)

This repository contains SASM, an economic model used for research and policy analysis.



###### About SASM

SASM is a Swedish agricultural sector model designed for analysing the economic impacts of changes in technology, markets and policy. The model includes farm production activities and processing activities which use regional and subregional inputs and produce regional and subregional products. Production and processing activities capture implicit derived demand and supply functions. Exogenous input supply functions and/or fixed input endowments may be introduced. Domestic product demand is described by exogenous demand functions and/or fixed demands. Regional products may be transported between regions and international trade activities are included.



###### Running the model

Run SASM2025.gms in GAMS Studio, or from the command line: gams SASM2025.gms

Standard settings (simulation year, policy levels, output options) are in settings.gms.

Project-specific code goes in project.gms and is activated with --projectFile=project. Finished projects are archived in projects/. See projects/project_template.gms.

Input data is located in the data/ folder.

Result tables are generated from model output by report.gms.

Results are written to the output/ folder, which is created automatically.



###### Workflow

The SASM group uses a trunk-based version control workflow:

* The main branch always contains a working version of the model.
* Larger or experimental changes are developed in temporary branches and merged into the main branch once they are tested and stable.
* Commits should represent logical units of work and include clear commit messages.
* Generated output files are not version controlled.



###### Repository structure

The following structure is to be maintained:



```
SASM/
├─ SASM2025.gms          # main model file
├─ settings.gms          # standard settings
├─ project.gms           # project-specific code for the ongoing project
├─ report.gms            # generates Excel output
├─ Trade_reduction.gms   # trade reduction module
├─ run_all_scenarios.bat # runs all scenarios in a project file
├─ readme.md             # this file
├─ .gitignore            # lists file types that Git ignores
├─ data/                 # input data (Excel)
│  └─ data.xlsx
├─ projects/             # archived project files and the template
│  └─ project_template.gms
└─ output/               # generated files (not version controlled)
```

