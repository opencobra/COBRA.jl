var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "category": "page",
    "text": "(Image: COBRA logo)"
},

{
    "location": "index.html#COBRA.jl-COnstraint-Based-Reconstruction-and-Analysis-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "category": "section",
    "text": "Documentation Coverage Continuous integration - ARTENOLIS\n(Image: ) (Image: coverage status) (Image: linux) (Image: macOS) (Image: windows10)COBRA.jl is a package written in Julia used to perform COBRA analyses such as Flux Balance Anlysis (FBA), Flux Variability Anlysis (FVA), or any of its associated variants such as distributedFBA [1].FBA and FVA rely on the solution of LP problems. The package can be used with ease when the LP problem is defined in a .mat file according to the format outlined in the COBRA Toolbox [2]."
},

{
    "location": "index.html#Installation-of-COBRA.jl-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Installation of COBRA.jl",
    "category": "section",
    "text": "If you are new to Julia, you may find the Beginner\'s Guide interesting. A working installation of Julia is required.At the Julia prompt, add the COBRA package:julia> Pkg.add(\"COBRA\")Use the COBRA.jl module by running:julia> using COBRACOBRA.jl has been tested on Julia v0.5+ on Ubuntu Linux 14.04+, MacOS 10.7+, and Windows 7 (64-bit). All solvers supported by MathProgBase.jl are supported by COBRA.jl, but must be installed separately. A COBRA model saved as a .mat file can be read in using MAT.jl. MathProgBase.jl and MAT.jl are automatically installed during the installation of the COBRA.jl package."
},

{
    "location": "index.html#Tutorial,-documentation-and-FAQ-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Tutorial, documentation and FAQ",
    "category": "section",
    "text": "The comprehensive tutorial is based on the interactive Jupyter notebook.The COBRA.jl package is fully documented here. You may also display the documentation in the Julia REPL:julia> ? distributedFBA:bulb: Should you encounter any errors or unusual behavior, please refer first to the FAQ section or open an issue."
},

{
    "location": "index.html#Testing-and-benchmarking-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "Testing and benchmarking",
    "category": "section",
    "text": "You can test the package using:julia> Pkg.test(\"COBRA\")Shall no solvers be detected on your system, error messages may be thrown when testing the COBRA.jl package.The code has been benchmarked against the fastFVA implementation [3]. A test model ecoli_core_model.mat [4] can be used to pre-compile the code and can be downloaded usingjulia> using Requests\njulia> include(\"$(Pkg.dir(\"COBRA\"))/test/getTestModel.jl\")\njulia> getTestModel()"
},

{
    "location": "index.html#How-to-cite-distributedFBA.jl?-1",
    "page": "COBRA.jl - COnstraint-Based Reconstruction and Analysis",
    "title": "How to cite distributedFBA.jl?",
    "category": "section",
    "text": "The corresponding paper can be downloaded from here. You may cite distributedFBA.jl as follows:Laurent Heirendt, Ines Thiele, Ronan M. T. Fleming; DistributedFBA.jl: high-level, high-performance flux balance analysis in Julia. Bioinformatics 2017 btw838. doi: 10.1093/bioinformatics/btw838"
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
    "text": "B. O. Palsson., Systems Biology: Constraint-based Reconstruction and Analysis. Cambridge University Press, NY, 2015.\nHeirendt, L. and Arreckx, S. et al., Creation and analysis of biochemical constraint-based models: the COBRA Toolbox v3.0 (submitted), 2017, arXiv:1710.04038.\nSteinn, G. et al., Computationally efficient flux variability analysis. BMC Bioinformatics, 11(1):1–3, 2010.\nOrth, J. et al., Reconstruction and use of microbial metabolic networks: the core escherichia coli metabolic model as an educational guide. EcoSal Plus, 2010."
},

{
    "location": "beginnerGuide.html#",
    "page": "Beginner\'s Guide",
    "title": "Beginner\'s Guide",
    "category": "page",
    "text": ""
},

{
    "location": "beginnerGuide.html#Beginner\'s-Guide-1",
    "page": "Beginner\'s Guide",
    "title": "Beginner\'s Guide",
    "category": "section",
    "text": ""
},

{
    "location": "beginnerGuide.html#What-is-Julia?-1",
    "page": "Beginner\'s Guide",
    "title": "What is Julia?",
    "category": "section",
    "text": "\"Julia is a high-level, high-performance dynamic programming language […]\". You may read more about Julia here."
},

{
    "location": "beginnerGuide.html#How-do-I-get-Julia?-1",
    "page": "Beginner\'s Guide",
    "title": "How do I get Julia?",
    "category": "section",
    "text": "You may download Julia as explained here. Please read through the Julia documentation if this is your first time trying out Julia."
},

{
    "location": "beginnerGuide.html#How-do-I-use-Julia?-1",
    "page": "Beginner\'s Guide",
    "title": "How do I use Julia?",
    "category": "section",
    "text": "On Windows, click on the executable .exe to start Julia. You may launch Julia on Linux or macOS by in a terminal window:juliaYou should then see the prompt of Julia:julia>You are now in the so-called REPL. Here, you can type all Julia-commands. You can quit Julia by typingjulia> quit()or hitting CTRL-d."
},

{
    "location": "beginnerGuide.html#What-if-I-need-help?-1",
    "page": "Beginner\'s Guide",
    "title": "What if I need help?",
    "category": "section",
    "text": "If you need help, you can always type a ?at the Julia REPL. For instance, if you require assistance with the abs (absolute value) function, you may type (in the Julia REPL next to julia>):? absYou may also find the FAQ section of this documentation interesting, especially if you are running into issues."
},

