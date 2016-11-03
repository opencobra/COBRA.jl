var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#COBRA.jl-COnstraint-Based-Reconstruction-and-Analysis-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "category": "section",
    "text": "(Image: Build Status) (Image: Build status) (Image: coverage status) (Image: Coverage Status) (Image: ) (Image: )COBRA.jl is a package written in Julia used to perform COBRA analyses such as Flux Balance Anlysis (FBA), Flux Variability Anlysis (FVA), or any of its associated variants such as distributedFBA [1].FBA and FVA rely on the solution of LP problems. The package can be used with ease when the LP problem is defined in a .mat file according to the format outlined in the COBRAToolbox [2]."
},

{
    "location": "index.html#Layout-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Layout",
    "category": "section",
    "text": "(Image: Code Layout)"
},

{
    "location": "index.html#Complete-Beginner's-Guide-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Complete Beginner's Guide",
    "category": "section",
    "text": "Should you not have any prior experience with Julia and/or Linux, please read carefully the Complete Beginner's Guide. If you however feel that you are set to proceed with this tutorial, please consider the Complete Beginner's Guide as a go-to reference in case you are running into any issues."
},

{
    "location": "index.html#Requirements-and-compatibility-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Requirements and compatibility",
    "category": "section",
    "text": "If you are novice to Julia, you may find the Complete Beginner's Guide interesting. In this manual, a working installation of Julia is assumed.COBRA.jl has been tested on Ubuntu Linux 14.04+, MacOS 10.7+, and Windows 7 (64-bit). Currently, all solvers that are supported by MathProgBase.jl are supported by COBRA.jl, but must be installed separately. The COBRA.jl package has been tested with Julia v0.5+, and requires a working installation of the latest MathProgBase.jl. In order to load the COBRA model from a .mat file, the module MAT.jl is required."
},

{
    "location": "index.html#Installation-of-COBRA-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Installation of COBRA",
    "category": "section",
    "text": "At the Julia prompt, clone the COBRA.jl package and update all packages:Pkg.update()\nPkg.clone(\"https://github.com/opencobra/COBRA.jl.git\")Use the COBRA.jl module by running:using COBRA"
},

{
    "location": "index.html#Testing-and-benchmarking-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Testing and benchmarking",
    "category": "section",
    "text": "You can test the package using:Pkg.test(\"COBRA\")Shall no solvers be detected on your system, you may experience error messages when testing the COBRA.jl package. Please make sure that you have installed at least one solver.The code has been benchmarked against the fastFVA implementation [3]. A test model ecoli_core_model.mat [4] can be used to pre-compile the code and is available in the /test folder. The modules and solvers are correctly installed when all tests pass without errors (warnings may appear of third party packages)."
},

{
    "location": "index.html#How-can-I-generate-the-documentation?-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "How can I generate the documentation?",
    "category": "section",
    "text": "You can generate the documentation using Documenter.jl by typing in /docs:julia --color=yes makeDoc.jl"
},

{
    "location": "index.html#Tutorial,-Documentation-and-FAQ-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Tutorial, Documentation and FAQ",
    "category": "section",
    "text": "You may follow this interactive Jupyter notebook. The complete documentation can be read here. For each function, you may display a description. For instance, you may request more information on distributedFBA by typing at the Julia REPL:? distributedFBAShould you encounter any errors or unusual behavior, please refer to the FAQ section."
},

{
    "location": "index.html#How-to-cite-distributedFBA.jl?-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "How to cite distributedFBA.jl?",
    "category": "section",
    "text": "You may cite distributedFBA.jl as follows:Laurent Heirendt, Ronan M.T. Fleming, Ines Thiele, DistributedFBA.jl: High-level, high-performance flux balance analysis in Julia, in review, 2016."
},

{
    "location": "index.html#Limitations-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Limitations",
    "category": "section",
    "text": "At present, a COBRA model in .mat format is loaded using the MAT.jl package. A valid MATLAB license is not required.\nThe inner layer parallelization is currently done within the solver. No log files of each spawned thread are generated.\nThe current benchmarks have been performed using default optimization and compilation options of Julia and a set of solver parameters. The performance may be further improved by tuning these parameters."
},

{
    "location": "index.html#References-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "References",
    "category": "section",
    "text": "B. O. Palsson. Systems Biology: Constraint-based Reconstruction and Analysis. Cambridge University Press, NY, 2015.\nSchellenberger, J. et al. COBRA Toolbox 2.0. 05 2011.\nSteinn, G. et al. Computationally efficient flux variability analysis. BMC Bioinformatics, 11(1):1–3, 2010.\nOrth, J. et al. Reconstruction and use of microbial metabolic networks: the core escherichia coli metabolic model as an educational guide. EcoSal Plus, 2010."
},

