# Tutorials 

# Tutorial - COBRA.jl

This tutorial serves as a quick start guide as well as an interactive reference for more advanced users. Download the live notebook from [here](https://github.com/opencobra/COBRA.jl/tree/master/tutorials).

### Installation

If you do not already have the `COBRA.jl` package installed, you must first first follow the installation instructions [here](http://opencobra.github.io/COBRA.jl/).

> Please note that should you run this tutorial on an already configured system. Otherwise, the following lines will throw an error message.

Before running any function of `COBRA.jl`, it is necessary to include the `COBRA.jl` module:


```julia
using COBRA
```

You can test your system by running:


```julia
COBRA.checkSysConfig()
```

### Beginner's Guide

Should you not have any prior experience with Julia and/or Linux, please **follow carefully** the [Beginner's Guide](http://opencobra.github.io/COBRA.jl/stable/beginnerGuide.html). If you however feel that you are set to proceed with this tutorial, please consider the [Beginner's Guide](http://opencobra.github.io/COBRA.jl/stable/beginnerGuide.html) as a go-to reference in case you are running into any issues. 

If you see unusual behavior, you may consider reading the [FAQ section](http://opencobra.github.io/COBRA.jl/stable/faq.html).

### Quick help

Do you feel lost or you don’t know the meaning of certain input parameters? Try typing a question mark at the Julia REPL followed by a keyword. For instance:

```julia
julia> ? distributedFBA
```

### Installation check and package testing

Make sure that you have a working installation of `MathProgBase.jl` and at least one of the supported solvers. You may find further information [here](http://mathprogbasejl.readthedocs.io/en/latest/). 

If you want to install other solvers such as `CPLEX`, `CLP`, `Gurobi`, or `Mosek`, you can find more information [here](https://github.com/JuliaOpt).

You may, at any time, check the integrity of the `COBRA.jl` package by running:

```Julia
julia> Pkg.test("COBRA")
```

The code has been benchmarked against the `fastFVA` implementation [[3](#References-1)]. The modules and solvers are correctly installed when all tests pass without errors (warnings may appear).

### References

1. [B. O. Palsson. Systems Biology: Constraint-based Reconstruction and Analysis. Cambridge University Press, NY, 2015.](http://www.cambridge.org/us/academic/subjects/life-sciences/genomics-bioinformatics-and-systems-biology/systems-biology-constraint-based-reconstruction-and-analysis?format=HB)
2. [Heirendt, L & Arreckx, S. et al. Creation and analysis of biochemical constraint-based models: the COBRA Toolbox v3.0 (submitted), 2017.](https://github.com/opencobra/cobratoolbox)
3. [Steinn, G. et al. Computationally efficient flux variability analysis. BMC Bioinformatics, 11(1):1–3, 2010.](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489)
4. [Orth, J. et al. Reconstruction and use of microbial metabolic networks: the core escherichia coli metabolic model as an educational guide. EcoSal Plus, 2010.](http://gcrg.ucsd.edu/Downloads/EcoliCore)
## Tutorial - distributedFBA.jl

This tutorial serves as a reference to get started with `distributedFBA.jl`. Download the live notebook from [here](https://github.com/opencobra/COBRA.jl/tree/master/tutorials).

If you are not familiar with `COBRA.jl`, or how `COBRA.jl` should be installed, please refer to the tutorial on `COBRA.jl`.


```julia
using COBRA
```

### Adding local workers

The connection functions are given in `connect.jl`, which, if a parallel version is desired, must be included separately:


```julia
using Distributed #leejm516: This is needed even though COBRA imports that package 
include(joinpath(dirname(pathof(COBRA)), "connect.jl"))
```

You may add local workers as follows:


```julia
## specify the total number of parallel workers
nWorkers = 4 

## create a parallel pool
workersPool, nWorkers = createPool(nWorkers) 
```

The IDs of the respective workers are given in `workersPool`, and the number of local workers is stored in `nWorkers`.

In order to be able to use the `COBRA` module on all connected workers, you must invoke:


```julia
@everywhere using COBRA;
```

### Define and change the COBRA solver

Before the COBRA solver can be defined, the solver parameters and configuration must be loaded after having set the `solverName` (solver must be installed):

- `:GLPKMathProgInterface`
- `:CPLEX`
- `:Gurobi`


```julia
## specify the solver name
solverName = :GLPKMathProgInterface

## include the solver configuration file
include(joinpath(dirname(pathof(COBRA)), "../config/solverCfg.jl"))
```

The name of the solver can be changed as follows:


```julia
## change the COBRA solver
solver = changeCobraSolver(solverName, solParams)
```

where `solParams` is an array with the definition of the solver parameters.

### Load a COBRA model

As a test and as an example, the *E.coli* core model may be loaded as:


```julia
## download the test model
using HTTP
include(joinpath(dirname(pathof(COBRA)), "../test/getTestmodel.jl"))
getTestModel()
```

Load the stoichiometric matrix S from a MATLAB `structure` named model in the specified .mat file


```julia
model = loadModel("ecoli_core_model.mat", "S", "model");
```

where `S` is the name of the field of the stoichiometric matrix and `model` is the name of the model. Note the semicolon that suppresses the ouput of `model`.


### Flux Balance Analysis (FBA)

In order to run a flux balance analysis (FBA), `distributedFBA` can be invoked with only 1 reaction and without an extra condition:


```julia
## set the reaction list (only one reaction)
rxnsList = 13

## select the reaction optimization mode
##  0: only minimization
##  1: only maximization
##  2: maximization and minimization
rxnsOptMode = 1

## launch the distributedFBA process with only 1 reaction on 1 worker
minFlux, maxFlux  = distributedFBA(model, solver, nWorkers=1, rxnsList=rxnsList, rxnsOptMode=rxnsOptMode);
```

where the reaction number `13` is solved. Note that the no extra conditions are added to the model (last function argument is `false`). The minimum flux and maximum flux can hence be listed as:


```julia
maxFlux[rxnsList]
```

### Flux Variability Analysis (FVA)

In order to run a common flux variability analysis (FVA), `distributedFBA` can be invoked with all reactions as follows:


```julia
## launch the distributedFBA process with all reactions
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax = distributedFBA(model, solver, nWorkers=4, optPercentage=90.0, preFBA=true);
```

The optimal solution of the original FBA problem can be retrieved with:


```julia
optSol
```

The corresponding solution vector `maxFlux` of the original FBA that is solved with:


```julia
fbaSol
```

The minimum and maximum fluxes of each reaction are in:


```julia
maxFlux
```

The flux vectors of all the reactions are stored in `fvamin` and `fvamax`.


```julia
fvamin
```


```julia
fvamax
```

### DistributedFBA of distinct reactions

You may now input several reactions with various `rxnsOptMode` values to run specific optimization problems.


```julia
rxnsList = [1; 18; 10; 20:30; 90; 93; 95]
rxnsOptMode = [0; 1; 2; 2 .+ zeros(Int, length(20:30)); 2; 1; 0]

## run only a few reactions with rxnsOptMode and rxnsList
## distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver);
```

Note that the reactions can be input as an unordered list.

### Saving the variables

You can save the output of `distributedFBA` by using:


```julia
saveDistributedFBA("results.mat")
```

Note that the results are saved in a `.mat` file that can be opened in MATLAB for further processing.

### Cleanup

In order to cleanup the files generated during this tutorial, you can remove the files using:


```julia
rm("ecoli_core_model.mat")
rm("results.mat")
```

### References

1. [B. O. Palsson. Systems Biology: Constraint-based Reconstruction and Analysis. Cambridge University Press, NY, 2015.](http://www.cambridge.org/us/academic/subjects/life-sciences/genomics-bioinformatics-and-systems-biology/systems-biology-constraint-based-reconstruction-and-analysis?format=HB)
2. [Heirendt, L & Arreckx, S. et al. Creation and analysis of biochemical constraint-based models: the COBRA Toolbox v3.0 (submitted), 2017.](https://github.com/opencobra/cobratoolbox)
3. [Steinn, G. et al. Computationally efficient flux variability analysis. BMC Bioinformatics, 11(1):1–3, 2010.](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489)
4. [Orth, J. et al. Reconstruction and use of microbial metabolic networks: the core escherichia coli metabolic model as an educational guide. EcoSal Plus, 2010.](http://gcrg.ucsd.edu/Downloads/EcoliCore)

## Tutorial - PALM.jl

This tutorial serves as a reference to get started with `PALM.jl`. Download the live notebook from [here](https://github.com/opencobra/COBRA.jl/tree/master/tutorials).

If you are not familiar with `COBRA.jl`, or how `COBRA.jl` should be installed, please refer to the tutorial on `COBRA.jl`.

**Note:** In order to run this tutorial, you must have [MATLAB](https://www.mathworks.com) installed and a valid MATLAB license.

Please make sure to have the following packages installed: `COBRA.jl`, `MATLAB`, and `MAT`.


```julia

import Pkg;
##Pkg.add("COBRA")
Pkg.add("MATLAB")

```

### Writing a MATLAB script

The main functionality of `PALM.jl` is to run a MATLAB script that loads a different model each time from a directory of models. The MATLAB script can be based on any tutorial of [the CORBA Toolbox](https://git.io/cobratoolbox) or on a custom script.

In order to illustrate the inner workings of `PALM.jl`, we will write a custom script that loads a different model out of a folder of 4 models, and calculates several numerical characteristics of the stoichiometric matrix. The analysis is accelerated by distributing these 4 models across 2 different workers.

The MATLAB script can be saved as `scriptFile.m` in any folder. For illustration purposes, this script is located in the `test/` folder of the COBRA.jl installation directory, but may be located in any other directory. Its content can be visualized as follows:


```julia
using COBRA
run(`cat $(joinpath(dirname(pathof(COBRA)), "../test/scriptFile.m"))`)
```

Note that the variables marked with `PALM_` are the ones defined within Julia.

### Installation of the COBRA Toolbox

As the `scriptFile.m` refers to the `readCbModel` function implemented in [the COBRA Toolbox](https://git.io/cobratoolbox), the COBRA Toolbox must be installed by following the installation instructions [here](https://opencobra.github.io/cobratoolbox/stable/installation.html).

If you already have a working installation of the COBRA Toolbox, you may skip the following lines. The COBRA Toolbox may be installed in any directory - please write it down for later use in this tutorial.

**Advanced users** may also want to install the COBRA Toolbox directly installed from Julia. You must have `git` (or `gitBash` on Windows) installed - see [requirements](https://opencobra.github.io/cobratoolbox/stable/installation.html#system-requirements).

For illustration purposes of this tutorial, the COBRA Toolbox will be installed in the `~/tmp` directory. This may take a while, depending on the speed of your internet connection.


```julia
installDir = homedir()*"/tmp/cobratoolbox"
```


```julia
## if you already ran this tutorial once, you may also remove the previous installation directory with the following command:
## Note: The following command removes the directory specified above!
run(`rm -rf $installDir`)
```


```julia
run(`git clone --depth=1 --recurse-submodules https://github.com/opencobra/cobratoolbox.git $installDir`);
@info "The COBRA Toolbox has been cloned successfully to the $installDir directory."
```


```julia
run(`mkdir "~/tmp/cobratoolbox"`)
```

**Tip:** When using `PALM.jl`, it is advised to add the `--recurse-submodules` flag. This will speed up the simultaneous initialisations on several workers.

### Connecting workers

Similarly to `distributedFBA.jl`, the workers may be added using `createPool`, given in the external function `connect.jl`, which must be included separately. Please note that also workers connected via SSH may be added to the pool of workers.


```julia
using Distributed
include(joinpath(dirname(pathof(COBRA)), "connect.jl"))
```


```julia
## specify the total number of parallel workers
nWorkers = 4 

## create a parallel pool
workersPool, nWorkers = createPool(nWorkers) 
```

After initializing the workers, the packages must be loaded on each worker:


```julia
@everywhere using COBRA;
@everywhere using MATLAB;
```

### Sharing the load

Within `PALM.jl`, the load is shared automatically. However, it might be illustrative to check upfront when planning a large-scale simulation how the load will be shared. For this purpose, the `shareLoad` function within the `COBRA.jl` package may be used.

If there are 4 models to be distributed across 4 workers, the load sharing is ideal, as every worker will run 1 model.


```julia
nWorkers, quotientModels, remainderModels = COBRA.shareLoad(4)
```

In case of sharing 6 models across the connected 4 workers, the load sharing will not be ideal:


```julia
nWorkers, quotientModels, remainderModels = COBRA.shareLoad(6)
```

### Preparing the models

In order to illustrate how several models can be loaded, the models included in the COBRA Toolbox may be used. The list of models may be displayed using:


```julia
modelDir = "$installDir/test/models/mat"
readdir(modelDir)
```

### Output variables

The variables that should be retrieved from the script (see `scriptFile.m`) can be defined in an array as follows:


```julia
varsCharact = ["nMets", "nRxns", "nElem", "nNz"]
```

**Note:** The variable names defined in `varsCharac` are the same as in the MATLAB script.

### Running PALM

The input parameters of `PALM.jl` are defined as:


```julia
? PALM
```

Now, all variables are defined, and `PALM.jl` is ready to be launched:


```julia
PALM(modelDir, "$(joinpath(dirname(pathof(COBRA)), "../test/scriptFile.m"))"; nMatlab=nWorkers, outputFile="modelCharacteristics.mat", varsCharact=varsCharact, cobraToolboxDir=installDir)
```

The output file that contains the values of the variables defined in `varsCharact` for each model is `modelCharacteristics.mat`. This file can be read back into Julia by using:


```julia
using MAT
vars = matread("modelCharacteristics.mat")
```

The full data set can be retrieved with: 


```julia
summaryData = vars["summaryData"]
```