{
    "location": "beginnerGuide.html#How-do-I-install-a-solver?-1",
    "page": "Beginner\'s Guide",
    "title": "How do I install a solver?",
    "category": "section",
    "text": "Please make sure that you have at least one of the supported solvers installed on your system.In order to get you started, you may install the Clp solver using:julia> Pkg.add(\"Clp\")This might take a while, as the Clp solver is downloaded to your system and then installed."
},

{
    "location": "beginnerGuide.html#What-if-I-want-another-solver?-1",
    "page": "Beginner\'s Guide",
    "title": "What if I want another solver?",
    "category": "section",
    "text": "As an example, and in order to get you started quickly, you may install the GLPK solver. On Windows, please follow these instructions. You must have cmake installed and gcc as described here and here.On Linux, type:sudo apt-get install cmake glpk-utils python-glpk libgmp-dev hdf5-toolsOn macOS, you may install GLPK by using brew:brew install glpkIn order to be able to use the GLPK solver, you must add the GLPKMathProgInterface and GLPK packages (see their respective GitHub pages here and here):Pkg.add(\"GLPK\")\nPkg.add(\"GLPKMathProgInterface\")Other supported solvers, such as CPLEX, Clp, Gurobi, or Mosek, may be installed in a similar way. Their respective interfaces are described here. If you want to use CPLEX, you must follow the installation instructions here. Most importantly, make sure that you set the LD_LIBRARY_PATH environment variable."
},

{
    "location": "beginnerGuide.html#Now-I-have-a-solver,-and-I-have-Julia.-What-is-next?-1",
    "page": "Beginner\'s Guide",
    "title": "Now I have a solver, and I have Julia. What is next?",
    "category": "section",
    "text": "You are now all set to install COBRA.jl. Follow the installation instructions here. You may then also follow this tutorial to get you started."
},

{
    "location": "beginnerGuide.html#There-is-a-tutorial,-but-I-cannot-open-it.-What-should-I-do?-1",
    "page": "Beginner\'s Guide",
    "title": "There is a tutorial, but I cannot open it. What should I do?",
    "category": "section",
    "text": "If you wish to install Jupyter notebook on your own system, you may download Jupyter notebook from here.Please make sure that you have at least Julia 0.5 as a kernel when running the Jupyter notebook. You may install the Julia kernel by launching Julia and running the following command from within the Julia REPL (as explained here):Pkg.add(\"IJulia\")You have a working kernel if you see in the top right corner the name of the Julia kernel (Julia 0.5).Please note that before adding the IJulia package, you must have followed the Jupyter installation instructions. If you are running into any issue running this tutorial on either Jupyter notebook, try it out locally by downloading first Julia as explained here.Now, you can start the Jupyter notebook. On Linux, you may start Jupyter with:jupyter notebookYou are all set and can run the tutorial."
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
    "text": "This tutorial serves as a quick start guide as well as an interactive reference for more advanced users. Download the live notebook here."
},

{
    "location": "cobratutorial.html#Installation-1",
    "page": "Tutorial",
    "title": "Installation",
    "category": "section",
    "text": "If you do not already have the COBRA.jl package installed, you must first first follow the installation instructions here.Please note that should you run this tutorial on an already configured system. Otherwise, the following lines will throw an error message.Before running any function of COBRA.jl, it is necessary to include the COBRA.jl module:using COBRAYou can test your system by running:COBRA.checkSysConfig();"
},

{
    "location": "cobratutorial.html#Beginner\'s-Guide-1",
    "page": "Tutorial",
    "title": "Beginner\'s Guide",
    "category": "section",
    "text": "Should you not have any prior experience with Julia and/or Linux, read carefully the Beginner\'s Guide. If you however feel that you are set to proceed with this tutorial, please consider the Beginner\'s Guide as a go-to reference in case you are running into any issues. If you see unusual behavior, you may consider reading the FAQ section."
},

{
    "location": "cobratutorial.html#Quick-help-1",
    "page": "Tutorial",
    "title": "Quick help",
    "category": "section",
    "text": "Do you feel lost or you don’t know the meaning of certain input parameters? Try typing a question mark at the Julia REPL followed by a keyword. For instance:julia> ? distributedFBA"
},

{
    "location": "cobratutorial.html#Installation-check-and-package-testing-1",
    "page": "Tutorial",
    "title": "Installation check and package testing",
    "category": "section",
    "text": "Make sure that you have a working installation of MathProgBase.jl and at least one of the supported solvers. You may find further information here. If you want to install other solvers such as CPLEX, CLP, Gurobi, or Mosek, you can find more information here.You may, at any time, check the integrity of the COBRA.jl package by running:julia> Pkg.test(\"COBRA\")The code has been benchmarked against the fastFVA implementation [3]. The modules and solvers are correctly installed when all tests pass without errors (warnings may appear)."
},

{
    "location": "cobratutorial.html#Adding-local-workers-1",
    "page": "Tutorial",
    "title": "Adding local workers",
    "category": "section",
    "text": "The connection functions are given in connect.jl, which, if a parallel version is desired, must be included separately:include(\"$(Pkg.dir(\"COBRA\"))/src/connect.jl\")You may add local workers as follows:# specify the total number of parallel workers\nnWorkers = 4 \n\n# create a parallel pool\nworkersPool, nWorkers = createPool(nWorkers) The IDs of the respective workers are given in workersPool, and the number of local workers is stored in nWorkers.In order to be able to use the COBRA module on all connected workers, you must invoke:@everywhere using COBRA;"
},

