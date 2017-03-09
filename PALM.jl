#-------------------------------------------------------------------------------------------
#=
    Purpose:    Implementation of PALM.jl
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       March 2017
=#

#-------------------------------------------------------------------------------------------
"""
    shareLoad(nModels, nMatlab, verbose)

Function shares the number of `nModels` across `nMatlab` sessions (Euclidian division)

# INPUTS

- `nModels`:        Number of models to be run

# OPTIONAL INPUTS

- `nMatlab`:        Number of desired MATLAB sessions (default: nModels)
- `verbose`:        Verbose mode, set `false` for quiet load sharing (default: true)

# OUTPUTS

- `nWorkers`:       Number of effective workers in the parallel pool; corresponds to `nMatlab` if `nMatlab` < `nModels` and to `nModels` otherwise
- `quotientModels`:  Rounded number of models to be run by all MATLAB sessions apart from the last one
- `remainderModels`:     Number of remaining models to be run by the last MATLAB session

# EXAMPLES

- Minimum working example
```julia
julia> shareLoad(nModels)
```

- Determination of the load of 4 models in 2 MATLAB sessions
```julia
julia> shareLoad(4, 2, false)
```

See also: `createPool()`, `launchPALM()`, and `PALM`

"""

function shareLoad(nModels::Int, nMatlab::Int = nModels, verbose::Bool = true)

    # Make sure that not more processes are launched than there are models (load ratio >= 1)
    if nMatlab > nModels
        if verbose
            warn("Number of workers ($nMatlab) exceeds the number of models ($nModels).")
        end

        nMatlab = nModels

        # remove the last workers in the pool
        for k = length(workers()):-1:nModels
            rmprocs(k)
        end

        if verbose
            warn("Number of workers reduced to number of models for ideal load distribution.\n")
        end
    end

    # Definition of workers and load distribution
    wrks = workers()
    nWorkers = length(wrks)
    quotientModels = Int(round(nModels / nWorkers))

    if verbose
        println("\n -- Load distribution --\n")
        println(" - Number of models:                 $nModels")
        println(" - Number of workers:                $nWorkers")
        println(" - True load (models/worker):        $(nModels/nWorkers)")
        println(" - Realistic load (quotient):        $quotientModels\n")
        println(" - Remaining load (remainder):       $remainderModels\n")
    end

    remainderModels = 0

    if nModels%nWorkers > 0
        if verbose
            println(" >> Every worker (#", wrks[1], " - #", wrks[end - 1], ") will solve ", quotientModels, " model(s).")
        end

        remainderModels = Int(nModels - (nWorkers - 1) * quotientModels)
        if remainderModels > 0
            if verbose
                println(" >> Worker #", wrks[end], " will solve ", remainderModels, " model(s).")
            end
        end

        if quotientModels < remainderModels - 1 || remainderModels < 1
            if verbose
                print_with_color(:red, "\n >> Load sharing is not fair. Consider adjusting the maximum poolsize.\n")
            end
        else
            if verbose
                print_with_color(:yellow, "\n >> Load sharing is almost ideal.\n")
            end
        end
    else
        if verbose
            println(" >> Every worker will run ", quotientModels, " model(s).")
            print_with_color(:green, " >> Load sharing is ideal.\n")
        end
    end

    return nWorkers, quotientModels, remainderModels
end

#-------------------------------------------------------------------------------------------
"""
    loopModels(p, scriptName, dirContent, startIndex, endIndex, varsCharact)

Function `loopModels` that is called in a loop from `PALM` on worker `p`, and runs
`scriptName` for all models with an index in `dirContent` between `startIndex` and `endIndex`
and retrieves all variables defined in `varsCharact`. The number of models run on worker `p`
is computed as `nModels = endIndex - startIndex + 1`.

# INPUTS

- `p`:              Process or worker number
- `scriptName`:     Name of MATLAB script to be run
- `dirContent`:     Array with file names (commonly read from a directory)
- `startIndex`:     Index of the first model in `dirContent` to be used on worker `p`
- `endIndex`:       Index of the last model in `dirContent` to be used on worker `p`
- `varsCharact`:    Array with the names of variables to be retrieved from the MATLAB session on worker `p`

# OUTPUTS

- `data`:           Mixed array of variables retrieved from worker p (rows: models, columns: variables).
                    First column corresponds to the model name, and first row corresponds to `varsCharact`.

# EXAMPLES

- Minimum working example
```julia
julia> loopModels(p, scriptName, dirContent, startIndex, endIndex, varsCharact)
```

See also: `PALM()`

"""

