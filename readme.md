#### SASM (Swedish Agricultural Sector Model)

This repository contains SASM, an economic model used for research and policy analysis.



###### About SASM

SASM is a Swedish agricultural sector model designed for analysing the economic impacts of changes in technology, markets and policy. The model includes farm production activities and processing activities which use regional and subregional inputs and produce regional and subregional products. Production and processing activities capture implicit derived demand and supply functions. Exogenous input supply functions and/or fixed input endowments may be introduced. Domestic product demand is described by exogenous demand functions and/or fixed demands. Regional products may be transported between regions and international trade activities are included.



###### Running the model

The model is run via GAMS Studio using the project file SASM.gsp.

Open SASM.gsp and run SASM2025.gms.

Input data is located in the data/ folder.

Results tables are generated from model output by report.gms.

Model output and logs are written to the output/ folder.

Excel reports are written to the reports/ folder.



###### Workflow

The SASM group uses a trunk-based version control workflow:

* The main branch always contains a working version of the model.
* Larger or experimental changes are developed in temporary branches and merged into the main branch once they are tested and stable.
* Commits should represent logical units of work and include clear commit messages.
* Generated output files are not version controlled.



###### Repository structure

The following structure is to be maintained:



SASM/

├─ SASM.gsp            # GAMS Studio project file

├─ SASM2025.gms        # main model file

├─ report.gms          # generates Excel output

├─ readme.md	       # this file	

├─ .gitignore          # lists file types that Git ignores

├─ data/               # input data (Excel)

│  └─ data.xlsx

├─ modules/            # model modules

│  └─

├─ output/             # generated files (not version controlled)

└─ reports/            # generated Excel reports (not version controlled)