{
    "location": "cobratutorial.html#Define-and-change-the-COBRA-solver-1",
    "page": "Tutorial",
    "title": "Define and change the COBRA solver",
    "category": "section",
    "text": "Before the COBRA solver can be defined, the solver parameters and configuration must be loaded after having set the solverName (solver must be installed)::GLPKMathProgInterface\n:CPLEX\n:Clp\n:Gurobi\n:Mosek# specify the solver name\nsolverName = :GLPKMathProgInterface\n\n# include the solver configuration file\ninclude(\"$(Pkg.dir(\"COBRA\"))/config/solverCfg.jl\")# change the COBRA solver\nsolver = changeCobraSolver(solverName, solParams)where solParams is an array with the definition of the solver parameters."
},

{
    "location": "cobratutorial.html#Load-a-COBRA-model-1",
    "page": "Tutorial",
    "title": "Load a COBRA model",
    "category": "section",
    "text": "As a test and as an example, the E.coli core model may be loaded as:# download the test model\nusing Requests\ninclude(\"$(Pkg.dir(\"COBRA\"))/test/getTestModel.jl\")\ngetTestModel()Load the stoichiometric matrix S from a MATLAB structure named model in the specified .mat filemodel = loadModel(\"ecoli_core_model.mat\", \"S\", \"model\");where S is the name of the field of the stoichiometric matrix and model is the name of the model. Note the semicolon that suppresses the ouput of model."
},

{
    "location": "cobratutorial.html#Flux-Balance-Analysis-(FBA)-1",
    "page": "Tutorial",
    "title": "Flux Balance Analysis (FBA)",
    "category": "section",
    "text": "In order to run a flux balance analysis (FBA), distributedFBA can be invoked with only 1 reaction and without an extra condition:# set the reaction list (only one reaction)\nrxnsList = 13\n\n# select the reaction optimization mode\n#  0: only minimization\n#  1: only maximization\n#  2: maximization and minimization\nrxnsOptMode = 1\n\n# launch the distributedFBA process with only 1 reaction on 1 worker\nminFlux, maxFlux  = distributedFBA(model, solver, nWorkers=1, rxnsList=rxnsList, rxnsOptMode=rxnsOptMode);where the reaction number 13 is solved. Note that the no extra conditions are added to the model (last function argument is false). The minimum flux and maximum flux can hence be listed as:maxFlux[rxnsList]"
},

{
    "location": "cobratutorial.html#Flux-Variability-Analysis-(FVA)-1",
    "page": "Tutorial",
    "title": "Flux Variability Analysis (FVA)",
    "category": "section",
    "text": "In order to run a common flux variability analysis (FVA), distributedFBA can be invoked with all reactions as follows:# launch the distributedFBA process with all reactions\nminFlux, maxFlux, optSol, fbaSol, fvamin, fvamax = distributedFBA(model, solver, nWorkers=4, optPercentage=90.0, preFBA=true);The optimal solution of the original FBA problem can be retrieved with:optSolThe corresponding solution vector maxFlux of the original FBA that is solved with:fbaSolThe minimum and maximum fluxes of each reaction are in:maxFluxThe flux vectors of all the reactions are stored in fvamin and fvamax.fvaminfvamax"
},

{
    "location": "cobratutorial.html#Distributed-FBA-of-distinct-reactions-1",
    "page": "Tutorial",
    "title": "Distributed FBA of distinct reactions",
    "category": "section",
    "text": "You may now input several reactions with various rxnsOptMode values to run specific optimization problems.rxnsList = [1; 18; 10; 20:30; 90; 93; 95]\nrxnsOptMode = [0; 1; 2; 2+zeros(Int, length(20:30)); 2; 1; 0]\n\n# run only a few reactions with rxnsOptMode and rxnsList\n# distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, preFBA, rxnsOptMode)\nminFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver);Note that the reactions can be input as an unordered list."
},

{
    "location": "cobratutorial.html#Saving-the-variables-1",
    "page": "Tutorial",
    "title": "Saving the variables",
    "category": "section",
    "text": "You can save the output of distributedFBA by using:saveDistributedFBA(\"results.mat\")Note that the results are saved in a .mat file that can be opened in MATLAB for further processing."
},

{
    "location": "cobratutorial.html#Cleanup-1",
    "page": "Tutorial",
    "title": "Cleanup",
    "category": "section",
    "text": "In order to cleanup the files generated during this tutorial, you can remove the files using:rm(\"ecoli_core_model.mat\")\nrm(\"results.mat\")"
},

