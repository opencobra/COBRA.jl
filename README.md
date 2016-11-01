COBRA.jl - COnstraint-Based Reconstruction and Analysis
=======================================================

[![Build Status](https://travis-ci.org/opencobra/COBRA.jl.svg?branch=master)](https://travis-ci.org/opencobra/COBRA.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/10gweiiiby18ucy5/branch/master?svg=true)](https://ci.appveyor.com/project/laurentheirendt/cobra-jl/branch/master)
[![coverage status](http://codecov.io/github/opencobra/COBRA.jl/coverage.svg?branch=master)](http://codecov.io/github/opencobra/COBRA.jl?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/opencobra/COBRA.jl/badge.svg?branch=master)](https://coveralls.io/github/opencobra/COBRA.jl?branch=master)
[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://opencobra.github.io/COBRA.jl)

`COBRA.jl` is a package written in [Julia](http://julialang.org/downloads/) used to perform COBRA analyses such as Flux Balance Anlysis (FBA), Flux Variability Anlysis (FVA), or any of its associated variants such as `distributedFBA` [[1](#References-1)].

FBA and FVA rely on the solution of LP problems. The package can be used with ease when the LP problem is defined in a `.mat` file according to the format outlined in the [COBRAToolbox](https://github.com/opencobra/cobratoolbox) [[2](#References-1)].

Layout
-------

![Code Layout](https://raw.githubusercontent.com/opencobra/COBRA.jl/master/docs/src/assets/codeLayout.jpg)

Complete Beginner's Guide
--------------------------

Should you not have any prior experience with Julia and/or Linux, please **read carefully** the [Complete Beginner's Guide](http://opencobra.github.io/COBRA.jl/cbg.html). If you however feel that you are set to proceed with this tutorial, please consider the Complete Beginner's Guide as a go-to reference in case you are running into any issues.

Requirements and compatibility
------------------------------

>
If you are novice to Julia, you may find the [Complete Beginner's Guide](http://opencobra.github.io/COBRA.jl/cbg.html) interesting. In this manual, a working installation of Julia is assumed.
>

`COBRA.jl` has been tested on *Ubuntu Linux 14.04+*, *MacOS 10.7+*, and *Windows 7 (64-bit)*. Currently, all solvers that are [supported](https://github.com/JuliaOpt/MathProgBase.jl/blob/master/src/defaultsolvers.jl) by `MathProgBase.jl` are supported by `COBRA.jl`, but must be installed **separately**. The `COBRA.jl` package has been tested with `Julia v0.5+`, and requires a working installation of the latest [`MathProgBase.jl`](https://github.com/JuliaOpt/MathProgBase.jl). In order to load the COBRA model from a `.mat` file, the module [`MAT.jl`](https://github.com/simonster/MAT.jl) is required.

Installation of COBRA
---------------------

At the Julia prompt, clone the `COBRA.jl` package and update all packages:
```Julia
Pkg.update()
Pkg.clone("https://github.com/opencobra/COBRA.jl.git")
```

Use the `COBRA.jl` module by running:
```Julia
using COBRA
```

Testing and benchmarking
------------------------

You can test the package using:
```Julia
Pkg.test("COBRA")
```
Shall no solvers be detected on your system, you may experience error messages when testing the `COBRA.jl` package. Please make sure that you have installed at least one solver.

The code has been benchmarked against the `fastFVA` implementation [[3](#References-1)]. A test model `ecoli_core_model.mat` [[4](#References-1)] can be used to pre-compile the code and is available in the `/test` folder. The modules and solvers are correctly installed when all tests pass without errors (warnings may appear of third party packages).

How can I generate the documentation?
-------------------------------------

You can generate the documentation using [`Documenter.jl`](https://github.com/JuliaDocs/Documenter.jl) by typing in `/docs`:
```sh
julia --color=yes makeDoc.jl
```

Tutorial, Documentation and FAQ
-------------------------------

You may follow [this](https://github.com/opencobra/COBRA.jl/tree/master/docs/tutorial) interactive Jupyter notebook. The complete documentation can be read [here](http://opencobra.github.io/COBRA.jl). For each function, you may display a description. For instance, you may request more information on `distributedFBA` by typing at the Julia REPL:
```Julia
? distributedFBA
```
Should you encounter any errors or unusual behavior, please refer to the [FAQ section](http://opencobra.github.io/COBRA.jl/faq.html).

How to cite `distributedFBA.jl`?
-----------------------------------------------

You may cite `distributedFBA.jl` as follows:

> Laurent Heirendt, Ronan M.T. Fleming, Ines Thiele, DistributedFBA.jl: High-level, high-performance flux balance analysis in Julia, in review, 2016.

Limitations
-----------

- At present, a COBRA model in `.mat` format is loaded using the `MAT.jl` package. A valid MATLAB license is **not** required.
- The inner layer parallelization is currently done within the solver. No log files of each spawned thread are generated.
- The current benchmarks have been performed using default optimization and compilation options of Julia and a set of solver parameters. The performance may be further improved by tuning these parameters.

References
-----------

1. [B. O. Palsson. Systems Biology: Constraint-based Reconstruction and Analysis. Cambridge University Press, NY, 2015.](http://www.cambridge.org/us/academic/subjects/life-sciences/genomics-bioinformatics-and-systems-biology/systems-biology-constraint-based-reconstruction-and-analysis?format=HB)
2. [Schellenberger, J. et al. COBRA Toolbox 2.0. 05 2011.](https://github.com/opencobra/cobratoolbox)
3. [Steinn, G. et al. Computationally efficient flux variability analysis. BMC Bioinformatics, 11(1):1–3, 2010.](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-489)
4. [Orth, J. et al. Reconstruction and use of microbial metabolic networks: the core escherichia coli metabolic model as an educational guide. EcoSal Plus, 2010.](http://gcrg.ucsd.edu/Downloads/EcoliCore)