{
    "location": "cbg.html#",
    "page": "Complete Beginner's Guide",
    "title": "Complete Beginner's Guide",
    "category": "page",
    "text": ""
},

{
    "location": "cbg.html#Complete-Beginner's-Guide-1",
    "page": "Complete Beginner's Guide",
    "title": "Complete Beginner's Guide",
    "category": "section",
    "text": ""
},

{
    "location": "cbg.html#What-is-Julia?-1",
    "page": "Complete Beginner's Guide",
    "title": "What is Julia?",
    "category": "section",
    "text": "\"Julia is a high-level, high-performance dynamic programming language […]\". You may read more about Julia here."
},

{
    "location": "cbg.html#How-do-I-get-Julia?-1",
    "page": "Complete Beginner's Guide",
    "title": "How do I get Julia?",
    "category": "section",
    "text": "You may install Julia as explained here. Please read through the Julia documentation if this is your first time trying out Julia.For Linux users (you must have sudo rights for this), you may install Julia as follows:sudo add-apt-repository ppa:staticfloat/juliareleases\nsudo add-apt-repository ppa:staticfloat/julia-deps\nsudo apt-get update\nsudo apt-get install juliaFor macOS and Windows, you may download the Julia binaries here."
},

{
    "location": "cbg.html#How-do-I-use-Julia?-1",
    "page": "Complete Beginner's Guide",
    "title": "How do I use Julia?",
    "category": "section",
    "text": "You may launch Julia on Linux or macOS by in a terminal window:juliaOn Windows systems, you may click on the executable .exe to start Julia. In both cases, you should see the prompt of Julia:julia>You are now in the so-called REPL. Here, you can type all Julia-commands."
},

{
    "location": "cbg.html#What-if-I-need-help?-1",
    "page": "Complete Beginner's Guide",
    "title": "What if I need help?",
    "category": "section",
    "text": "If you need help, you can always type a ?at the Julia REPL. For instance, if you require assistance with the abs (absolute value) function, you may type (in the Julia REPL next to julia>):? absYou may also find the FAQ section of this documentation interesting, especially if you are running into issues."
},

{
    "location": "cbg.html#How-do-I-install-a-solver?-1",
    "page": "Complete Beginner's Guide",
    "title": "How do I install a solver?",
    "category": "section",
    "text": "Please make sure that you have ***at least one*** of the supported solvers installed on your system.In order to get you started, you may install the Clp solver using:Pkg.add(\"Clp\")This might take a while, as the Clp solver is downloaded to your system and then installed."
},

{
    "location": "cbg.html#What-if-I-want-another-solver?-1",
    "page": "Complete Beginner's Guide",
    "title": "What if I want another solver?",
    "category": "section",
    "text": "As an example, and in order to get you started quickly, you may install the GLPK solver. On Windows, please follow these instructions. You must have cmake installed and gcc as described here and here.On Linux, type:sudo apt-get install cmake glpk-utils python-glpk libgmp-dev hdf5-toolsOn macOS, you may install GLPK by using brew:brew install glpkIn order to be able to use the GLPK solver, you must add the GLPKMathProgInterface and GLPK packages (see their respective GitHub pages here and here):Pkg.add(\"GLPK\")\nPkg.add(\"GLPKMathProgInterface\")Other supported solvers, such as CPLEX, Clp, Gurobi, or Mosek, may be installed in a similar way. Their respective interfaces are described here. If you want to use CPLEX, you must follow the installation instructions here. Most importantly, make sure that you set the LD_LIBRARY_PATH environment variable."
},

{
    "location": "cbg.html#Now-I-have-a-solver,-and-I-have-Julia.-What-is-next?-1",
    "page": "Complete Beginner's Guide",
    "title": "Now I have a solver, and I have Julia. What is next?",
    "category": "section",
    "text": "You are now all set to install COBRA.jl. Follow the installation instructions here. You may then also follow this tutorial to get you started."
},

{
    "location": "cbg.html#There-is-a-tutorial,-but-I-cannot-open-it.-What-should-I-do?-1",
    "page": "Complete Beginner's Guide",
    "title": "There is a tutorial, but I cannot open it. What should I do?",
    "category": "section",
    "text": "If you wish to install Jupyter notebook on your own system, you may download Jupyter notebook from here.Please make sure that you have at least Julia 0.5 as a kernel when running the Jupyter notebook. You may install the Julia kernel by launching Julia and running the following command from within the Julia REPL (as explained here):Pkg.add(\"IJulia\")You have a working kernel if you see in the top right corner the name of the Julia kernel (Julia 0.5).Please note that before adding the IJulia package, you must have followed the Jupyter installation instructions. If you are running into any issue running this tutorial on either Jupyter notebook, try it out locally by downloading first Julia as explained here.Now, you can start the Jupyter notebook. On Linux, you may start Jupyter with:jupyter notebookYou are all set. You can run the tutorial."
},