{
    "location": "cobratutorial.html#References-1",
    "page": "Tutorial",
    "title": "References",
    "category": "section",
    "text": "B. O. Palsson. Systems Biology: Constraint-based Reconstruction and Analysis. Cambridge University Press, NY, 2015.\nSchellenberger, J. et al. COBRA Toolbox 2.0. 05 2011.\nSteinn, G. et al. Computationally efficient flux variability analysis. BMC Bioinformatics, 11(1):1–3, 2010.\nOrth, J. et al. Reconstruction and use of microbial metabolic networks: the core escherichia coli metabolic model as an educational guide. EcoSal Plus, 2010."
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
    "location": "configuration.html#Solver-configuration-parameters:-solverCfg.jl-1",
    "page": "Configuration",
    "title": "Solver configuration parameters: solverCfg.jl",
    "category": "section",
    "text": "In order to load currently defined solver parameters, the following file may be included in the script, which defines the solParams array:include(\"$(Pkg.dir(\"COBRA\"))/config/solverCfg.jl\")Then, the COBRA solver can be set with:solver = changeCobraSolver(solverName, solParams);If specific solver parameters should be set, the file solverCfg.jl may also be edited, or a new file mySolverCfg.jl can be created in the folder config loaded as:include(\"config/mySolverCfg.jl\")The solver can then be set in a similar way with the additional argument solParams in changeCobraSolver.In general, an array with all solver parameters is defined as follows:solParams = [(:parameter, value)]For the CPLEX solver, a list of all CPLEX parameters can be found here. The array of solver parameters can be defined as follows:solParams = [\n    # decides whether or not results are displayed on screen in an application of the C API.\n    (:CPX_PARAM_SCRIND,         0);\n\n    # sets the parallel optimization mode. Possible modes are automatic, deterministic, and opportunistic.\n    (:CPX_PARAM_PARALLELMODE,   1);\n\n    # sets the default maximal number of parallel threads that will be invoked by any CPLEX parallel optimizer.\n    (:CPX_PARAM_THREADS,        1);\n\n    # partitions the number of threads for CPLEX to use for auxiliary tasks while it solves the root node of a problem.\n    (:CPX_PARAM_AUXROOTTHREADS, 2);\n\n    # decides how to scale the problem matrix.\n    (:CPX_PARAM_SCAIND,         1);\n\n    # controls which algorithm CPLEX uses to solve continuous models (LPs).\n    (:CPX_PARAM_LPMETHOD,       0)\n] #end of solParams"
},

{
    "location": "configuration.html#SSH-connection-details:-sshCfg.jl-1",
    "page": "Configuration",
    "title": "SSH connection details: sshCfg.jl",
    "category": "section",
    "text": "A parallel pool with workers on SSH nodes can be created using:include(\"$(Pkg.dir(\"COBRA\"))/src/connect.jl\")\nworkersPool, nWorkers = createPool(12, true, \"mySSHCfg.jl\")which will connect 12 local workers, and all workers defined in mySSHCfg.jl. An example connection file is provided in the config/ folder of the COBRA package installation folder.An array with all connection details to SSH nodes is defined as follows:sshWorkers = Array{Dict{Any, Any}}(1)\n\nsshWorkers[1,:] = Dict( \"usernode\"   => \"first.last@server.com\",\n                        \"procs\"  => 32,\n                        \"dir\"    => `~/COBRA.jl/`,\n                        \"flags\"  => `-4 -p22`,\n                        \"exename\"=> \"/usr/bin/julia/bin/./julia\")Make sure that the size of sshWorkers is properly set."
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
    "category": "function",
    "text": "createPool(localWorkers, connectSSHWorkers, connectionFile)\n\nFunction used to create a pool of parallel workers that are either local or connected via SSH.\n\nINPUTS\n\nlocalWorkers:   Number of local workers to connect.                   If connectSSH is true, the number of localWorkers is 1 (host).\n\nOPTIONAL INPUTS\n\nconnectSSH:     Boolean that indicates whether additional nodes should be connected via SSH.                   (default: false)\nconnectionFile  Name of the file with the SSH connection details (default: config/sshCfg.jl in the COBRA package installation folder)\n\nOUTPUTS\n\nworkers():      Array of IDs of the connected workers (local and SSH workers)\nnWorkers:       Total number of connect workers (local and SSH workers)\n\nEXAMPLES\n\nMinimum working example:\n\njulia> createPool(localWorkers)\n\nLocal workers and workers on SSH nodes can be connected as follows:\n\nworkersPool, nWorkers = createPool(12, true, \"mySSHCfg.jl\")\n\nwhich will connect 12 local workers, and all workers defined in mySSHCfg.jl. An example connection file is provided in the config/ folder of the COBRA package installation folder.\n\nSee also: workers(), nprocs(), addprocs(), gethostname()\n\n\n\n"
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
    "category": "function",
    "text": "checkPackage(pkgName)\n\nFunction checks whether a package is installed properly or not and returns a boolean value.\n\nINPUTS\n\npkgName:        A string that contains the name of the package to be checked\n\nOPTIONAL INPUTS\n\nverbose:        Verbose mode:\n0: off (quiet)\n1: on (default)\n\nOUTPUTS\n\n(bool):           A boolean that indicates whether a package is installed properly\n\nSee also: using, isdir()\n\n\n\n"
},

{
    "location": "functions.html#checkSysConfig",
    "page": "Modules and Functions",
    "title": "checkSysConfig",
    "category": "function",
    "text": "checkSysConfig()\n\nFunction evaluates whether the LP solvers of MathProgBase are installed on the system or not and returns a list of these packages. MathProgBase.jl must be installed.\n\nOPTIONAL INPUTS\n\nverbose:        Verbose mode:\n0: off (quiet)\n1: on (default)\n\nOUTPUTS\n\npackages:         A list of solver packages installed on the system\n\nSee also: MathProgBase, checkPackage()\n\n\n\n"
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
    "category": "function",
    "text": "preFBA!(model, solver, optPercentage, osenseStr, rxnsList)\n\nFunction that solves the original FBA, adds the objective value as a constraint to the stoichiometric matrix of the model, and changes the RHS vector b. Note that the model object is changed.\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\nsolver:         A ::SolverConfig object that contains a valid handle to the solver\n\nOPTIONAL INPUTS\n\noptPercentage:  Only consider solutions that give you at least a certain percentage of the optimal solution (default: 0%)\nosenseStr:      Sets the optimization mode of the original FBA (\"max\" or \"min\", default: \"max\")\nrxnsList:       List of reactions to analyze (default: all reactions)\n\nOUTPUTS\n\nobjValue:       Optimal objective value of the original FBA problem\nfbaSol:         Solution vector that corresponds to the optimal objective value\n\nEXAMPLES\n\nMinimum working example:\n\njulia> preFBA!(model, solver)\n\nFull input/output example\n\njulia> optSol, fbaSol = preFBA!(model, solver, optPercentage, objective)\n\nSee also: solveCobraLP(), distributedFBA()\n\n\n\n"
},

