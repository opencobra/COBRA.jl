# COBRA.jl - Tutorial

This tutorial serves as a quick start guide as well as an interactive reference for more advanced users.

Download the live notebook [here](https://github.com/opencobra/COBRA.jl/tree/master/docs/tutorial).

## Beginner's Guide

Should you not have any prior experience with Julia and/or Linux, please **read carefully** the [Beginner's Guide](http://opencobra.github.io/COBRA.jl/stable/cobratutorial.html). If you however feel that you are set to proceed with this tutorial, please consider the Beginner's Guide as a go-to reference in case you are running into any issues. If you see unusual behavior, you may consider reading the [FAQ section](http://opencobra.github.io/COBRA.jl/stable/faq.html).

## Quick installation

Should you not already have the `COBRA.jl` package, you must first first follow the installation instructions [here](http://opencobra.github.io/COBRA.jl/).

> Please note that should you run this tutorial on an already configured system, the following lines will throw an error message.

Before running any function of `COBRA.jl`, it is necessary to include the `COBRA.jl` module:


```julia
using COBRA
```

## Quick help

Should you feel lost or don't know the meaning of certain input parameters, try typing a question mark at the Julia REPL followed by a keyword. For instance:


```julia
? distributedFBA
```

## Installation check and package testing

Please make sure that you have a working installation of `MathProgBase.jl` and at least one of the supported solvers. You may find further information [here](http://mathprogbasejl.readthedocs.io/en/latest/). You may run the following in order to be sure and check your system's configuration.

You can find further information on how to install other supported solvers, such as `CPLEX`, `CLP`, `Gurobi`, or `Mosek` [here](https://github.com/JuliaOpt).


```julia
# loads the functions to check your setup
include("$(Pkg.dir("COBRA"))/src/checkSetup.jl")

# list your installed packages
packages = checkSysConfig()

# clear the workspace of loaded packages
workspace()
```

You may, at any time, check the integrity of the `COBRA.jl` package by running:

```Julia
Pkg.test("COBRA")
```

The code has been benchmarked against the `fastFVA` implementation [[3](#References-1)]. A test model `ecoli_core_model.mat` [[4](#References-1)] can be used to pre-compile the code and is available in the `/test` folder. The modules and solvers are correctly installed when all tests pass without errors (warnings may appear).

## Adding local workers

The connection functions are given in `connect.jl`, which, if a parallel version is desired, must be included separately:


```julia
include("$(Pkg.dir("COBRA"))/src/connect.jl")
```

You may add local workers as follows:


```julia
# specify the total number of parallel workers
nWorkers = 4

# create a parallel pool
workersPool, nWorkers = createPool(nWorkers)
```

The IDs of the respective workers are given in `workersPool`, and the number of local workers is stored in `nWorkers`.

In order to be able to use the `COBRA` module on all connected workers, you must invoke (the `Compat` package may throw errors):


```julia
using COBRA
```

## Define and change the COBRA solver

Before the COBRA solver can be defined, the solver parameters and configuration must be loaded after having set the `solverName` (solver must be installed):

- `:GLPKMathProgInterface`
- `:CPLEX`
- `:Clp`
- `:Gurobi`
- `:Mosek`


```julia
# specify the solver name
solverName = :GLPKMathProgInterface

# include the solver configuration file
include("$(Pkg.dir("COBRA"))/config/solverCfg.jl")

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)
```

where `solParams` is an array with the definition of the solver parameters.

## Load a COBRA model

As a test and as an example, the *E.coli* core model may be loaded as:


```julia
# load the stoichiometric matrix S from a struct named model in the specified .mat file
model = loadModel("$(Pkg.dir("COBRA"))/test/ecoli_core_model.mat", "S", "model");
```

where `S` is the name of the field of the stoichiometric matrix and `model` is the name of the model. Note the semicolon that suppresses the ouput of `model`.


## Flux Balance Analysis (FBA)

In order to run a flux balance analysis (FBA), `distributedFBA` can be invoked with only 1 reaction and without an extra condition:


```julia
# set the reaction list (only one reaction)
rxnsList = 13

# select the reaction optimization mode
#  0: only minimization
#  1: only maximization
#  2: maximization and minimization
rxnsOptMode = 1

# launch the distributedFBA process with only 1 reaction on 1 worker
# distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)
minFlux, maxFlux  = distributedFBA(model, solver, 1, 90.0, "", rxnsList, 0, rxnsOptMode, false);
```

where the reaction number `13` is solved. Note that the no extra conditions are added to the model (last function argument is `false`). The minimum flux and maximum flux can hence be listed as:


```julia
maxFlux[rxnsList]
```

## Flux Variability Analysis (FVA)

In order to run a common flux variability analysis (FVA), `distributedFBA` can be invoked with all reactions as follows:


```julia
nWorkers = 4

# launch the distributedFBA process with all reactions
# distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax = distributedFBA(model, solver, nWorkers, 90.0, "max");
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

## Distributed FBA of distinct reactions

You may now input several reactions with various `rxnsOptMode` values to run specific optimization problems.


```julia
rxnsList = [1; 18; 10; 20:30; 90; 93; 95]
rxnsOptMode = [0; 1; 2; 2+zeros(Int, length(20:30)); 2; 1; 0]

# run only a few reactions with rxnsOptMode and rxnsList
# distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers, 90.0, "max", rxnsList, 0, rxnsOptMode);
```

Note that the reactions can be input as an unordered list.

## Save the variables

You can save the output of `distributedFBA` by using:


```julia
saveDistributedFBA("results.mat")
```

## References

1. [B. O. Palsson. Systems Biology: Constraint-based Reconstruction and Analysis. Cambridge University Press, NY, 2015.](http://www.cambridge.org/us/academic/subjects/life-sciences/genomics-bioinformatics-and-systems-biology/systems-biology-constraint-based-reconstruction-and-analysis?format=HB)
2. [Schellenberger, J. et al. COBRA Toolbox 2.0. 05 2011.](https://github.com/opencobra/cobratoolbox)
3. [Steinn, G. et al. Computationally efficient flux variability analysis. BMC Bioinformatics, 11(1):1–3, 2010.](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489)
4. [Orth, J. et al. Reconstruction and use of microbial metabolic networks: the core escherichia coli metabolic model as an educational guide. EcoSal Plus, 2010.](http://gcrg.ucsd.edu/Downloads/EcoliCore)