{
    "location": "cobratutorial.html#",
    "page": "Tutorial",
    "title": "Tutorial",
    "category": "page",
    "text": ""
},

{
    "location": "cobratutorial.html#COBRA.jl-Tutorial-1",
    "page": "Tutorial",
    "title": "COBRA.jl - Tutorial",
    "category": "section",
    "text": "This tutorial serves as a quick start guide as well as an interactive reference for more advanced users.Download the live notebook here."
},

{
    "location": "cobratutorial.html#Complete-Beginner's-Guide-1",
    "page": "Tutorial",
    "title": "Complete Beginner's Guide",
    "category": "section",
    "text": "Should you not have any prior experience with Julia and/or Linux, please read carefully the Complete Beginner's Guide. If you however feel that you are set to proceed with this tutorial, please consider the Complete Beginner's Guide as a go-to reference in case you are running into any issues. If you see unusual behavior, you may consider reading the FAQ section."
},

{
    "location": "cobratutorial.html#Quick-installation-1",
    "page": "Tutorial",
    "title": "Quick installation",
    "category": "section",
    "text": "Should you not already have the COBRA.jl package, you must first first follow the installation instructions here.Please note that should you run this tutorial on an already configured system, the following lines will throw an error message.Before running any function of COBRA.jl, it is necessary to include the COBRA.jl module:using COBRA"
},

{
    "location": "cobratutorial.html#Quick-help-1",
    "page": "Tutorial",
    "title": "Quick help",
    "category": "section",
    "text": "Should you feel lost or don't know the meaning of certain input parameters, try typing a question mark at the Julia REPL followed by a keyword. For instance:? distributedFBA"
},

{
    "location": "cobratutorial.html#Installation-check-and-package-testing-1",
    "page": "Tutorial",
    "title": "Installation check and package testing",
    "category": "section",
    "text": "Please make sure that you have a working installation of MathProgBase.jl and at least one of the supported solvers. You may find further information here. You may run the following in order to be sure and check your system's configuration. You can find further information on how to install other supported solvers, such as CPLEX, CLP, Gurobi, or Mosek here.# loads the functions to check your setup\ninclude(\"$(Pkg.dir(\"COBRA\"))/src/checkSetup.jl\") \n\n# list your installed packages\npackages = checkSysConfig()You may, at any time, check the integrity of the COBRA.jl package by running:Pkg.test(\"COBRA\")The code has been benchmarked against the fastFVA implementation. A test model ecoli_core_model.mat is freely available and can be used to pre-compile the code. The model is also available in the /test folder. The modules and solvers are correctly installed when all tests pass without errors (warnings may appear)."
},

{
    "location": "cobratutorial.html#Adding-local-workers-1",
    "page": "Tutorial",
    "title": "Adding local workers",
    "category": "section",
    "text": "The connection functions are given in connect.jl, which, if a parallel version is desired, must be included separately:include(\"$(Pkg.dir(\"COBRA\"))/src/connect.jl\")You may add local workers as follows:# specify the total number of parallel workers\nnWorkers = 4 \n\n# create a parallel pool\nworkersPool, nWorkers = createPool(nWorkers) The IDs of the respective workers are given in workersPool, and the number of local workers is stored in nWorkers.In order to be able to use the COBRA module on all connected workers, you must invoke (the Compat package may throw errors):using COBRA"
},

{
    "location": "cobratutorial.html#Define-and-change-the-COBRA-solver-1",
    "page": "Tutorial",
    "title": "Define and change the COBRA solver",
    "category": "section",
    "text": "Before the COBRA solver can be defined, the solver parameters and configuration must be loaded after having set the solverName (solver must be installed)::GLPKMathProgInterface\n:CPLEX\n:Clp\n:Gurobi\n:Mosek# specify the solver name\nsolverName = :GLPKMathProgInterface\n\n# include the solver configuration file\ninclude(\"$(Pkg.dir(\"COBRA\"))/config/solverCfg.jl\")\n\n# change the COBRA solver\nsolver = changeCobraSolver(solverName, solParams)where solParams is an array with the definition of the solver parameters."
},

{
    "location": "cobratutorial.html#Load-a-COBRA-model-1",
    "page": "Tutorial",
    "title": "Load a COBRA model",
    "category": "section",
    "text": "As a test and as an example, the E.coli core model may be loaded as:# load the stoichiometric matrix S from a struct named model in the specified .mat file\nmodel = loadModel(\"$(Pkg.dir(\"COBRA\"))/test/ecoli_core_model.mat\", \"S\", \"model\");where S is the name of the field of the stoichiometric matrix and model is the name of the model. Note the semicolon that suppresses the ouput of model."
},