{
    "location": "functions.html#splitRange",
    "page": "Modules and Functions",
    "title": "splitRange",
    "category": "function",
    "text": "splitRange(model, rxnsList, nWorkers, strategy)\n\nFunction splits a reaction list in blocks for a certain number of workers according to a selected strategy. Generally , splitRange() is called before the FBAs are distributed.\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\nrxnsList:       List of reactions to analyze (default: all reactions)\n\nOPTIONAL INPUTS\n\nnWorkers:       Number of workers as initialized using createPool() or similar\nstrategy:       Number of the splitting strategy\n0: Blind splitting: default random distribution\n1: Extremal dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from both extremal indices of the sorted column density vector\n2: Central dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from the beginning and center indices of the sorted column density vector\n\nOUTPUTS\n\nrxnsKey:        Structure with vector for worker p with start and end indices of each block\n\nEXAMPLES\n\nMinimum working example\n\njulia> splitRange(model, rxnsList, 2)\n\nSelection of the splitting strategy 2 for 4 workers\n\njulia> splitRange(model, rxnsList, 4, 2)\n\nSee also: distributeFBA()\n\n\n\n"
},

{
    "location": "functions.html#loopFBA",
    "page": "Modules and Functions",
    "title": "loopFBA",
    "category": "function",
    "text": "loopFBA(m, rxnsList, nRxns, rxnsOptMode, iRound, pid, resultsDir, logFiles, onlyFluxes)\n\nFunction used to perform a loop of a series of FBA problems using the CPLEX solver Generally, loopFBA is called in a loop over multiple workers and makes use of the CPLEX.jl module.\n\nINPUTS\n\nm:              A MathProgBase.LinearQuadraticModel object with inner field\nsolver:         A ::SolverConfig object that contains a valid handleto the solver\nrxnsList:       List of reactions to analyze (default: all reactions)\nnRxns:          Total number of reaction in the model m.inner\n\nOPTIONAL INPUTS\n\nrxnsOptMode:    List of min/max optimizations to perform:\n0: only minimization\n1: only maximization\n2: minimization & maximization [default: all reactions are minimized and maximized, i.e. 2+zeros(Int,length(model.rxns))]\niRound:         Index of optimization round\n0: minimization\n1: maximization\npid:            Julia ID of launched process\nresultsDir:     Path to results folder (default is a results folder in the Julia package directory)\nlogFiles:       (only available for CPLEX) Boolean to write a solver logfile of each optimization (default: false)\nonlyFluxes:     Save only minFlux and maxFlux if true and will return placeholders for fvamin, fvamax, statussolmin, or statussolmax (applicable for quick checks of large models, default: false)\n\nOUTPUTS\n\nretObj:         Vector with optimal (either min or max) solutions (objective values)\nretFlux:        Array of solution vectors corresponding to the vector with the optimal objective values                   (either min or max)\nretStat:        Vector with the status of the solver of each FBA (default: initialized with -1)\n0:   LP problem is infeasible\n1:   LP problem is optimal\n2:   LP problem is unbounded\n3:   Solver for the LP problem has hit a user limit\n4:   LP problem is infeasible or unbounded\n5:   LP problem has a non-documented solution status\n< 0: returned original solution status of solver (only CPLEX supported)\n\nEXAMPLES\n\nMinimum working example\n\njulia> loopFBA(m, rxnsList, nRxns)\n\nSee also: distributeFBA(), MathProgBase.HighLevelInterface\n\n\n\n"
},

{
    "location": "functions.html#distributedFBA",
    "page": "Modules and Functions",
    "title": "distributedFBA",
    "category": "function",
    "text": "distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, rxnsOptMode, preFBA, saveChunks, resultsDir, logFiles, onlyFluxes)\n\nFunction to distribute a series of FBA problems across one or more workers that have been initialized using the createPool function (or similar).\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\nsolver:         A ::SolverConfig object that contains a valid handle to the solver\nnWorkers:       Number of workers as initialized using createPool() or similar\n\nOPTIONAL INPUTS\n\noptPercentage:  Only consider solutions that give you at least a certain percentage of the optimal solution (default: 0%).\nobjective:      Objective (\"min\" or \"max\") (default: \"max\")\nrxnsList:       List of reactions to analyze (default: all reactions)\nstrategy:       Number of the splitting strategy\n0: Blind splitting: default random distribution\n1: Extremal dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from both extremal indices of the sorted column density vector\n2: Central dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from the beginning and center indices of the sorted column density vector\nrxnsOptMode:    List of min/max optimizations to perform:\n0: only minimization\n1: only maximization\n2: minimization & maximization [default: all reactions are minimized and maximized, i.e. 2+zeros(Int,length(model.rxns))]\npreFBA:         Solve the original FBA and add a percentage condition (Boolean variable, default: false). Set to true for flux variability analysis.\nsaveChunks:     Save the fluxes of the minimizations and maximizations in individual files on each worker (applicable for large models, default: false)\nresultsDir:     Path to results folder (default is a results folder in the Julia package directory)\nlogFiles:       Boolean to write a solver logfile of each optimization (folder resultsDir/logs is automatically created. default: false)\nonlyFluxes:     Save only minFlux and maxFlux if true and will return placeholders for fvamin, fvamax, statussolmin, or statussolmax (applicable for quick checks of large models, default: false)\n\nOUTPUTS\n\nminFlux:        Minimum flux for each reaction\nmaxFlux:        Maximum flux for each reaction\noptSol:         Optimal solution of the initial FBA (if preFBA set to true)\nfbaSol:         Solution vector of the initial FBA (if preFBA set to true)\nfvamin:         Array with flux values for the considered reactions (minimization) (if onlyFluxes set to false)     Note: fvamin is saved in individual .mat files when saveChunks is true.\nfvamax:         Array with flux values for the considered reactions (maximization) (if onlyFluxes set to false)     Note: fvamax is saved in individual .mat files when saveChunks is true.\nstatussolmin:   Vector of solution status for each reaction (minimization) (if onlyFluxes set to false)\nstatussolmax:   Vector of solution status for each reaction (maximization) (if onlyFluxes set to false)\n\nEXAMPLES\n\nMinimum working example\n\njulia> minFlux, maxFlux = distributedFBA(model, solver)\n\nFlux variability analysis with optPercentage = 90% (on 4 workers)\n\njulia> minFlux, maxFlux = distributedFBA(model, solver, nWorkers=4, optPercentage=90.0, preFBA=true)\n\nFull input/output example\n\njulia> minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, logFiles=true)\n\nSave only the fluxes\n\njulia> minFlux, maxFlux = distributedFBA(model, solver, preFBA=true, saveChunks=false, onlyFluxes=true)\n\nSave flux vectors in files\n\njulia> minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver)\n\nSee also: preFBA!(), splitRange(), buildCobraLP(), loopFBA(), or fetch()\n\n\n\n"
},

