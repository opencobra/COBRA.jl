#-------------------------------------------------------------------------------------------
#=
    Purpose:    Implementation of distributedFBA
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------
"""
    preFBA!(model, solver, optPercentage, osenseStr, rxnsList)

Function that solves the original FBA, adds the objective value as a constraint to the
stoichiometric matrix of the model, and changes the RHS vector `b`. Note that the `model` object is changed.

# INPUTS

- `model`:          An `::LPproblem` object that has been built using the `loadModel` function.
                        All fields of `model` must be available.
- `solver`:         A `::SolverConfig` object that contains a valid `handle` to the solver

# OPTIONAL INPUTS

- `optPercentage`:  Only consider solutions that give you at least a certain percentage of the optimal solution (default: 100%)
- `osenseStr`:      Sets the optimization mode of the original FBA ("max" or "min", default: "max")
- `rxnsList`:       List of reactions to analyze (default: all reactions)

# OUTPUTS

- `objValue`:       Optimal objective value of the original FBA problem
- `fbaSol`:         Solution vector that corresponds to the optimal objective value

# EXAMPLES

- Minimum working example:
```julia
julia> preFBA!(model, solver)
```

- Full input/output example
```julia
julia> optSol, fbaSol = preFBA!(model, solver, optPercentage, objective)
```

See also: `solveCobraLP()`, `distributedFBA()`

"""