{
    "location": "cobratutorial.html#Flux-Balance-Analysis-(FBA)-1",
    "page": "Tutorial",
    "title": "Flux Balance Analysis (FBA)",
    "category": "section",
    "text": "In order to run a flux balance analysis (FBA), distributedFBA can be invoked with only 1 reaction and without an extra condition:# set the reaction list (only one reaction)\nrxnsList = 13\n\n# select the reaction optimization mode\n#  0: only minimization\n#  1: only maximization\n#  2: maximization and minimization\nrxnsOptMode = 1\n\n# launch the distributedFBA process with only 1 reaction on 1 worker\n# distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)\nminFlux, maxFlux  = distributedFBA(model, solver, 1, 90.0, \"\", rxnsList, 0, rxnsOptMode, false);where the reaction number 13 is solved. Note that the no extra conditions are added to the model (last function argument is false). The minimum flux and maximum flux can hence be listed as:maxFlux[rxnsList]"
},

{
    "location": "cobratutorial.html#Flux-Variability-Analysis-(FVA)-1",
    "page": "Tutorial",
    "title": "Flux Variability Analysis (FVA)",
    "category": "section",
    "text": "In order to run a common flux variability analysis (FVA), distributedFBA can be invoked with all reactions as follows:nWorkers = 4\n\n# launch the distributedFBA process with all reactions\n# distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)\nminFlux, maxFlux, optSol, fbaSol, fvamin, fvamax = distributedFBA(model, solver, nWorkers, 90.0, \"max\");The optimal solution of the original FBA problem can be retrieved with:optSolThe corresponding solution vector maxFlux of the original FBA that is solved with:fbaSolThe minimum and maximum fluxes of each reaction are in:maxFluxThe flux vectors of all the reactions are stored in fvamin and fvamax.fvaminfvamax"
},

{
    "location": "cobratutorial.html#Distributed-FBA-of-distinct-reactions-1",
    "page": "Tutorial",
    "title": "Distributed FBA of distinct reactions",
    "category": "section",
    "text": "You may now input several reactions with various rxnsOptMode values to run specific optimization problems.rxnsList = [1;18;10;20:30;90;93;95]\nrxnsOptMode = [0;1;2;2+zeros(Int,length(20:30));2;1;0]\n\n# run only a few reactions with rxnsOptMode and rxnsList\n# distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)\nminFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers, 90.0, \"max\", rxnsList, 0, rxnsOptMode);Note that the reactions can be input as an unordered list."
},

{
    "location": "cobratutorial.html#Save-the-variables-1",
    "page": "Tutorial",
    "title": "Save the variables",
    "category": "section",
    "text": "You can save the output of distributedFBA by using:saveDistributedFBA(\"results.mat\")"
},

{
    "location": "configuration.html#",
    "page": "Configuration",
    "title": "Configuration",
    "category": "page",
    "text": ""
},

{
    "location": "configuration.html#Configuration-1",
    "page": "Configuration",
    "title": "Configuration",
    "category": "section",
    "text": ""
},

{
    "location": "configuration.html#solverCfg.jl-1",
    "page": "Configuration",
    "title": "solverCfg.jl",
    "category": "section",
    "text": "An array with all solver parameters is defined as follows:solParams = [(:parameter, value)]For the CPLEX solver, a list of all CPLEX parameters can be found here"
},

{
    "location": "configuration.html#sshCfg.jl-1",
    "page": "Configuration",
    "title": "sshCfg.jl",
    "category": "section",
    "text": "An array with all connection details to SHH nodes is defined as follows:sshWorkers = Array{Dict{Any, Any}}(1)\n\nsshWorkers[1,:] = Dict( \"usernode\"   => \"first.last@server.com\",\n                        \"procs\"  => 32,\n                        \"dir\"    => `~/COBRA.jl/`,\n                        \"flags\"  => `-4 -p22`,\n                        \"exename\"=> \"/usr/bin/julia/bin/./julia\")Make sure that the size of sshWorkers is properly set."
},

{
    "location": "functions.html#",
    "page": "Modules and Functions",
    "title": "Modules and Functions",
    "category": "page",
    "text": ""
},

{
    "location": "functions.html#Functions-1",
    "page": "Modules and Functions",
    "title": "Functions",
    "category": "section",
    "text": ""
},

