# Beginner's Guide

What is Julia?
--------------

"*Julia is a high-level, high-performance dynamic programming language […]*". You may read more about Julia [here](http://julialang.org).

How do I get Julia?
-------------------

You may download Julia as explained [here](http://julialang.org/downloads/). Please read through the
[Julia documentation](http://docs.julialang.org/) if this is your first time trying out Julia.

How do I use Julia?
-------------------

On `Windows`, click on the executable `.exe` to start Julia. You may launch Julia on `Linux` or `macOS` by in a terminal window:
```sh
julia
```

You should then see the prompt of Julia:
```Julia
julia>
```
You are now in the so-called `REPL`. Here, you can type all Julia-commands. You can quit Julia by typing
```Julia
julia> quit()
```
or hitting `CTRL-d`.

What if I need help?
--------------------
If you need help, you can always type a `?`at the Julia REPL. For instance, if you require assistance with the `abs` (absolute value) function, you may type (in the Julia REPL next to `julia>`):
```Julia
? abs
```

You may also find the [FAQ section](faq.html) of this documentation interesting, especially if you are running into issues.

How do I install a solver?
--------------------------

Please make sure that you have **at least one** of the supported solvers installed on your system.

In order to get you started, you may install the `Clp` solver using:
```Julia
julia> Pkg.add("Clp")
```
This might take a while, as the `Clp` solver is downloaded to your system and then installed.

What if I want another solver?
------------------------------

As an example, and in order to get you started quickly, you may install the `GLPK` solver. On Windows, please follow these [instructions](http://winglpk.sourceforge.net/). You must have `cmake` installed and `gcc` as described [here](http://askubuntu.com/questions/610291/how-to-install-cmake-3-2-on-ubuntu-14-04) and [here](http://askubuntu.com/questions/271388/how-to-install-gcc-4-8).

On Linux, type:
```sh
sudo apt-get install cmake glpk-utils python-glpk libgmp-dev hdf5-tools
```

On `macOS`, you may install `GLPK` by using [`brew`](http://brew.sh/):
```sh
brew install glpk
```

In order to be able to use the `GLPK` solver, you must add the `GLPKMathProgInterface` and `GLPK` packages (see their respective GitHub pages [here](https://github.com/JuliaOpt/GLPKMathProgInterface.jl) and [here](https://github.com/JuliaOpt/GLPK.jl)):
```Julia
Pkg.add("GLPK")
Pkg.add("GLPKMathProgInterface")
```

Other supported solvers, such as `CPLEX`, `Clp`, `Gurobi`, or `Mosek`, may be installed in a similar way. Their respective interfaces are described [here](https://github.com/JuliaOpt). If you want to use `CPLEX`, you must follow the installation instructions [here](https://github.com/JuliaOpt/CPLEX.jl). Most importantly, make sure that you set the `LD_LIBRARY_PATH` environment variable.

Now I have a solver, and I have Julia. What is next?
------------------------------------------------------

You are now all set to install `COBRA.jl`. Follow the installation instructions [here](index.html). You may then also follow this [tutorial](cobratutorial.html) to get you started.

There is a tutorial, but I cannot open it. What should I do?
------------------------------------------------------------

If you wish to install Jupyter notebook on your own system, you may download [Jupyter](http://jupyter.org/) notebook from here.

Please make sure that you have at least `Julia 0.5` as a kernel when running the Jupyter notebook. You may install the Julia kernel by launching Julia and running the following command from within the Julia REPL (as explained [here](https://github.com/JuliaLang/IJulia.jl)):
```Julia
Pkg.add("IJulia")
```
You have a working kernel if you see in the top right corner the name of the Julia kernel (`Julia 0.5`).

Please note that before adding the `IJulia` package, you must have followed the Jupyter [installation instructions](https://jupyter.readthedocs.io/en/latest/install.html). If you are running into any issue running this tutorial on either Jupyter notebook, try it out locally by downloading first Julia as explained [here](http://julialang.org/downloads/).

Now, you can start the Jupyter notebook. On Linux, you may start Jupyter with:
```sh
jupyter notebook
```
You are all set and can run the tutorial.
