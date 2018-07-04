#-------------------------------------------------------------------------------------------
#=
    Purpose:    Create and initialize a pool of workers (local and via SSH)
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------
"""
    createPool(localWorkers, connectSSHWorkers, connectionFile)

Function used to create a pool of parallel workers that are either local or connected via SSH.

# INPUTS

- `localWorkers`:   Number of local workers to connect.
                    If `connectSSH` is `true`, the number of localWorkers is 1 (host).

# OPTIONAL INPUTS

- `connectSSH`:     Boolean that indicates whether additional nodes should be connected via SSH.
                    (default: `false`)
- `connectionFile`  Name of the file with the SSH connection details (default: config/sshCfg.jl in the `COBRA` package installation folder)

# OUTPUTS

- `workers()`:      Array of IDs of the connected workers (local and SSH workers)
- `nWorkers`:       Total number of connect workers (local and SSH workers)

# EXAMPLES

Minimum working example:
```julia
julia> createPool(localWorkers)
```

Local workers and workers on SSH nodes can be connected as follows:
```julia
workersPool, nWorkers = createPool(12, true, "mySSHCfg.jl")
```
which will connect 12 local workers, and all workers defined in `mySSHCfg.jl`. An example connection file is provided in the `config/` folder of the `COBRA` package installation folder.

See also: `workers()`, `nprocs()`, `addprocs()`, `gethostname()`

"""

function createPool(localWorkers::Int, connectSSH::Bool=false, connectionFile::String="$(dirname(@__FILE__))/../config/sshCfg.jl")

    # load cores on remote nodes
    if connectSSH
        # load the SSH configuration
        if isfile(connectionFile)
            print("Loading SSH connection details from $connectionFile ...")
            include(connectionFile)
            print_with_color(:green, "Done.\n")
        else
            error("Connection file (filename: `$connectionFile`) is unreadable or not accessible.")
        end

        #count the total number of workers
        remoteWorkers = 0
        for i = 1:length(sshWorkers)
            remoteWorkers += sshWorkers[i]["procs"]
        end
    else #no remote SSH nodes
        remoteWorkers = 0 #specify that no remote workers are used
        if localWorkers == 0
            error("At least one worker is required in the pool. Please set `localWorkers` > 0.")
        end
    end

    nWorkers = localWorkers + remoteWorkers

    # connect all required workers
    if nWorkers <= 1
        info("Sequential version - Depending on the model size, expect long execution times.")

    else
        info("Parallel version - Connecting the $nWorkers workers ...")

        # print a warning for already connected threads
        if nprocs() > nWorkers
            print_with_color(:blue, "$nWorkers workers already connected. No further workers to connect.\n")
        end

        # add local threads
        if localWorkers > 0 && nworkers() < nWorkers
            addprocs(localWorkers, topology = :master_slave)
            print_with_color(:blue, "$(nworkers()) local workers are connected. (+1) on host: $(gethostname())\n")
        end

        # add remote threads
        if connectSSH && nworkers() < nWorkers && isfile(connectionFile)
            info("Connecting SSH nodes ...")

            # loop through the workers to be connected
            for i = 1:length(sshWorkers)
                println(" >> Connecting ", sshWorkers[i]["procs"], " workers on ", sshWorkers[i]["usernode"])

                try
                    if !is_windows()
                        # try logging in quietly to defined node using SSH
                        successConnect = success(`ssh -o BatchMode=yes -o ConnectTimeout=2 $(sshWorkers[i]["usernode"]) $(sshWorkers[i]["flags"])`)

                        # add threads when the SSH login is successful
                        if successConnect
                            addprocs([(sshWorkers[i]["usernode"], sshWorkers[i]["procs"])], topology = :master_slave,
                                    tunnel = true, dir = sshWorkers[i]["dir"], sshflags = sshWorkers[i]["flags"],
                                    exeflags=`--depwarn=no`, exename = sshWorkers[i]["exename"])

                            # return a status update
                            info("Connected ", sshWorkers[i]["procs"], " workers on ",  sshWorkers[i]["usernode"])

                            # increase the counter of remote workers
                            remoteWorkers += sshWorkers[i]["procs"]
                        else
                            error("Connecting ", sshWorkers[i]["procs"], " workers on ",  sshWorkers[i]["usernode"], " via SSH failed.")
                        end
                    else
                        error("Connecting computing nodes via SSH nodes is only supported on UNIX systems.\n")
                    end
                catch
                    error("Cannot connect $nWorkers workers via SSH. Check details in $connectionFile.")
                end
            end

            nWorkers = nworkers() + 1
        end
    end

    return workers(), nWorkers

end

export createPool

#------------------------------------------------------------------------------------------