@everywhere function loopModels(p, scriptName, dirContent, startIndex, endIndex, varsCharact)

    # determine the lengt of the number of variables
    nCharacteristics = length(varsCharact)

    #local nModels
    if endIndex >= startIndex
        nModels = endIndex - startIndex + 1

        # declaration of local data array
        data = Array{Union{Int,Float64,AbstractString}}(nModels, nCharacteristics + 1)

        for k = 1:nModels
            PALM_iModel = k + (p - 1) * nModels
            PALM_modelFile = dirContent[PALM_iModel]

            # save the modelName
            data[k, 1] = PALM_modelFile

            @mput PALM_iModel
            @mput PALM_modelFile
            eval(parse("@matlab $scriptName"))

            for i = 1:nCharacteristics
                data[k, i + 1] = MATLAB.get_variable(Symbol(varsCharact[i]))
            end
        end

        return data
    else
        error("The specified endIndex (=$endIndex) is greater than the specified startIndex (=$startIndex).")
    end
end

function launchPALM(dirContent, nModels, scriptName, nWorkers, quotientModels, remainderModels, varsCharact, outputFile)

    # throw an error if not parallel
    if nWorkers == 1
        error("The poolsize is equal to 1. PALM.jl is meant to be used in parallel, not serial or sequential.")
    end

    # determine the number of characteristics to be retrieved
    nCharacteristics = length(varsCharact)

    # prepare array for storing remote references
    R = Array{Future}(nWorkers)

    # declare an array to store the indices for each worker
    indicesWorkers = Array{Int}(nWorkers, 3)

    # declare an empty array for storing a summary of all data
    summaryData = Array{Union{Int,Float64,AbstractString}}(nModels + 1, nCharacteristics + 1)

    # launch the function loopModels on every worker
    @sync for (p, pid) in enumerate(workers())

        info("Launching MATLAB session on worker $(p+1).")

        startIndex = Int((p - 1) * quotientModels + 1)

        # save the startIndex for each worker
        indicesWorkers[p, 1] = startIndex

        if p <  workers()[end]
            endIndex = Int(p * quotientModels)
            indicesWorkers[p, 2] = endIndex
            indicesWorkers[p, 3] = quotientModels
            info("Worker $(p+1) runs $quotientModels models: from $startIndex to $endIndex")
        else
            endIndex = Int((p - 1) * quotientModels + remainderModels)
            indicesWorkers[p, 2] = endIndex
            indicesWorkers[p, 3] = remainderModels
            info("Worker $(p+1) runs $remainderModels models: from $startIndex to $endIndex")
        end

        @async R[p] = @spawnat (p + 1) begin
            loopModels(p, scriptName, dirContent, startIndex, endIndex, varsCharact)
        end

    end

    # set the header of all the columns
    summaryData[1, :] = [""; varsCharact]

    # store the data retrieved from worker p
    @sync for (p, pid) in enumerate(workers())
        summaryData[indicesWorkers[p, 1] + 1:indicesWorkers[p, 2] + 1, :] = fetch(R[p][1:indicesWorkers[p, 3], :])
    end

    # save the summary data
    fileName = outputFile#"modelCharacteristics.mat"
    file = matopen(fileName, "w")
    write(file, "summaryData", summaryData)

    # close the file and return a status message
    close(file)

end

function PALM(dir, nMatlab, scriptName, outputFile)
    #include("shareLoad.jl")

    dirContent = readdir(dir)
    nModels = length(dirContent)

    info("Directory with $nModels models read successfully.")

    nWorkers, quotientModels, remainderModels = shareLoad(nModels, nMatlab)

    launchPALM(dirContent, nModels, scriptName, nWorkers, quotientModels, remainderModels, varsCharact, outputFile)
end
