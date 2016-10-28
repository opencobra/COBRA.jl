# Configuration

## solverCfg.jl

An array with all solver parameters is defined as follows:

```julia
solParams = [(:parameter, value)]
```

For the `CPLEX` solver, a list of all `CPLEX` parameters can be found [here](https://www.ibm.com/support/knowledgecenter/SS9UKU_12.5.0/com.ibm.cplex.zos.help/homepages/refparameterscplex.html)

## sshCfg.jl

An array with all connection details to SHH nodes is defined as follows:

```julia
sshWorkers = Array{Dict{Any, Any}}(1)

sshWorkers[1,:] = Dict( "usernode"   => "first.last@server.com",
                        "procs"  => 32,
                        "dir"    => `~/COBRA.jl/`,
                        "flags"  => `-4 -p22`,
                        "exename"=> "/usr/bin/julia/bin/./julia")
```

Make sure that the size of `sshWorkers` is properly set.
