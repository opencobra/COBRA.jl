# Tutorial - COBRA.jl

This tutorial serves as a quick start guide as well as an interactive reference for more advanced users. Download the live notebook from [here](https://github.com/opencobra/COBRA.jl/tree/master/tutorials).

## Installation

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

## Beginner's Guide

Should you not have any prior experience with Julia and/or Linux, please **follow carefully** the [Beginner's Guide](http://opencobra.github.io/COBRA.jl/stable/beginnerGuide.html). If you however feel that you are set to proceed with this tutorial, please consider the [Beginner's Guide](http://opencobra.github.io/COBRA.jl/stable/beginnerGuide.html) as a go-to reference in case you are running into any issues. 

If you see unusual behavior, you may consider reading the [FAQ section](http://opencobra.github.io/COBRA.jl/stable/faq.html).

## Quick help

Do you feel lost or you don’t know the meaning of certain input parameters? Try typing a question mark at the Julia REPL followed by a keyword. For instance:

```julia
julia> ? distributedFBA
```

## Installation check and package testing

Make sure that you have a working installation of `MathProgBase.jl` and at least one of the supported solvers. You may find further information [here](http://mathprogbasejl.readthedocs.io/en/latest/). 

If you want to install other solvers such as `CPLEX`, `CLP`, `Gurobi`, or `Mosek`, you can find more information [here](https://github.com/JuliaOpt).

You may, at any time, check the integrity of the `COBRA.jl` package by running:

```Julia
julia> Pkg.test("COBRA")
```

The code has been benchmarked against the `fastFVA` implementation [[3](#References-1)]. The modules and solvers are correctly installed when all tests pass without errors (warnings may appear).

## References

1. [B. O. Palsson. Systems Biology: Constraint-based Reconstruction and Analysis. Cambridge University Press, NY, 2015.](http://www.cambridge.org/us/academic/subjects/life-sciences/genomics-bioinformatics-and-systems-biology/systems-biology-constraint-based-reconstruction-and-analysis?format=HB)
2. [Heirendt, L & Arreckx, S. et al. Creation and analysis of biochemical constraint-based models: the COBRA Toolbox v3.0 (submitted), 2017.](https://github.com/opencobra/cobratoolbox)
3. [Steinn, G. et al. Computationally efficient flux variability analysis. BMC Bioinformatics, 11(1):1–3, 2010.](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489)
4. [Orth, J. et al. Reconstruction and use of microbial metabolic networks: the core escherichia coli metabolic model as an educational guide. EcoSal Plus, 2010.](http://gcrg.ucsd.edu/Downloads/EcoliCore)