{
    "location": "functions.html#createPool",
    "page": "Modules and Functions",
    "title": "createPool",
    "category": "Function",
    "text": "createPool(localWorkers, connectSSHWorkers)\n\nFunction used to create a pool of parallel workers that are either local or connected via SSH.\n\nINPUTS\n\nlocalWorkers:   Number of local workers to connect.                   If connectSSH is true, the number of localWorkers is 1 (host).\n\nOPTIONAL INPUTS\n\nconnectSSH:     Boolean that indicates whether additional nodes should be connected via SSH.                   (default: false)\n\nOUTPUTS\n\nworkers():      Array of IDs of the connected workers (local and SSH workers)\nnWorkers:       Total number of connect workers (local and SSH workers)\n\nEXAMPLES\n\nMinimum working example:\n\njulia> createPool(localWorkers)\n\nSee also: workers(), nprocs(), addprocs(), gethostname()\n\n\n\n"
},

{
    "location": "functions.html#connect.jl-1",
    "page": "Modules and Functions",
    "title": "connect.jl",
    "category": "section",
    "text": "createPool"
},

{
    "location": "functions.html#checkPackage",
    "page": "Modules and Functions",
    "title": "checkPackage",
    "category": "Function",
    "text": "checkPackage(pkgname)\n\nFunction checks whether a package is installed properly or not and returns a boolean value.\n\nINPUTS\n\npkgname:        A string that contains the name of the package to be checked\n\nOUTPUTS\n\n(bool):           A boolean that indicates whether a package is installed properly\n\nSee also: using, isdir()\n\n\n\n"
},

{
    "location": "functions.html#checkSysConfig",
    "page": "Modules and Functions",
    "title": "checkSysConfig",
    "category": "Function",
    "text": "checkSysConfig()\n\nFunction evaluates whether the LP solvers of MathProgBase are installed on the system or not and returns a list of these packages. MathProgBase.jl must be installed.\n\nOUTPUTS\n\npackages:         A list of solver packages installed on the system\n\nSee also: MathProgBase, checkPackage()\n\n\n\n"
},

{
    "location": "functions.html#checkSetup.jl-1",
    "page": "Modules and Functions",
    "title": "checkSetup.jl",
    "category": "section",
    "text": "checkPackage\ncheckSysConfig"
},

{
    "location": "functions.html#preFBA!",
    "page": "Modules and Functions",
    "title": "preFBA!",
    "category": "Function",
    "text": "preFBA!(model, solver, optPercentage, osenseStr, rxnsList)\n\nFunction that solves the original FBA, adds the objective value as a constraint to the stoichiometric matrix of the model, and changes the RHS vector b. Note that the model object is changed.\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\nsolver:         A ::SolverConfig object that contains a valid handle to the solver\n\nOPTIONAL INPUTS\n\noptPercentage:  Only consider solutions that give you at least a certain percentage of the optimal solution (default: 100%)\nosenseStr:      Sets the optimization mode of the original FBA (\"max\" or \"min\", default: \"max\")\nrxnsList:       List of reactions to analyze (default: all reactions)\n\nOUTPUTS\n\nobjValue:       Optimal objective value of the original FBA problem\nfbaSol:         Solution vector that corresponds to the optimal objective value\n\nEXAMPLES\n\nMinimum working example:\n\njulia> preFBA!(model, solver)\n\nFull input/output example\n\njulia> optSol, fbaSol = preFBA!(model, solver, optPercentage, objective)\n\nSee also: solveCobraLP(), distributedFBA()\n\n\n\n"
},

{
    "location": "functions.html#splitRange",
    "page": "Modules and Functions",
    "title": "splitRange",
    "category": "Function",
    "text": "splitRange(model, rxnsList, nWorkers, strategy)\n\nFunction splits a reaction list in blocks for a certain number of workers according to a selected strategy. Generally , splitRange() is called before the FBAs are distributed.\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\nrxnsList:       List of reactions to analyze (default: all reactions)\n\nOPTIONAL INPUTS\n\nnWorkers:       Number of workers as initialized using createPool() or similar\nstrategy:       Number of the splitting strategy\n0: Blind splitting: default random distribution\n1: Extremal dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from both extremal indices of the sorted column density vector\n2: Central dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from the beginning and center indices of the sorted column density vector\n\nOUTPUTS\n\nrxnsKey:        Structure with vector for worker p with start and end indices of each block\n\nEXAMPLES\n\nMinimum working example\n\njulia> splitRange(model, rxnsList, 2)\n\nSelection of the splitting strategy 2 for 4 workers\n\njulia> splitRange(model, rxnsList, 4, 2)\n\nSee also: distributeFBA()\n\n\n\n"
},