{
    "location": "functions.html#printSolSummary",
    "page": "Modules and Functions",
    "title": "printSolSummary",
    "category": "function",
    "text": "printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName, strategy, saveChunks)\n\nOutput a solution summary\n\nINPUTS\n\ntestFile:       Name of the .mat test file\noptSol:         Optimal solution of the initial FBA\nminFlux:        Minimum flux for each reaction\nmaxFlux:        Maximum flux for each reaction\nsolTime:        Solution time (in seconds)\nnWorkers:       Number of workers as initialized using createPool() or similar\nsolverName:     Name of the solver\nstrategy:       Number of the splitting strategy\n0: Blind splitting: default random distribution\n1: Extremal dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from both extremal indices of the sorted column density vector\n2: Central dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from the beginning and center indices of the sorted column density vector\nsaveChunks:     Save the fluxes of the minimizations and maximizations in individual files on each worker (applicable for large models)\n\nOUTPUTS\n\n(Printed summary)\n\nSee also: norm(), maximum(), minimum()\n\n\n\n"
},

{
    "location": "functions.html#saveDistributedFBA",
    "page": "Modules and Functions",
    "title": "saveDistributedFBA",
    "category": "function",
    "text": "saveDistributedFBA(fileName::String, vars)\n\nOutput a file with all the output variables of distributedFBA() and rxnsList\n\nINPUTS\n\nfileName:         Filename of the output\nvars:             List of variables (default: [\"minFlux\", \"maxFlux\", \"optSol\", \"fbaSol\", \"fvamin\", \"fvamax\", \"statussolmin\", \"statussolmax\", \"rxnsList\"])\n\nOUTPUTS\n\n.mat file with the specified output variables\n\nEXAMPLES\n\nMinimum working example\n\njulia> saveDistributedFBA(\"myResults.mat\")\n\nFile location\n\njulia> saveDistributedFBA(\"myDirectory/myResults.mat\")\n\nHome location\n\njulia> saveDistributedFBA(ENV[\"HOME\"]*\"/myResults.mat\")\n\nSave minFlux and maxFlux variables\n\njulia> saveDistributedFBA(ENV[\"HOME\"]*\"/myResults.mat\", [\"minFlux\", \"maxFlux\"])\n\n\n\n"
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
    "category": "type",
    "text": "LPproblem(S, b, c, lb, ub, osense, csense, rxns, mets)\n\nGeneral type for storing an LP problem which contains the following fields:\n\nS:              LHS matrix (m x n)\nb:              RHS vector (m x 1)\nc:              Objective coefficient vector (n x 1)\nlb:             Lower bound vector (n x 1)\nub:             Upper bound vector (n x 1)\nosense:         Objective sense (scalar; -1 ~ \"max\", +1 ~ \"min\")\ncsense:         Constraint senses (m x 1, \'E\' or \'=\', \'G\' or \'>\', \'L\' ~ \'<\')\nsolver:         A ::SolverConfig object that contains a valid handle to the solver\n\n\n\n"
},

{
    "location": "functions.html#loadModel",
    "page": "Modules and Functions",
    "title": "loadModel",
    "category": "function",
    "text": "loadModel(fileName, matrixAS, modelName, modelFields)\n\nFunction used to load a COBRA model from an existing .mat file\n\nINPUTS\n\nfilename:       Name of the .mat file that contains the model structure\n\nOPTIONAL INPUTS\n\nmatrixAS:       String to distinguish the name of stoichiometric matrix (\"S\" or \"A\", default: \"S\")\nmodelName:      String with the name of the model structure (default: \"model\")\nmodelFields:    Array with strings of fields of the model structure (default: [\"ub\", \"lb\", \"osense\", \"c\", \"b\", \"csense\", \"rxns\", \"mets\"])\n\nOUTPUTS\n\nLPproblem()     :LPproblem object with filled fields from .mat file\n\nExamples\n\nMinimum working example\n\njulia> loadModel(\"myModel.mat\")\n\nFull input/output example\n\njulia> model = loadModel(\"myModel.mat\", \"A\", \"myModelName\", [\"ub\",\"lb\",\"osense\",\"c\",\"b\",\"csense\",\"rxns\",\"mets\"]);\n\nNotes\n\nosense is set to \"max\" (osense = -1) by default\nAll entries of A, b, c, lb, ub are of type float\n\nSee also: MAT.jl, matopen(), matread()\n\n\n\n"
},

