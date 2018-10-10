# CircOpt

## File Organization
* `worker0/': Contains the template that will be clones for each cpu worker during the optimization
* `params...Ref.m files\': Contain reference and initialization data for a specific patient or subject species
* `data...m files\': Contain data for a specific patient or subject
* `opt...m files\': Tune CircAdapt to a specific patient or subject
* `eval...m files\': Evaluate a given patient or subject CircAdapt configuration
* `step...m files\': Evaluate a single perturbation step within a given patient or subject CircAdapt configuration

## Installation
1. Acquire CircAdapt from http://www.circadapt.org and place in worker0/
2. Make the changes to CircAdapt listed in diff.txt
3. Follow the example syntax in Run.m to tune a model