{
    "location": "functions.html#loopFBA",
    "page": "Modules and Functions",
    "title": "loopFBA",
    "category": "Function",
    "text": "loopFBA(m, rxnsList, nRxns, pid, iRound, rxnsOptMode)\n\nFunction used to perform a loop of a series of FBA problems using the CPLEX solver Generally, loopFBA is called in a loop over multiple workers and makes use of the CPLEX.jl module.\n\nINPUTS\n\nm:              A MathProgBase.LinearQuadraticModel object with inner field\nsolver:         A ::SolverConfig object that contains a valid handleto the solver\nrxnsList:       List of reactions to analyze (default: all reactions)\nnRxns:          Total number of reaction in the model m.inner\n\nOPTIONAL INPUTS\n\nrxnsOptMode:    List of min/max optimizations to perform:\n0: only minimization\n1: only maximization\n2: minimization & maximization [default: all reactions are minimized and maximized, i.e. 2+zeros(Int,length(model.rxns))]\niRound:         Index of optimization round\n0: minimization\n1: maximization\npid:            Julia ID of launched process\n\nOUTPUTS\n\nretObj:         Vector with optimal (either min or max) solutions (objective values)\nretFlux:        Array of solution vectors corresponding to the vector with the optimal objective values                   (either min or max)\nretStat:        Vector with the status of the solver of each FBA (default: initialized with -1)\n0: LP problem is infeasible\n1: LP problem is optimal\n2: LP problem is unbounded\n3: Solver for the LP problem has hit a user limit\n4: LP problem is infeasible or unbounded\n5: LP problem has a non-documented solution status\n\nEXAMPLES\n\nMinimum working example\n\njulia> loopFBA(m, rxnsList, nRxns)\n\nSee also: distributeFBA(), MathProgBase.HighLevelInterface\n\n\n\n"
},

{
    "location": "functions.html#distributedFBA",
    "page": "Modules and Functions",
    "title": "distributedFBA",
    "category": "Function",
    "text": "distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)\n\nFunction to distribute a series of FBA problems across one or more workers that have been initialized using the createPool function (or similar).\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\nsolver:         A ::SolverConfig object that contains a valid handle to the solver\nnWorkers:       Number of workers as initialized using createPool() or similar\n\nOPTIONAL INPUTS\n\noptPercentage:  Only consider solutions that give you at least a certain percentage of the optimal solution (default: 100%)\nobjective:      Objective (\"min\" or \"max\") (default: \"max\")\nrxnsList:       List of reactions to analyze (default: all reactions)\nstrategy:       Number of the splitting strategy\n0: Blind splitting: default random distribution\n1: Extremal dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from both extremal indices of the sorted column density vector\n2: Central dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from the beginning and center indices of the sorted column density vector\nrxnsOptMode:    List of min/max optimizations to perform:\n0: only minimization\n1: only maximization\n2: minimization & maximization [default: all reactions are minimized and maximized, i.e. 2+zeros(Int,length(model.rxns))]\npreFBA:         Boolean to solve the original FBA and add a percentage condition (default: true)\n\nOUTPUTS\n\nminFlux:          Minimum flux for each reaction\nmaxFlux:          Maximum flux for each reaction\noptSol:           Optimal solution of the initial FBA\nfbaSol:           Solution vector of the initial FBA\nfvamin:           Array with flux values for the considered reactions (minimization)\nfvamax:           Array with flux values for the considered reactions (maximization)\nstatussolmin:     Vector of solution status for each reaction (minimization)\nstatussolmax:     Vector of solution status for each reaction (maximization)\n\nEXAMPLES\n\nMinimum working example\n\njulia> minFlux, maxFlux = distributedFBA(model, solver)\n\nFull input/output example\n\njulia> minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, optPercentage, objective, rxnsList, strategy, rxnsOptMode, true)\n\nSee also: preFBA!(), splitRange(), buildCobraLP(), loopFBA(), or fetch()\n\n\n\n"
},

{
    "location": "functions.html#printSolSummary",
    "page": "Modules and Functions",
    "title": "printSolSummary",
    "category": "Function",
    "text": "printSolSummary(testFile::String, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)\n\nOutput a solution summary\n\nINPUTS\n\noptSol:           Optimal solution of the initial FBA\nminFlux:          Minimum flux for each reaction\nmaxFlux:          Maximum flux for each reaction\nsolTime:          Solution time (in seconds)\nnWorkers:         Number of workers as initialized using createPool() or similar\nsolverName:       Name of the solver\n\nOUTPUTS\n\n(Printed summary)\n\nSee also: norm(), maximum(), minimum()\n\n\n\n"
},