{
    "location": "functions.html#load.jl-1",
    "page": "Modules and Functions",
    "title": "load.jl",
    "category": "section",
    "text": "LPproblem\nloadModel"
},

{
    "location": "functions.html#shareLoad",
    "page": "Modules and Functions",
    "title": "shareLoad",
    "category": "function",
    "text": "shareLoad(nModels, nMatlab, verbose)\n\nFunction shares the number of nModels across nMatlab sessions (Euclidian division)\n\nINPUTS\n\nnModels:         Number of models to be run\n\nOPTIONAL INPUTS\n\nnMatlab:         Number of desired MATLAB sessions (default: 2)\nverbose:         Verbose mode, set false for quiet load sharing (default: true)\n\nOUTPUTS\n\nnWorkers:        Number of effective workers in the parallel pool; corresponds to nMatlab if nMatlab < nModels and to nModels otherwise\nquotientModels:  Rounded number of models to be run by all MATLAB sessions apart from the last one\nremainderModels: Number of remaining models to be run by the last MATLAB session\n\nEXAMPLES\n\nMinimum working example\n\njulia> shareLoad(nModels)\n\nDetermination of the load of 4 models in 2 MATLAB sessions\n\njulia> shareLoad(4, 2, false)\n\nSee also: createPool() and PALM\n\n\n\n"
},

{
    "location": "functions.html#loopModels",
    "page": "Modules and Functions",
    "title": "loopModels",
    "category": "function",
    "text": "loopModels(dir, p, scriptName, dirContent, startIndex, endIndex, varsCharact)\n\nFunction loopModels is generally called in a loop from PALM() on worker p. Runs scriptName for all models with an index in dirContent between startIndex and endIndex. Retrieves all variables defined in varsCharact. The number of models on worker p is computed as nModels = endIndex - startIndex + 1.\n\nINPUTS\n\ndir:            Directory that contains the models (model file format: .mat)\np:              Process or worker number\nscriptName:     Name of MATLAB script to be run (without extension .m)\ndirContent:     Array with file names (commonly read from a directory)\nstartIndex:     Index of the first model in dirContent to be used on worker p\nendIndex:       Index of the last model in dirContent to be used on worker p\nvarsCharact:    Array with the names of variables to be retrieved from the MATLAB session on worker p\n\nOUTPUTS\n\ndata:           Mixed array of variables retrieved from worker p (rows: models, columns: variables).                   First column corresponds to the model name, and first row corresponds to varsCharact.\n\nEXAMPLES\n\nMinimum working example\n\njulia> loopModels(dir, p, scriptName, dirContent, startIndex, endIndex, varsCharact)\n\nSee also: PALM()\n\n\n\n"
},

{
    "location": "functions.html#PALM",
    "page": "Modules and Functions",
    "title": "PALM",
    "category": "function",
    "text": "PALM(dir, scriptName, nMatlab, outputFile, cobraToolboxDir)\n\nFunction reads the directory dir, and launches nMatlab sessions to run scriptName. Results are saved in the outputFile.\n\nINPUTS\n\ndir:             Directory that contains the models (model file format: .mat)\nscriptName:      Name of MATLAB script to be run (without extension .m)\n\nOPTIONAL INPUTS\n\nnMatlab:         Number of desired MATLAB sessions (default: 2)\noutputFile:      Name of .mat file to save the result table named \"summaryData\" (default name: \"PALM_data.mat\")\ncobraToolboxDir: Directory of the COBRA Toolbox (default: \"~/cobratoolbox\")\n\nOUTPUTS\n\nFile with the name specified in outputFile.\n\nEXAMPLES\n\nMinimum working example\n\njulia> PALM(\"~/models\", \"characteristics\")\n\nRunning PALM on 12 MATLAB sessions\n\njulia> PALM(\"~/models\", \"characteristics\", 12, \"characteristicsResults.mat\")\n\nSee also: loopModels() and shareLoad()\n\n\n\n"
},

{
    "location": "functions.html#PALM.jl-1",
    "page": "Modules and Functions",
    "title": "PALM.jl",
    "category": "section",
    "text": "shareLoad\nloopModels\nPALM"
},

{
    "location": "functions.html#SolverConfig",
    "page": "Modules and Functions",
    "title": "SolverConfig",
    "category": "type",
    "text": "SolverConfig(name, handle)\n\nDefinition of a common solver type, which inclues the name of the solver and other parameters\n\nname:           Name of the solver (alias)\nhandle:         Solver handle used to refer to the solver\n\n\n\n"
},

{
    "location": "functions.html#buildCobraLP",
    "page": "Modules and Functions",
    "title": "buildCobraLP",
    "category": "function",
    "text": "buildCobraLP(model, solver)\n\nBuild a model by interfacing directly with the CPLEX solver\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\nsolver:         A ::SolverConfig object that contains a valid handleto the solver\n\nOUTPUTS\n\nm:              A MathProgBase.LinearQuadraticModel object with inner field\n\nEXAMPLES\n\njulia> m = buildCobraLP(model, solver)\n\nSee also: MathProgBase.LinearQuadraticModel(), MathProgBase.HighLevelInterface.buildlp()\n\n\n\n"
},