function preFBA!(model, solver, optPercentage::Float64 = 100.0, osenseStr::String = "max",
                        rxnsList::Array{Int, 1} = ones(Int, length(model.rxns)))

    # constants
    OPT_PERCENTAGE = 90.0
    tol = 1e-6

    # determine the size of the stoichiometric matrix
    (nMets,nRxns) = size(model.S)
    println("\n >> Size of stoichiometric matrix: ($nMets, $nRxns)\n")

    # determine the number of reactions that shall be considered
    nRxnsList = length(rxnsList)

    if optPercentage > OPT_PERCENTAGE
        print_with_color(:cyan, "The optPercentage is higher than 90. The solution process might take longer than expected.\n\n")
    end

    # determine constraints for the correct space (0-100% of the full space)
    if countnz(model.c) > 0
        hasObjective = true

        # solve the original LP problem
        fbaSolution = solveCobraLP(model, solver)

        if fbaSolution.status == :Optimal
            # retrieve the solution to the initial LP
            FBAobj = fbaSolution.objval

            # retrieve the solution vector
            fbaSol = fbaSolution.sol

            if osenseStr == "max"
                objValue = floor(FBAobj/tol) * tol * optPercentage / 100.0
            else
                objValue = ceil(FBAobj/tol) * tol * optPercentage / 100.0
            end
        else
            error("No optimal solution found to the orginal FBA problem!\n")
        end
    else
        hasObjective = false
        fbaSol = 0.0
    end

    # add a condition if the LP has an extra condition based on the FBA solution
    if hasObjective
        print_with_color(:blue, "preFBA! [osenseStr = $osenseStr]: FBAobj = $FBAobj, optPercentage = $optPercentage, objValue = optPercentage * FBAobj = $objValue, norm(fbaSol) = $(norm(fbaSol)).\n\n")

        # add a row in the stoichiometric matrix
        model.S = [model.S; model.c']

        # add an element in the b vector
        model.b = [model.b; objValue]

        # change the sense of the constraints vector based on the objective sense
        if osenseStr == "max"
            push!(model.csense, '>')
        else
            push!(model.csense, '<')
        end

        return FBAobj, fbaSol
    else
        print_with_color(:blue, "No objective set (`c` is zero). objValue and fbaSol not defined. optPercentage = $optPercentage.\n\n")
        return nothing
    end

end

#-------------------------------------------------------------------------------------------
"""
    splitRange(model, rxnsList, nWorkers, strategy)

Function splits a reaction list in blocks for a certain number of workers according to
a selected strategy. Generally , `splitRange()` is called before the FBAs are distributed.

# INPUTS

- `model`:          An `::LPproblem` object that has been built using the `loadModel` function.
                        All fields of `model` must be available.
- `rxnsList`:       List of reactions to analyze (default: all reactions)

# OPTIONAL INPUTS

- `nWorkers`:       Number of workers as initialized using `createPool()` or similar
- `strategy`:       Number of the splitting strategy
    - 0: Blind splitting: default random distribution
    - 1: Extremal dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from both extremal indices of the sorted column density vector
    - 2: Central dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from the beginning and center indices of the sorted column density vector

# OUTPUTS

- `rxnsKey`:        Structure with vector for worker `p` with start and end indices of each block

# EXAMPLES

- Minimum working example
```julia
julia> splitRange(model, rxnsList, 2)
```

- Selection of the splitting strategy 2 for 4 workers
```julia
julia> splitRange(model, rxnsList, 4, 2)
```

See also: `distributeFBA()`

"""

function splitRange(model, rxnsList, nWorkers::Int = 1, strategy::Int = 0)

    # determine number of reactions for each worker
    pRxnsWorker = convert(Int, ceil(length(rxnsList) / nWorkers))

    # determine the length of the rxnsList
    NrxnsList = length(rxnsList)

    # output the average load per worker and the splitting strategy
    print_with_color(:blue, "Average load per worker: $pRxnsWorker reactions ($nWorkers workers).\n")
    print_with_color(:blue, "Splitting strategy is $strategy.\n\n")

    # define indices for each worker p
    istart      = zeros(Int, nWorkers)
    iend        = zeros(Int, nWorkers)
    istart[1]   = 1
    iend[1]     = pRxnsWorker
    rxnsKey     = [] # either UnitRange or Int

    # determine the row and column densities
    if strategy > 0

        # intialize vectors for start and end indices of each block
        startMarker1  = zeros(Int, nWorkers)
        endMarker1    = zeros(Int, nWorkers)
        startMarker2  = zeros(Int, nWorkers)
        endMarker2    = zeros(Int, nWorkers)

        # retrieve the number of metabolites and reactions
        Nmets, Nrxns  = size(model.S)

        # intialize column and row density vectors
        cdVect        = zeros(NrxnsList)

        # loop through the number of reactions and determine the column density
        for i in 1:NrxnsList
              cdVect[i] = nnz(model.S[:, rxnsList[i]]) / Nmets * 100.0
        end

        # initialize counter vectors
        rxnsVect = rxnsList

        # retrieve the indices of the permutation
        indexcdVect = sortperm(cdVect)

        # sort the column and row density vectors accordingly
        sortedrxnsVect = rxnsVect[indexcdVect]

        # determine the number of reactions per worker
        pRxnsHalfWorker = convert(Int, ceil(NrxnsList / (2 * nWorkers)))

        for p in 1:nWorkers
            # strategy 1
            if strategy == 1
                startMarker1[p] = (p - 1) * pRxnsHalfWorker + 1
                endMarker1[p]   = p * pRxnsHalfWorker

                startMarker2[p] = startMarker1[p] + convert(Int, ceil(NrxnsList / 2.0))
                endMarker2[p]   = endMarker1[p] + convert(Int, ceil(NrxnsList / 2.0))

            # strategy 2
            elseif strategy == 2
                startMarker1[p] = (p-1) * pRxnsHalfWorker + 1
                endMarker1[p]   = p * pRxnsHalfWorker

                startMarker2[p] = convert(Int, ceil(NrxnsList / 2.0)) + startMarker1[p]
                endMarker2[p]   = startMarker2[p] + pRxnsHalfWorker + 1
            end

            if strategy == 1 || strategy == 2
                # avoid start indices beyond the total number of reactions
                if startMarker1[p] > NrxnsList startMarker1[p] = NrxnsList end
                if startMarker2[p] > NrxnsList startMarker2[p] = NrxnsList end

                # avoid end indices beyond the total number of reactions
                if endMarker1[p] > NrxnsList endMarker1[p] = NrxnsList end
                if endMarker2[p] > NrxnsList endMarker2[p] = NrxnsList end

                # avoid flipped chunks
                if startMarker1[p] > endMarker1[p] startMarker1[p] = endMarker1[p] end
                if startMarker2[p] > endMarker2[p] startMarker2[p] = endMarker2[p] end
            end # end if strategy == 1 || strategy == 2

        end # end for loop
    end # end if strategy > 0

    # determine indices for chunks distributed to parallel workers
    if nWorkers > 1
        for p = 1:nWorkers
            if p > 1 && strategy == 0
                # determine the start and end of each chunk
                istart[p] = 1 + pRxnsWorker * (p - 1)
                iend[p]   = istart[p] + pRxnsWorker - 1

                # avoid start indices beyond the total number of reactions
                if istart[p] > NrxnsList istart[p] = NrxnsList end

                # avoid end indices beyond the total number of reactions
                if iend[p] > NrxnsList iend[p] = NrxnsList end

                # avoid flipped chunks
                if istart[p] > iend[p] istart[p] = iend[p] end
            end # end if p > 1

            # prepare the vector with all the reactions distributed per worker p
            if strategy == 1 || strategy == 2
                push!(rxnsKey, [sortedrxnsVect[startMarker1[p]:endMarker1[p]]; sortedrxnsVect[startMarker2[p]:endMarker2[p]]])
            else
                push!(rxnsKey, istart[p]:iend[p])
            end
        end #end for loop
    end

    return rxnsKey

end

#-------------------------------------------------------------------------------------------
"""
    loopFBA(m, rxnsList, nRxns, pid, iRound, rxnsOptMode)

Function used to perform a loop of a series of FBA problems using the CPLEX solver
Generally, `loopFBA` is called in a loop over multiple workers and makes use of the
`CPLEX.jl` module.

# INPUTS

- `m`:              A MathProgBase.LinearQuadraticModel object with `inner` field
- `solver`:         A `::SolverConfig` object that contains a valid `handle`to the solver
- `rxnsList`:       List of reactions to analyze (default: all reactions)
- `nRxns`:          Total number of reaction in the model `m.inner`

# OPTIONAL INPUTS

- `rxnsOptMode`:    List of min/max optimizations to perform:
    - 0: only minimization
    - 1: only maximization
    - 2: minimization & maximization
      [default: all reactions are minimized and maximized, i.e. 2+zeros(Int,length(model.rxns))]
- `iRound`:         Index of optimization round
    - 0: minimization
    - 1: maximization
- `pid`:            Julia ID of launched process
- `resultsDir`:     Path to results folder (default is a `results` folder in the Julia package directory)
- `logFiles`:       (only available for CPLEX) Boolean to write a solver logfile of each optimization (default: false)
- `onlyFluxes`:     Save only minFlux and maxFlux if true and will return placeholders for `fvamin`, `fvamax`, `statussolmin`, or `statussolmax` (applicable for quick checks of large models, default: false)

# OUTPUTS

- `retObj`:         Vector with optimal (either `min` or `max`) solutions (objective values)
- `retFlux`:        Array of solution vectors corresponding to the vector with the optimal objective values
                    (either `min` or `max`)
- `retStat`:        Vector with the status of the solver of each FBA (default: initialized with `-1`)
    - 0:   LP problem is infeasible
    - 1:   LP problem is optimal
    - 2:   LP problem is unbounded
    - 3:   Solver for the LP problem has hit a user limit
    - 4:   LP problem is infeasible or unbounded
    - 5:   LP problem has a non-documented solution status
    - 10+: `retStat - 10` = returned solution status of CPLEX

# EXAMPLES

- Minimum working example
```julia
julia> loopFBA(m, rxnsList, nRxns)
```

See also: `distributeFBA()`, `MathProgBase.HighLevelInterface`

"""

function loopFBA(m, rxnsList, nRxns::Int, rxnsOptMode = 2 + zeros(Int, length(rxnsList)), iRound::Int = 0, pid::Int = 1,
                 resultsDir::String = "$(dirname(@__FILE__))/../results", logFiles::Bool = false, onlyFluxes::Bool = false)

    # initialize vectors and counters
    retObj = zeros(nRxns)
    retStat = -1 + zeros(Int, nRxns)
    j = 1

    # declare the return flux matrix
    if !onlyFluxes
        retFlux = 0.0/0.0 * ones(nRxns, length(rxnsList)) # initialize with NaN
    else
        retFlux = zeros(1, 1)
    end

    # loop over all the reactions
    for k = 1:length(rxnsList)

        # determine the optimization mode
        if (rxnsOptMode[k] == 0 && iRound == 0) || (rxnsOptMode[k] == 1 && iRound == 1) || (rxnsOptMode[k] == 2)
            performOptim = true
        else
            performOptim = false
        end

        if performOptim
            # change the sense of the optimization
            if j == 1
                if iRound == 0
                    MathProgBase.HighLevelInterface.setsense!(m, :Min)
                    println(" -- Minimization (iRound = $iRound). Block $pid [$(length(rxnsList))/$nRxns].")
                else
                    MathProgBase.HighLevelInterface.setsense!(m, :Max)
                    println(" -- Maximization (iRound = $iRound). Block $pid [$(length(rxnsList))/$nRxns].")
                end
            end

            # Set the objective vector coefficients
            c = zeros(nRxns)
            c[rxnsList[k]] = 1000.0 # set the coefficient of the current FBA to 1000

            # set the objective of the CPLEX model
            MathProgBase.HighLevelInterface.setobj!(m, c)

            if logFiles
                # save individual logFiles with the CPLEX solver
                if string(typeof(m.inner)) == "CPLEX.Model"
                    CPLEX.set_logfile(m.inner.env, "$resultsDir/logs/$((iRound == 0 ) ? "min" : "max")-myLogFile-$(rxnsList[k]).log")
                end
            end

            # solve the model using the general MathProgBase interface
            solutionLP = MathProgBase.HighLevelInterface.solvelp(m)

            # retrieve the solution status
            statLP = solutionLP.status

            # output the solution, save the minimum and maximum fluxes
            if statLP == :Optimal
                # retrieve the objective value
                retObj[rxnsList[k]] = solutionLP.objval / 1000.0 #solutionLP.sol[rxnsList[k]]

                # retrieve the solution vector
                if !onlyFluxes
                    retFlux[:, k] = solutionLP.sol
                end

                # return the solution status
                retStat[rxnsList[k]] = 1 # LP problem is optimal

            elseif statLP == :Infeasible
                retStat[rxnsList[k]] = 0 # LP problem is infeasible

            elseif statLP == :Unbounded
                retStat[rxnsList[k]] = 2 # LP problem is unbounded

            elseif statLP == :UserLimit
                retStat[rxnsList[k]] = 3 # Solver for the LP problem has hit a user limit

            elseif statLP == :InfeasibleOrUnbounded
                retStat[rxnsList[k]] = 4 # LP problem is infeasible or unbounded

            else
                if string(typeof(m.inner)) == "CPLEX.Model"
                    retStat[rxnsList[k]] = 10 + CPLEX.get_status_code(m.inner)
                else
                    retStat[rxnsList[k]] = 5 # LP problem has a non-documented solution status
                end
            end

            j = j + 1 # increase the counter for the return flux vector
        end # end condition performOptim
    end #end k loop

    return retObj, retFlux, retStat

end

# ------------------------------------------------------------------------------------------
"""
    distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, rxnsOptMode, preFBA, saveChunks, resultsDir, logFiles)

Function to distribute a series of FBA problems across one or more workers that have been
initialized using the `createPool` function (or similar).

# INPUTS

- `model`:          An `::LPproblem` object that has been built using the `loadModel` function.
                        All fields of `model` must be available.
- `solver`:         A `::SolverConfig` object that contains a valid `handle` to the solver
- `nWorkers`:       Number of workers as initialized using `createPool()` or similar

# OPTIONAL INPUTS

- `optPercentage`:  Only consider solutions that give you at least a certain percentage of the optimal solution (default: 100%)
- `objective`:      Objective ("min" or "max") (default: "max")
- `rxnsList`:       List of reactions to analyze (default: all reactions)
- `strategy`:       Number of the splitting strategy
    - 0: Blind splitting: default random distribution
    - 1: Extremal dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from both extremal indices of the sorted column density vector
    - 2: Central dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from the beginning and center indices of the sorted column density vector
- `rxnsOptMode`:    List of min/max optimizations to perform:
    - 0: only minimization
    - 1: only maximization
    - 2: minimization & maximization
      [default: all reactions are minimized and maximized, i.e. `2+zeros(Int,length(model.rxns))]`
- `preFBA`:         Solve the original FBA and add a percentage condition (Boolean variable, default: true for flux variability analysis FVA)
- `saveChunks`:     Save the fluxes of the minimizations and maximizations in individual files on each worker (applicable for large models, default: false)
- `resultsDir`:     Path to results folder (default is a `results` folder in the Julia package directory)
- `logFiles`:       Boolean to write a solver logfile of each optimization (default: false)
- `onlyFluxes`:     Save only minFlux and maxFlux if true and will return placeholders for `fvamin`, `fvamax`, `statussolmin`, or `statussolmax` (applicable for quick checks of large models, default: false)

# OUTPUTS

- `minFlux`:        Minimum flux for each reaction
- `maxFlux`:        Maximum flux for each reaction
- `optSol`:         Optimal solution of the initial FBA (if `preFBA` set to `true`)
- `fbaSol`:         Solution vector of the initial FBA (if `preFBA` set to `true`)
- `fvamin`:         Array with flux values for the considered reactions (minimization) (if `onlyFluxes` set to `false`)
      Note: `fvamin` is saved in individual `.mat` files when `saveChunks` is `true`.
- `fvamax`:         Array with flux values for the considered reactions (maximization) (if `onlyFluxes` set to `false`)
      Note: `fvamax` is saved in individual `.mat` files when `saveChunks` is `true`.
- `statussolmin`:   Vector of solution status for each reaction (minimization) (if `onlyFluxes` set to `false`)
- `statussolmax`:   Vector of solution status for each reaction (maximization) (if `onlyFluxes` set to `false`)

# EXAMPLES

- Minimum working example
```julia
julia> minFlux, maxFlux = distributedFBA(model, solver)
```

- Full input/output example
```julia
julia> minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, optPercentage, objective, rxnsList, strategy, rxnsOptMode, true, true, true)
```

- Save only the fluxes
```julia
julia> minFlux, maxFlux = distributedFBA(model, solver, optPercentage, objective, rxnsList, strategy, rxnsOptMode, true, false, true)
```

- Save flux vectors in files
```julia
julia> minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, optPercentage, objective, rxnsList, strategy, rxnsOptMode, true, true)
```

See also: `preFBA!()`, `splitRange()`, `buildCobraLP()`, `loopFBA()`, or `fetch()`
"""

function distributedFBA(model, solver, nWorkers::Int = 1, optPercentage::Float64 = 100.0, objective::String = "max",
                        rxnsList = 1:length(model.rxns), strategy::Int = 0, rxnsOptMode = 2 + zeros(Int,length(model.rxns)),
                        preFBA::Bool = true, saveChunks::Bool = false, resultsDir::String = "$(dirname(@__FILE__))/../results",
                        logFiles::Bool = false, onlyFluxes::Bool = false)

    # calculate a default FBA solution
    if preFBA
        startTime = time()
        optSol, fbaSol = preFBA!(model, solver, optPercentage, objective)
        solTime = time() - startTime
        print_with_color(:green, "Original FBA solved. Solution time: $solTime s.\n\n")
    else
        optSol = 0.0
        fbaSol = zeros(length(model.rxns))
        print_with_color(:blue, "Original FBA. No additional constraints have been added.\n")
    end

    # determine the number of reactions and metabolites
    nRxns = length(model.rxns)
    nMets = length(model.mets)

    nRxnsList = length(rxnsList)

    # intialize the flux vectors
    minFlux = zeros(nRxns)
    maxFlux = zeros(nRxns)

    # sanity check for very large models
    if nRxns > 60000 && !saveChunks && !onlyFluxes
        saveChunks = true
        info("Trying to solve a model of $nRxns reactions. `saveChunks` has been set to `true`.")
    end

    # initialilze the flux matrices
    if !onlyFluxes
        if !saveChunks
            fvamax = zeros(nRxns, nRxns)
            fvamin = zeros(nRxns, nRxns)
        else
            # create a folder for storing the results
            if !isdir("$resultsDir")
                mkdir("$resultsDir")
                print_with_color(:green, "Directory `$resultsDir` created.\n\n")
            else
                print_with_color(:cyan, "Directory `$resultsDir` already exists.\n\n")
            end

            # create a folder for storing the chunks of the fluxes of each minimization
            if !isdir("$resultsDir/fvamin")
                mkdir("$resultsDir/fvamin")
            end

            # create a folder for storing the chunks of the fluxes of each maximization
            if !isdir("$resultsDir/fvamax")
                mkdir("$resultsDir/fvamax")
            end

            # create a folder for log files
            if logFiles && !isdir("$resultsDir/logs")
                mkdir("$resultsDir/logs")
            end

            fvamin = zeros(2, 2)
            fvamax = zeros(2, 2)
        end
    else
        fvamin = zeros(2, 2)
        fvamax = zeros(2, 2)
    end

    # initialize the vectors to report the solution status
    if !onlyFluxes
        statussolmin = zeros(Int, nRxns)
        statussolmax = zeros(Int, nRxns)
    else
        statussolmin = zeros(Int, 1)
        statussolmax = zeros(Int, 1)
    end

    # perform sanity checks
    if nRxnsList > nRxns
        rxnsList = 1:nRxns
        warn("The `rxnsList` has more reactions than in the model. `rxnsList` shorted to the maximum number of reactions.")
    end

    if nRxns != nRxnsList
        println(" >> Only $nRxnsList ", (nRxnsList == 1) ? "reaction" : "reactions", " of $nRxns will be solved (~ $(nRxnsList * 100 / nRxns) \%).\n")
    else
        println(" >> All $nRxns reactions of the model will be solved (100 \%).\n")
    end

    # sanity checks for large models
    if nRxnsList > 20000 && nWorkers <= 4
        warn("\nTrying to solve more than 20000 optimization problems on fewer than 4 workers. Memory might be limited.")
        info(" >> Try running this analysis on a cluster, or use a larger parallel pool.\n")
    end

    # sanity check for few reactions on a large pool
    if nRxnsList < nWorkers
        warn("\nThe parallel pool of workers is larger than the number of reactions being solved.")
        info(" >> Consider reducing the size of the parallel pool to free system resources.\n")
    end

    # perform maximizations and minimizations in parallel
    if nWorkers > 1

        # partition and split the reactions among workers
        rxnsKey = splitRange(model, rxnsList, nWorkers, strategy)

        # prepare array for storing remote references
        R = Array{Future}(nWorkers, 2)

        # distribution across workers
        @sync for (p, pid) in enumerate(workers())
            for iRound = 0:1
                @async R[p, iRound + 1] = @spawnat (p + 1) begin
                    m = buildCobraLP(model, solver) # on each worker, the model must be built individually

                    # adjust the solver parameters based on the model
                    autoTuneSolver(m, nMets, nRxns, solver, pid)

                    # start the loop of FBA
                    loopFBA(m, rxnsList[rxnsKey[p]], nRxns, rxnsOptMode[rxnsKey[p]], iRound, pid, resultsDir, logFiles, onlyFluxes)
                end
            end
        end

        # assemble the vectors
        @sync for (p, pid) in enumerate(workers())

            # save the minimum and maximum
            minFlux[rxnsList[rxnsKey[p]]] = fetch(R[p, 1])[1][rxnsList[rxnsKey[p]]]
            maxFlux[rxnsList[rxnsKey[p]]] = fetch(R[p, 2])[1][rxnsList[rxnsKey[p]]]

            # save the fluxes of each reaction
            if !onlyFluxes
                if saveChunks
                    if p == 1 println() end
                    print(" Saving the minimum and maximum fluxes for reactions $(rxnsList[rxnsKey[p]]) from worker $p ... ")

                    # open 2 file streams
                    filemin = matopen("$resultsDir/fvamin/fvamin_$p.mat", "w")
                    filemax = matopen("$resultsDir/fvamax/fvamax_$p.mat", "w")

                    # saving the rxnsList and rxnsOptMode temporarily
                    tmpRxnsList = convertUnitRange(rxnsList[rxnsKey[p]])
                    tmpRxnsOptMode = convertUnitRange(rxnsOptMode[rxnsKey[p]])

                    # save the reaction key for each worker into each file (filemin)
                    write(filemin, "fvamin", fetch(R[p, 1])[2][:, :])
                    write(filemin, "rxnsList", tmpRxnsList)
                    write(filemin, "rxnsOptMode", tmpRxnsOptMode)

                    # save the reaction key for each worker into each file (filemax)
                    write(filemax, "fvamax", fetch(R[p, 2])[2][:, :])
                    write(filemax, "rxnsList", tmpRxnsList)
                    write(filemax, "rxnsOptMode", tmpRxnsOptMode)

                    # close the 2 file streams
                    close(filemin)
                    close(filemax)
                    print_with_color(:green, "Done.\n")
                else
                    fvamin[:, rxnsList[rxnsKey[p]]] = fetch(R[p, 1])[2][:, :]
                    fvamax[:, rxnsList[rxnsKey[p]]] = fetch(R[p, 2])[2][:, :]
                end

                # save the solver status for each reaction
                statussolmin[rxnsList[rxnsKey[p]]] = fetch(R[p, 1])[3][rxnsList[rxnsKey[p]]]
                statussolmax[rxnsList[rxnsKey[p]]] = fetch(R[p, 2])[3][rxnsList[rxnsKey[p]]]
            end
        end

    # perform maximizations and minimizations sequentially
    else
        m = buildCobraLP(model, solver)

        # adjust the solver parameters based on the model
        autoTuneSolver(m, nMets, nRxns, solver)

        minFlux, fvamin, statussolmin = loopFBA(m, rxnsList, nRxns, rxnsOptMode, 0)
        maxFlux, fvamax, statussolmax = loopFBA(m, rxnsList, nRxns, rxnsOptMode, 1)
    end

    return minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax

end

#-------------------------------------------------------------------------------------------
"""
    printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName, strategy, saveChunks)

Output a solution summary

# INPUTS

- `testFile`:       Name of the `.mat` test file
- `optSol`:         Optimal solution of the initial FBA
- `minFlux`:        Minimum flux for each reaction
- `maxFlux`:        Maximum flux for each reaction
- `solTime`:        Solution time (in seconds)
- `nWorkers`:       Number of workers as initialized using `createPool()` or similar
- `solverName`:     Name of the solver
- `strategy`:       Number of the splitting strategy
    - 0: Blind splitting: default random distribution
    - 1: Extremal dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from both extremal indices of the sorted column density vector
    - 2: Central dense-and-sparse splitting: every worker receives dense and sparse reactions, starting from the beginning and center indices of the sorted column density vector
- `saveChunks`:     Save the fluxes of the minimizations and maximizations in individual files on each worker (applicable for large models)

# OUTPUTS

- (Printed summary)

See also: `norm()`, `maximum()`, `minimum()`

"""

function printSolSummary(testFile::String, optSol, maxFlux, minFlux, solTime, nWorkers, solverName, strategy = 0, saveChunks = false)

    # print a solution summary
    println("\n-- Solution summary --\n")
    print_with_color(:blue, "$testFile\n")
    println(" Original FBA obj.val         ", optSol)
    println(" Maximum of maxFlux:          ", maximum(maxFlux))
    println(" Minimum of maxFlux:          ", minimum(maxFlux))
    println(" Maximum of minFlux:          ", maximum(minFlux))
    println(" Minimum of minFlux:          ", minimum(minFlux))
    println(" Norm of maxFlux:             ", norm(maxFlux))
    println(" Norm of minFlux:             ", norm(minFlux))
    println(" Solution time [s]:           ", solTime)
    println(" Number of workers:           ", nWorkers)
    println(" Solver:                      ", solverName)
    println(" Distribution strategy:       ", strategy)
    println(" Saving individual files:     ", saveChunks)
    println()

end

#------------------------------------------------------------------------------------------
"""
    saveDistributedFBA(fileName::String, vars)

Output a file with all the output variables of `distributedFBA()` and `rxnsList`

# INPUTS

- `fileName`:         Filename of the output
- `vars`:             List of variables (default: ["minFlux", "maxFlux", "optSol", "fbaSol", "fvamin", "fvamax", "statussolmin", "statussolmax", "rxnsList"])

# OUTPUTS

- `.mat` file with the specified output variables

# EXAMPLES

- Minimum working example
```julia
julia> saveDistributedFBA("myResults.mat")
```

- File location
```julia
julia> saveDistributedFBA("myDirectory/myResults.mat")
```

- Home location
```julia
julia> saveDistributedFBA(ENV["HOME"]*"/myResults.mat")
```

- Save minFlux and maxFlux variables
```julia
julia> saveDistributedFBA(ENV["HOME"]*"/myResults.mat", ["minFlux", "maxFlux"])
```

"""

function saveDistributedFBA(fileName::String, vars = ["minFlux", "maxFlux", "optSol", "fbaSol", "fvamin", "fvamax", "statussolmin", "statussolmax", "rxnsList"])

    # open a file with a give filename
    file = matopen(fileName, "w")

    # initialize the counter for the variables
    countSavedVars = 0

    # loop through the list of variables
    for i = 1:length(vars)
        if isdefined(Main, Symbol(vars[i]))
            print("Saving $(vars[i]) (T:> $(typeof(eval(Main, Symbol(vars[i]))))) ...")

            write(file, "$(vars[i])", convertUnitRange( eval(Main, Symbol(vars[i])) ))

            # increment the counter
            countSavedVars = countSavedVars + 1

            print_with_color(:green, "Done.\n")
        end
    end

    # close the file and return a status message
    close(file)

    # print a status message
    if countSavedVars > 0
        print_with_color(:green, "All available variables saved to $fileName.\n")
    else
        warn("No variables saved.")
    end

end

export preFBA!, splitRange, loopFBA, distributedFBA, printSolSummary, saveDistributedFBA

#------------------------------------------------------------------------------------------