{
    "location": "functions.html#saveDistributedFBA",
    "page": "Modules and Functions",
    "title": "saveDistributedFBA",
    "category": "Function",
    "text": "saveDistributedFBA(fileName::String)\n\nOutput a file with all the output variables of distributedFBA()\n\nINPUTS\n\nfileName:         Filename of the output\n\nOUTPUTS\n\n.mat file with all output variables of distributedFBA()\n\n\n\n"
},

{
    "location": "functions.html#distributedFBA.jl-1",
    "page": "Modules and Functions",
    "title": "distributedFBA.jl",
    "category": "section",
    "text": "preFBA!\nsplitRange\nloopFBA\ndistributedFBA\nprintSolSummary\nsaveDistributedFBA"
},

{
    "location": "functions.html#LPproblem",
    "page": "Modules and Functions",
    "title": "LPproblem",
    "category": "Type",
    "text": "LPproblem(A, b, c, lb, ub, osense, csense, rxns, mets)\n\nGeneral type for storing an LP problem which contains the following fields:\n\nA or S:       LHS matrix (m x n)\nb:              RHS vector (m x 1)\nc:              Objective coefficient vector (n x 1)\nlb:             Lower bound vector (n x 1)\nub:             Upper bound vector (n x 1)\nosense:         Objective sense (scalar; -1 ~ \"max\", +1 ~ \"min\")\ncsense:         Constraint senses (m x 1, 'E' or '=', 'G' or '>', 'L' ~ '<')\nsolver:         A ::SolverConfig object that contains a valid handle to the solver\n\n\n\n"
},

{
    "location": "functions.html#loadModel",
    "page": "Modules and Functions",
    "title": "loadModel",
    "category": "Function",
    "text": "loadModel(fileName, matrixAS, modelName)\n\nFunction used to load a COBRA model from an existing .mat file\n\nINPUTS\n\nfilename:       Name of the .mat file that contains the model structure\n\nOPTIONAL INPUTS\n\nmatrixAS:       String to distinguish the name of stoichiometric matrix (\"S\" or \"A\", default: \"S\")\nmodelName:      String with the name of the model structure (default: \"model\")\nmodelFields:    Array with strings of fields of the model structure (default: [\"ub\", \"lb\", \"osense\", \"c\", \"b\", \"csense\", \"rxns\", \"mets\"])\n\nOUTPUTS\n\nLPproblem()     :LPproblem object with filled fields from .mat file\n\nExamples\n\nMinimum working example\n\njulia> loadModel(\"myModel.mat\")\n\nFull input/output example\n\njulia> model = loadModel(\"myModel.mat\", \"A\", \"myModelName\", [\"ub\",\"lb\",\"osense\",\"c\",\"b\",\"csense\",\"rxns\",\"mets\"]);\n\nNotes\n\nosense is set to \"max\" by default\nAll entries of A, b, c, lb, ub are of type float\n\nSee also: MAT.jl, matopen(), matread()\n\n\n\n"
},

{
    "location": "functions.html#load.jl-1",
    "page": "Modules and Functions",
    "title": "load.jl",
    "category": "section",
    "text": "LPproblem\nloadModel"
},

{
    "location": "functions.html#SolverConfig",
    "page": "Modules and Functions",
    "title": "SolverConfig",
    "category": "Type",
    "text": "SolverConfig(name, handle)\n\nDefinition of a common solver type, which inclues the name of the solver and other parameters\n\nname:           Name of the solver (alias)\nhandle:         Solver handle used to refer to the solver\n\n\n\n"
},

{
    "location": "functions.html#buildCobraLP",
    "page": "Modules and Functions",
    "title": "buildCobraLP",
    "category": "Function",
    "text": "buildCobraLP(model, solver)\n\nBuild a model by interfacing directly with the CPLEX solver\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\nsolver:         A ::SolverConfig object that contains a valid handleto the solver\n\nOUTPUTS\n\nm:              A MathProgBase.LinearQuadraticModel object with inner field\n\nEXAMPLES\n\njulia> m = buildCobraLP(model, solver)\n\nSee also: MathProgBase.LinearQuadraticModel(), MathProgBase.HighLevelInterface.buildlp()\n\n\n\n"
},

{
    "location": "functions.html#changeCobraSolver",
    "page": "Modules and Functions",
    "title": "changeCobraSolver",
    "category": "Function",
    "text": "changeCobraSolver(name, params)\n\nFunction used to change the solver and include the respective solver interfaces\n\nINPUT\n\nname:           Name of the solver (alias)\n\nOPTIONAL INPUT\n\nparams:         Solver parameters as a row vector with tuples\n\nOUTPUT\n\nsolver:         Solver object with a handle field\n\nEXAMPLES\n\nMinimum working example (for the CPLEX solver)\n\njulia> changeCobraSolver(\"CPLEX\", cpxControl)\n\nSee also: MathProgBase.jl\n\n\n\n"
},

