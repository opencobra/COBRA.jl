
# COBRA.jl - Tutorial

This tutorial serves as a quick start guide as well as an interactive reference for more advanced users. Download the live notebook [here](https://github.com/opencobra/COBRA.jl/tree/master/docs/tutorial).

## Installation

If you do not already have the `COBRA.jl` package installed, you must first first follow the installation instructions [here](http://opencobra.github.io/COBRA.jl/).

> Please note that should you run this tutorial on an already configured system. Otherwise, the following lines will throw an error message.

Before running any function of `COBRA.jl`, it is necessary to include the `COBRA.jl` module:


```julia
using COBRA
```

You can test your system by running:


```julia
COBRA.checkSysConfig();
```

    [1m[33m
     >> Checking the system's configuration ...
    
    [0m[1m[33mPackage Clp is not installed. In order to use Clp, you must first run `Pkg.add("Clp")`
    [0m[1m[32mGLPKMathProgInterface is installed.
    [0m[1m[32mGurobi is installed.
    [0m[1m[32mCPLEX is installed.
    [0m[1m[33mPackage Mosek is not installed. In order to use Mosek, you must first run `Pkg.add("Mosek")`
    [0m[1m[32m
     >> Done. 3 solvers are installed and ready to use.
    [0m

## Beginner's Guide

Should you not have any prior experience with Julia and/or Linux, **read carefully** the [Beginner's Guide](http://opencobra.github.io/COBRA.jl/stable/cobratutorial.html). If you however feel that you are set to proceed with this tutorial, please consider the Beginner's Guide as a go-to reference in case you are running into any issues. If you see unusual behavior, you may consider reading the [FAQ section](http://opencobra.github.io/COBRA.jl/stable/faq.html).

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

    [1m[34mINFO: Parallel version - Connecting the 4 workers ...
    [0m

    [1m[34m4 local workers are connected. (+1) on host: macbookpro-uni-lu.local
    [0m




    ([2,3,4,5],4)



The IDs of the respective workers are given in `workersPool`, and the number of local workers is stored in `nWorkers`.

In order to be able to use the `COBRA` module on all connected workers, you must invoke:


```julia
@everywhere using COBRA;
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
```




    2-element Array{Any,1}:
         :Simplex
     true        




```julia
# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)
```




    COBRA.SolverConfig("GLPK",GLPKMathProgInterface.GLPKInterfaceLP.GLPKSolverLP(true,:Simplex,Any[]))



where `solParams` is an array with the definition of the solver parameters.

## Load a COBRA model

As a test and as an example, the *E.coli* core model may be loaded as:


```julia
# download the test model
using Requests
include("$(Pkg.dir("COBRA"))/test/getTestModel.jl")
getTestModel()
```

    [1m[34mINFO: The ecoli_core model already exists.
    [0m

Load the stoichiometric matrix S from a MATLAB `structure` named model in the specified .mat file


```julia
model = loadModel("ecoli_core_model.mat", "S", "model");
```

    [1m[34mINFO: The model objective is set to be maximized.
    [0m[1m[34mINFO: All constraints assumed equality constaints.
    [0m

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
minFlux, maxFlux  = distributedFBA(model, solver, nWorkers=1, rxnsList=rxnsList, rxnsOptMode=rxnsOptMode);
```

    [1m[34mOriginal FBA. No additional constraints have been added.
    [0m >> Only 1 reaction of 95 will be solved (~ 1.0526315789473684 %).
    
     -- Maximization (iRound = 1). Block 1 [1/95].


where the reaction number `13` is solved. Note that the no extra conditions are added to the model (last function argument is `false`). The minimum flux and maximum flux can hence be listed as:


```julia
maxFlux[rxnsList]
```




    0.8739215069684303



## Flux Variability Analysis (FVA)

In order to run a common flux variability analysis (FVA), `distributedFBA` can be invoked with all reactions as follows:


```julia
# launch the distributedFBA process with all reactions
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax = distributedFBA(model, solver, nWorkers=4, optPercentage=90.0, preFBA=true);
```

    
     >> Size of stoichiometric matrix: (72, 95)
    
    [1m[34mpreFBA! [osenseStr = max]: FBAobj = 0.8739215069684303, optPercentage = 90.0, objValue = optPercentage * FBAobj = 0.7865289, norm(fbaSol) = 106.83731553000716.
    
    [0m[1m[32mOriginal FBA solved. Solution time: 0.6389560699462891 s.
    
    [0m >> All 95 reactions of the model will be solved (100 %).
    
    [1m[34mAverage load per worker: 24 reactions (4 workers).
    [0m[1m[34mSplitting strategy is 0.
    
    [0m	From worker 5:	 -- Minimization (iRound = 0). Block 5 [23/95].
    	From worker 4:	 -- Minimization (iRound = 0). Block 4 [24/95].
    	From worker 3:	 -- Minimization (iRound = 0). Block 3 [24/95].
    	From worker 2:	 -- Minimization (iRound = 0). Block 2 [24/95].
    	From worker 4:	 -- Maximization (iRound = 1). Block 4 [24/95].
    	From worker 5:	 -- Maximization (iRound = 1). Block 5 [23/95].
    	From worker 3:	 -- Maximization (iRound = 1). Block 3 [24/95].
    	From worker 2:	 -- Maximization (iRound = 1). Block 2 [24/95].


The optimal solution of the original FBA problem can be retrieved with:


```julia
optSol
```




    0.8739215069684303



The corresponding solution vector `maxFlux` of the original FBA that is solved with:


```julia
fbaSol
```




    95-element Array{Float64,1}:
     -5.8486e-30 
      0.0        
      1.46336e-29
      6.00725    
      6.00725    
     -0.0        
      0.0        
      5.06438    
     -0.0        
     -5.8486e-30 
      8.39       
     45.514      
      0.873922   
      ⋮          
     -0.0        
      2.67848    
     -2.2815     
     -7.93232e-29
      0.0        
      5.06438    
     -5.06438    
      1.49698    
      0.0        
      1.49698    
      1.1815     
      7.47738    



The minimum and maximum fluxes of each reaction are in:


```julia
maxFlux
```




    95-element Array{Float64,1}:
       -2.9243e-29 
        0.0        
       -8.87161e-29
        8.89453    
        8.89453    
        0.0        
       17.1611     
        8.04594    
        0.0        
       -2.9243e-29 
       25.5511     
       59.3811     
        0.873922   
        ⋮          
        0.0        
       15.5265     
       -0.565357   
       22.8815     
       22.8815     
     1000.0        
       -1.00265e-28
        7.90523    
       37.0422     
        7.90523    
        7.62129    
        9.21764    



The flux vectors of all the reactions are stored in `fvamin` and `fvamax`.


```julia
fvamin
```




    95×95 Array{Float64,2}:
     -2.54238      -2.54238       2.19322e-30  …  -1.0235e-29   -2.23709e-28
     -2.54238      -2.54238       0.0              0.0           0.0        
     -2.2865e-31   -2.2865e-31   -3.81358         -4.29861e-29   1.36458e-27
      4.75567       4.75567       3.23024          7.8033        0.848586   
      4.75567       4.75567       3.23024          7.8033        0.848586   
     -0.0          -0.0          -3.81358      …  -0.0          -0.0        
      0.0           0.0           0.0              0.0           3.97558    
      3.90709       3.90709       2.38166          6.87133       0.0        
     -0.0          -0.0          -0.0             -0.0          -0.0        
      8.04182e-30   8.04182e-30   2.19322e-30     -1.0235e-29   -2.23709e-28
      8.39          8.39          8.39         …   8.39          8.39       
     40.5609       40.5609       38.527           41.3535       54.893      
      0.786529      0.786529      0.786529         0.863813      0.786529   
      ⋮                                        ⋱                            
     -0.0          -0.0          -0.0             -0.0          -0.0        
      2.62758       2.62758       3.13606         -0.620909     15.5265     
     -2.16183      -2.16183      -2.41606      …  -0.620909     -8.6113     
     -0.0          -0.0          -0.0             -0.0          -0.0        
      0.0           0.0           0.0              0.0           0.0        
      3.90709       3.90709       2.38166          6.87133       0.0        
     -3.90709      -3.90709      -2.38166         -6.87133      -1.77592e-27
      1.45576       1.45576       1.71         …  -0.154536      7.90523    
      0.0           0.0           0.0              7.9397        8.97615    
      1.45576       1.45576       1.71            -0.154536      7.90523    
      1.17182       1.17182       1.42606         -0.466373      7.62129    
      7.62117       7.62117       7.36693          9.14076       1.1717     




```julia
fvamax
```




    95×95 Array{Float64,2}:
     -2.9243e-29   -2.9243e-29   -2.9243e-29   …  -2.23709e-28  -2.9243e-29 
      0.0           0.0           0.0              0.0           0.0        
     -8.87161e-29  -8.87161e-29  -8.87161e-29      1.36458e-27  -8.87161e-29
      8.89453       8.89453       8.89453          0.848586      8.89453    
      8.89453       8.89453       8.89453          0.848586      8.89453    
     -0.0          -0.0          -0.0          …  -0.0          -0.0        
      0.0           0.0           0.0              3.97558       0.0        
      8.04594       8.04594       8.04594          0.0           8.04594    
     -0.0          -0.0          -0.0             -0.0          -0.0        
     -2.9243e-29   -2.9243e-29   -2.9243e-29      -2.23709e-28  -2.9243e-29 
      8.39          8.39          8.39         …   8.39          8.39       
     38.8959       38.8959       38.8959          54.893        38.8959     
      0.786529      0.786529      0.786529         0.786529      0.786529   
      ⋮                                        ⋱                            
     -0.0          -0.0          -0.0             -0.0          -0.0        
     -0.565357     -0.565357     -0.565357        15.5265       -0.565357   
     -0.565357     -0.565357     -0.565357     …  -8.6113       -0.565357   
     -0.0          -0.0          -0.0             -0.0          -0.0        
      0.0           0.0           0.0              0.0           0.0        
      8.04594       8.04594       8.04594          0.0           8.04594    
     -8.04594      -8.04594      -8.04594         -1.77592e-27  -8.04594    
     -0.14071      -0.14071      -0.14071      …   7.90523      -0.14071    
     28.9014       28.9014       28.9014           8.97615      28.9014     
     -0.14071      -0.14071      -0.14071          7.90523      -0.14071    
     -0.424647     -0.424647     -0.424647         7.62129      -0.424647   
      9.21764       9.21764       9.21764          1.1717        9.21764    



## Distributed FBA of distinct reactions

You may now input several reactions with various `rxnsOptMode` values to run specific optimization problems.


```julia
rxnsList = [1; 18; 10; 20:30; 90; 93; 95]
rxnsOptMode = [0; 1; 2; 2+zeros(Int, length(20:30)); 2; 1; 0]

# run only a few reactions with rxnsOptMode and rxnsList
# distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver);
```

    [1m[34mOriginal FBA. No additional constraints have been added.
    [0m >> All 95 reactions of the model will be solved (100 %).
    
     -- Minimization (iRound = 0). Block 1 [95/95].
     -- Maximization (iRound = 1). Block 1 [95/95].


Note that the reactions can be input as an unordered list.

## Saving the variables

You can save the output of `distributedFBA` by using:


```julia
saveDistributedFBA("results.mat")
```

    Saving minFlux (T:> Array{Float64,1}) ...[1m[32mDone.
    [0mSaving maxFlux (T:> Array{Float64,1}) ...[1m[32mDone.
    [0mSaving optSol (T:> Float64) ...[1m[32mDone.
    [0mSaving fbaSol (T:> Array{Float64,1}) ...[1m[32mDone.
    [0mSaving fvamin (T:> Array{Float64,2}) ...[1m[32mDone.
    [0mSaving fvamax (T:> Array{Float64,2}) ...[1m[32mDone.
    [0mSaving statussolmin (T:> Array{Float64,1}) ...[1m[32mDone.
    [0mSaving statussolmax (T:> Array{Float64,1}) ...[1m[32mDone.
    [0mSaving rxnsList (T:> Array{Int64,1}) ...[1m[32mDone.
    [0m[1m[32mAll available variables saved to results.mat.
    [0m

Note that the results are saved in a `.mat` file that can be opened in MATLAB for further processing.

## Cleanup

In order to cleanup the files generated during this tutorial, you can remove the files using:


```julia
rm("ecoli_core_model.mat")
rm("results.mat")
```

## References

1. [B. O. Palsson. Systems Biology: Constraint-based Reconstruction and Analysis. Cambridge University Press, NY, 2015.](http://www.cambridge.org/us/academic/subjects/life-sciences/genomics-bioinformatics-and-systems-biology/systems-biology-constraint-based-reconstruction-and-analysis?format=HB)
2. [Schellenberger, J. et al. COBRA Toolbox 2.0. 05 2011.](https://github.com/opencobra/cobratoolbox)
3. [Steinn, G. et al. Computationally efficient flux variability analysis. BMC Bioinformatics, 11(1):1–3, 2010.](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489)
4. [Orth, J. et al. Reconstruction and use of microbial metabolic networks: the core escherichia coli metabolic model as an educational guide. EcoSal Plus, 2010.](http://gcrg.ucsd.edu/Downloads/EcoliCore)