{
    "location": "functions.html#changeCobraSolver",
    "page": "Modules and Functions",
    "title": "changeCobraSolver",
    "category": "function",
    "text": "changeCobraSolver(name, params)\n\nFunction used to change the solver and include the respective solver interfaces\n\nINPUT\n\nname:           Name of the solver (alias)\n\nOPTIONAL INPUT\n\nparams:         Solver parameters as a row vector with tuples\n\nOUTPUT\n\nsolver:         Solver object with a handle field\n\nEXAMPLES\n\nMinimum working example (for the CPLEX solver)\n\njulia> changeCobraSolver(\"CPLEX\", cpxControl)\n\nSee also: MathProgBase.jl\n\n\n\n"
},

{
    "location": "functions.html#solveCobraLP",
    "page": "Modules and Functions",
    "title": "solveCobraLP",
    "category": "function",
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
    "location": "functions.html#findRxnIDS",
    "page": "Modules and Functions",
    "title": "findRxnIDS",
    "category": "function",
    "text": "findRxnIDS(model, rxnsList)\n\nFunction that returns a vector of reaction IDs that correspond to an input list of reaction names.\n\nINPUTS\n\nmodel:          An ::LPproblem object that has been built using the loadModel function.                       All fields of model must be available.\n\nOPTIONAL INPUTS\n\nrxnsList:       List of reaction names (default: all reactions in the model)\n\nOUTPUTS\n\nrxnIDs:       	Vector with the reaction IDs that correspond to the reaction names in rxnsList\n\nEXAMPLES\n\nMinimum working example:\n\njulia> findRxnIDS(model)\n\nFull input/output example\n\njulia> rxnIDs, rxnIDsNE = findRxnIDS(model, rxnsList)\n\nFull input/output example\n\njulia> rxnIDs, rxnIDsNE = findRxnIDS(model, [\"reactionName1\", \"reactionName2\"])\n\nSee also: loadModel(), distributedFBA()\n\n\n\n"
},

{
    "location": "functions.html#convertUnitRange",
    "page": "Modules and Functions",
    "title": "convertUnitRange",
    "category": "function",
    "text": "convertUnitRange(vect)\n\nConverts a unit range vector to an array type vector. If the vector is not of UnitRange{Int64} type, the same vector is returned.\n\nINPUTS\n\nvect:         Any vector (UnitRange{Int64} will be converted to Array{Int64})\n\nOUTPUTS\n\nretVect       Converted vector (if type of input vector is UnitRange{Int64})\n\nEXAMPLES\n\nMinimum working example\n\njulia> a = 1:4\n1:4\n\njulia> convertUnitRange(a)\n4-element Array{Int64,1}:\n  1\n  2\n  3\n  4\n\n\n\n"
},

{
    "location": "functions.html#tools.jl-1",
    "page": "Modules and Functions",
    "title": "tools.jl",
    "category": "section",
    "text": "findRxnIDS\nconvertUnitRange"
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
    "location": "faq.html#Why-can\'t-I-build-packages-in-Julia?-1",
    "page": "FAQ",
    "title": "Why can\'t I build packages in Julia?",
    "category": "section",
    "text": "In order to build the packages of Julia, cmake must be installed on Unix systems. In addition, csh must be installed in order to open a MATLAB session. Both packages can be installed using system commands (must have sudo rights):$ sudo apt-get install cmake csh"
},

{
    "location": "faq.html#Why-do-the-Julia-instances-on-remote-workers-not-start?-1",
    "page": "FAQ",
    "title": "Why do the Julia instances on remote workers not start?",
    "category": "section",
    "text": "There can be several reasons, but majorly, you must ensure that the Julia configuration on all the nodes is the same than on the host node.Make sure that the lib folder in ~/.julia is the same on the ALL the nodes (.ji files in /.julia/lib/v0.x). The exact (bitwise) same usr/lib/julia/* binaries, which requires copying them to each machine. In order to have the same .ji files on all nodes, it is recommended to copy them from a central storage space (or cloud) to the library folder on the node:$ cp ~/centralStorage/CPLEX.ji ~/.julia/lib/v0.x/\n$ cp ~/centralStorage/MathProgBase.ji ~/.julia/lib/v0.x/Once all the .ji have been copied, do not use or build the modules on the nodes. In other words, do not type using CPLEX/MathProgBase at the REPL. Alternatively, you may set JULIA_PKGDIR to a cloud or common storage location."
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
    "text": "Some Windows users may have to wait a while when installing Julia. The performance of COBRA.jl is unaffected by this relatively long load time. However, you may try these avenues of fixing this:Try setting the git parameters correctly (using git bash that you can download from here):$ git config --global core.preloadindex true\n$ git config --global core.fscache true\n$ git config --global gc.auto 256Make sure that you set the following environment variables correctly:$ set JULIA_PKGDIR=C:\\Users\\<yourUsername>\\.julia\\vx.y.z\n$ set HOME=C:\\Users\\<yourUsername>\\AppData\\Local\\Julia-x.y.zMake sure that the .julia folder is not located on a network. This slows the processes in Julia down dramatically."
},

{
    "location": "faq.html#How-can-I-generate-the-documentation?-1",
    "page": "FAQ",
    "title": "How can I generate the documentation?",
    "category": "section",
    "text": "You can generate the documentation using Documenter.jl by typing in /docs:$ julia --color=yes makeDoc.jl"
},

{
    "location": "faq.html#How-can-I-get-the-latest-version-of-COBRA.jl-1",
    "page": "FAQ",
    "title": "How can I get the latest version of COBRA.jl",
    "category": "section",
    "text": "If you want to enjoy the latest untagged (but eventually unstable) features of COBRA.jl, do the following from within Julia:julia> Pkg.checkout(\"COBRA\", \"develop\")"
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