{
    "location": "functions.html#solveCobraLP",
    "page": "Modules and Functions",
    "title": "solveCobraLP",
    "category": "Function",
    "text": "solveCobraLP(model, solver)\n\nFunction used to solve a linear program (LP) with a specified solver. LP problem must have the form:\n\n                                  max/min cᵀv\n                                   s.t.  Av = b\n                                        l ⩽ v ⩽ u\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\nsolver:         A ::SolverConfig object that contains a valid handleto the solver\n\nOUTPUTS\n\nsolutionLP:     Solution object of type LPproblem\n\nEXAMPLES\n\nMinimum working example\n\njulia> solveCobraLP(model, solver)\n\nSee also: MathProgBase.linprog(),\n\n\n\n"
},

{
    "location": "functions.html#solve.jl-1",
    "page": "Modules and Functions",
    "title": "solve.jl",
    "category": "section",
    "text": "SolverConfig\nbuildCobraLP\nchangeCobraSolver\nsolveCobraLP"
},

{
    "location": "faq.html#",
    "page": "FAQ",
    "title": "FAQ",
    "category": "page",
    "text": ""
},

{
    "location": "faq.html#Frequently-Asked-Questions-(FAQ)-1",
    "page": "FAQ",
    "title": "Frequently Asked Questions (FAQ)",
    "category": "section",
    "text": ""
},

{
    "location": "faq.html#Why-can't-I-build-packages-in-Julia?-1",
    "page": "FAQ",
    "title": "Why can't I build packages in Julia?",
    "category": "section",
    "text": "In order to build the packages of Julia, cmake must be installed on Unix systems. In addition, csh must be installed in order to open a MATLAB session. Both packages can be installed using system commands (must have sudo rights):$ sudo apt-get install cmake csh"
},

{
    "location": "faq.html#Why-do-the-Julia-instances-on-remote-workers-not-start?-1",
    "page": "FAQ",
    "title": "Why do the Julia instances on remote workers not start?",
    "category": "section",
    "text": "There can be several reasons, but majorly, you must ensure that the Julia configuration on all the nodes is the same than on the host node.Make sure that the lib folder in ~/.julia is the same on the ALL the nodes (.ji files in /.julia/lib/v0.x). The exact (bitwise) same usr/lib/julia/* binaries, which requires copying them to each machine. In order to have the same .ji files on all nodes, it is recommended to copy them from a central storage space (or cloud) to the library folder on the node:cp ~/centralStorage/CPLEX.ji ~/.julia/lib/v0.x/\ncp ~/centralStorage/MathProgBase.ji ~/.julia/lib/v0.x/Once all the .ji have been copied, do not use or build the modules on the nodes. In other words, do not type using CPLEX/MathProgBase at the REPL. Alternatively, you may set JULIA_PKGDIR to a cloud or common storage location."
},

{
    "location": "faq.html#Some-workers-are-dying-how-can-I-avoid-this?-1",
    "page": "FAQ",
    "title": "Some workers are dying - how can I avoid this?",
    "category": "section",
    "text": "Set the enviornment variables explicity on the host in the .bashrc file or /etc/profile.dexport JULIA_WORKER_TIMEOUT=1000;"
},

{
    "location": "faq.html#I-cannot-access-the-SSH-nodes.-What-am-I-doing-wrong?-1",
    "page": "FAQ",
    "title": "I cannot access the SSH nodes. What am I doing wrong?",
    "category": "section",
    "text": "You must have configured your ssh keys in order to be able to access the nodes, or you must access the nodes without credentials."
},

{
    "location": "faq.html#My-machine-is-a-Windows-machine,-and-everything-is-so-slow.-What-can-I-do?-1",
    "page": "FAQ",
    "title": "My machine is a Windows machine, and everything is so slow. What can I do?",
    "category": "section",
    "text": "Some Windows users may have to wait a while when installing Julia. The performance of COBRA.jl is unaffected by this relatively long load time. However, you may try these avenues of fixing this:Try setting the git parameters correctly (using git bash that you can download from here):git config --global core.preloadindex true\ngit config --global core.fscache true\ngit config --global gc.auto 256Make sure that you set the following environment variables correctly:set JULIA_PKGDIR=C:\\Users\\<yourUsername>\\.julia\\v0.5\nset HOME=C:\\Users\\<yourUsername>\\AppData\\Local\\Julia-0.5.0Make sure that the .julia folder is not located on a network. This slows the processes in Julia down dramatically."
},

{
    "location": "contents.html#",
    "page": "Index",
    "title": "Index",
    "category": "page",
    "text": ""
},

{
    "location": "contents.html#Index-1",
    "page": "Index",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
