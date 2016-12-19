# Configuration

## Solver configuration parameters: solverCfg.jl

In order to load currently defined solver parameters, the following file may be included in the script, which defines the `solParams` array:
```julia
include("$(Pkg.dir("COBRA"))/config/solverCfg.jl")
```
Then, the `COBRA` solver can be set with:
```julia
solver = changeCobraSolver(solverName, solParams);
```

If specific solver parameters should be set, the file `solverCfg.jl` may also be edited, or a new file `mySolverCfg.jl` can be created in the folder `config` loaded as:
```julia
include("config/mySolverCfg.jl")
```
The solver can then be set in a similar way with the additional argument `solParams` in `changeCobraSolver`.

In general, an array with all solver parameters is defined as follows:
```julia
solParams = [(:parameter, value)]
```

For the `CPLEX` solver, a list of all `CPLEX` parameters can be found [here](https://www.ibm.com/support/knowledgecenter/SS9UKU_12.5.0/com.ibm.cplex.zos.help/homepages/refparameterscplex.html). The array of solver parameters can be defined as follows:
```julia
solParams = [
    # decides whether or not results are displayed on screen in an application of the C API.
    (:CPX_PARAM_SCRIND,         0);

    # sets the parallel optimization mode. Possible modes are automatic, deterministic, and opportunistic.
    (:CPX_PARAM_PARALLELMODE,   1);

    # sets the default maximal number of parallel threads that will be invoked by any CPLEX parallel optimizer.
    (:CPX_PARAM_THREADS,        1);

    # partitions the number of threads for CPLEX to use for auxiliary tasks while it solves the root node of a problem.
    (:CPX_PARAM_AUXROOTTHREADS, 2);

    # decides how to scale the problem matrix.
    (:CPX_PARAM_SCAIND,         1);

    # controls which algorithm CPLEX uses to solve continuous models (LPs).
    (:CPX_PARAM_LPMETHOD,       0)
] #end of solParams
```

## SSH connection details: sshCfg.jl

A parallel pool with workers on SSH nodes can be created using:
```julia
include("$(Pkg.dir("COBRA"))/src/connect.jl")
workersPool, nWorkers = createPool(12, true, "mySSHCfg.jl")
```
which will connect 12 local workers, and all workers defined in `mySSHCfg.jl`. An example connection file is provided in the `config/` folder of the `COBRA` package installation folder.

An array with all connection details to SSH nodes is defined as follows:
```julia
sshWorkers = Array{Dict{Any, Any}}(1)

sshWorkers[1,:] = Dict( "usernode"   => "first.last@server.com",
                        "procs"  => 32,
                        "dir"    => `~/COBRA.jl/`,
                        "flags"  => `-4 -p22`,
                        "exename"=> "/usr/bin/julia/bin/./julia")
```

Make sure that the size of `sshWorkers` is properly set.
