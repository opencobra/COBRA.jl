#-------------------------------------------------------------------------------------------
#=
    Purpose:    Implementation of PALM.jl
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       March 2017
=#

#-------------------------------------------------------------------------------------------
"""
    shareLoad(nModels, nMatlab, printLevel)

Function shares the number of `nModels` across `nMatlab` sessions (Euclidian division)

# INPUTS

- `nModels`:         Number of models to be run

# OPTIONAL INPUTS

- `nMatlab`:        Number of desired MATLAB sessions (default: 2)
- `printLevel`:     Verbose level (default: 1). Mute all output with `printLevel = 0`.
- `dryRun`:         Test load sharing without changing the parpool (default: false)

# OUTPUTS

- `nWorkers`:        Number of effective workers in the parallel pool; corresponds to `nMatlab` if `nMatlab` < `nModels` and to `nModels` otherwise
- `quotientModels`:  Rounded number of models to be run by all MATLAB sessions apart from the last one
- `remainderModels`: Number of remaining models to be run by the last MATLAB session

# EXAMPLES

- Minimum working example
```julia
julia> shareLoad(nModels)
```

- Determination of the load of 4 models in 2 MATLAB sessions
```julia
julia> shareLoad(4, 2, 1)
```

See also: `createPool()` and `PALM`

"""

function shareLoad(nModels::Int, nMatlab::Int = 2, printLevel::Int=1, dryRun::Bool=false)

    if printLevel > 0 && dryRun
        info("Load sharing is determined without actively changing the number of connected workers (dryRun = true).")
    end

    # Make sure that not more processes are launched than there are models (load ratio >= 1)
    if nMatlab > nModels
        if printLevel > 0
            warn("Number of workers ($nMatlab) exceeds the number of models ($nModels).")
        end

        nMatlab = nModels

        # remove the last workers in the pool
        if !dryRun
            for k = length(workers()):-1:nModels
                rmprocs(k)
            end
        end

        if printLevel > 0
            warn("Number of workers reduced to number of models for ideal load distribution.\n")
        end
    end

    # Definition of workers and load distribution
    if dryRun
        wrks = [1:nMatlab;]
    else
        wrks = workers()
    end
    nWorkers = length(wrks)
    quotientModels = Int(ceil(nModels / nWorkers))

    remainderModels = 0

    if nModels%nWorkers > 0
        if printLevel > 0
            println(" >> Every worker (#", wrks[1], " - #", wrks[end - 1], ") will run (at least) ", quotientModels, " model(s).")
        end

        remainderModels = Int(nModels - (nWorkers - 1) * quotientModels)
        if remainderModels > 0
            if printLevel > 0
                println(" >> Worker #", wrks[end-1], " will solve ", quotientModels + remainderModels, " model(s).")
            end
        end

        if quotientModels < remainderModels - 1 || remainderModels < 1
            if printLevel > 0
                print_with_color(:red, "\n >> Load sharing is not fair. Consider adjusting the maximum poolsize.\n")
            end
        else
            if printLevel > 0
                print_with_color(:yellow, "\n >> Load sharing is almost ideal.\n")
            end
        end
    else
        if printLevel > 0
            println(" >> Every worker will run ", quotientModels, " model(s).")
            print_with_color(:green, " >> Load sharing is ideal.\n")
        end
    end

    if printLevel > 0
        println("\n -- Load distribution --\n")
        println(" - Number of models:                 $nModels")
        println(" - Number of workers:                $nWorkers")
        println(" - True load (models/worker):        $(nModels/nWorkers)")
        println(" - Realistic load (quotient):        $quotientModels\n")
        println(" - Remaining load (remainder):       $remainderModels\n")
    end

    return nWorkers, quotientModels, remainderModels
end

#-------------------------------------------------------------------------------------------
"""
    loopModels(dir, p, scriptName, dirContent, startIndex, endIndex, varsCharact, printLevel)

Function `loopModels` is generally called in a loop from `PALM()` on worker `p`.
Runs `scriptName` for all models with an index in `dirContent` between `startIndex` and `endIndex`.
Retrieves all variables defined in `varsCharact`. The number of models on worker `p`
is computed as `nModels = endIndex - startIndex + 1`.

# INPUTS

- `dir`:            Directory that contains the models (model file format: `.mat`)
- `p`:              Process or worker number
- `scriptName`:     Name of MATLAB script to be run (without extension `.m`)
- `dirContent`:     Array with file names (commonly read from a directory)
- `startIndex`:     Index of the first model in `dirContent` to be used on worker `p`
- `endIndex`:       Index of the last model in `dirContent` to be used on worker `p`
- `varsCharact`:    Array with the names of variables to be retrieved from the MATLAB session on worker `p`

# OPTIONAL INPUTS

- `printLevel`:     Verbose level (default: 1). Mute all output with `printLevel = 0`.

# OUTPUTS

- `data`:           Mixed array of variables retrieved from worker p (rows: models, columns: variables).
                    First column corresponds to the model name, and first row corresponds to `varsCharact`.

# EXAMPLES

- Minimum working example
```julia
julia> loopModels(dir, p, scriptName, dirContent, startIndex, endIndex, varsCharact)
```

See also: `PALM()`

"""

function loopModels(dir, p, scriptName, dirContent, startIndex, endIndex, varsCharact, localnModels, printLevel::Int=1)

    # determine the lengt of the number of variables
    nCharacteristics = length(varsCharact)

    #local nModels
    if endIndex >= startIndex
        # declaration of local data array
        data = Array{Union{Int,Float64,AbstractString}}(localnModels, nCharacteristics + 1)

        for k = 1:localnModels
            PALM_iModel = k #+ (p - 1) * nModels
            PALM_modelFile = dirContent[startIndex+k-1]
            PALM_dir = dir
            PALM_printLevel = printLevel

            # save the modelName
            data[k, 1] = PALM_modelFile

            MATLAB.@mput PALM_iModel
            MATLAB.@mput PALM_modelFile
            MATLAB.@mput PALM_dir
            MATLAB.@mput PALM_printLevel
            eval(parse("MATLAB.mat\"run('$scriptName')\""))

            for i = 1:nCharacteristics
                data[k, i + 1] = MATLAB.get_variable(Symbol(varsCharact[i]))
            end
        end

        if printLevel > 0
            @show data
        end

        return data
    else
        error("The specified endIndex (=$endIndex) is greater than the specified startIndex (=$startIndex).")
    end
end

#-------------------------------------------------------------------------------------------
"""
    PALM(dir, scriptName, nMatlab, outputFile, cobraToolboxDir, printLevel)

Function reads the directory `dir`, and launches `nMatlab` sessions to run `scriptName`.
Results are saved in the `outputFile`.

# INPUTS

- `dir`:             Directory that contains the models (model file format: `.mat`)
- `scriptName`:      Absolute or relative path MATLAB script to be run

# OPTIONAL INPUTS

- `nMatlab`:         Number of desired MATLAB sessions (default: 2)
- `outputFile`:      Name of `.mat` file to save the result table named "summaryData" (default name: "PALM_data.mat")
- `cobraToolboxDir`: Directory of the COBRA Toolbox (default: ENV["HOME"]*"/cobratoolbox")
- `printLevel`:     Verbose level (default: 1). Mute all output with `printLevel = 0`.

# OUTPUTS

File with the name specified in `outputFile`.

# EXAMPLES

- Minimum working example
```julia
julia> PALM(ENV["HOME"]*"/models", "characteristics")
```

- Running `PALM` on 12 MATLAB sessions
```julia
julia> PALM(ENV["HOME"]*"/models", "characteristics", 12, "characteristicsResults.mat")
```

See also: `loopModels()` and `shareLoad()`

"""

function PALM(dir, scriptName; nMatlab::Int=2, outputFile::AbstractString="PALM_data.mat", varsCharact=[], cobraToolboxDir=ENV["HOME"]*Base.Filesystem.path_separator*"cobratoolbox", printLevel::Int=1, useCOBRA::Bool=true)

    # read the content of the directory
    dirContent = readdir(dir)

    if printLevel > 0
        info("Directory with $(length(dirContent)) models read successfully.")
    end

    nWorkers, quotientModels, remainderModels = shareLoad(length(dirContent), nMatlab)

    # determine the number of models
    nModels = length(dirContent)

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

    # clone the COBRA Toolbox if it is not yet available
    # Note: there is no need for the submodules to be cloned
    if !isdir(cobraToolboxDir)
        cmd = "git clone git@github.com:opencobra/cobratoolbox.git $cobraToolboxDir"
        info(cmd)
        run(`$cmd`)
    end

    # clone a copy to a tmp folder as the cobtratoolbox is updated at runtime
    if useCOBRA
        for (p, pid) in enumerate(workers())
            @sync @spawnat (p + 1) begin
                info(ENV["HOME"]*"/tmp/test-ct-$p")
                if !isdir(ENV["HOME"]*"/tmp/test-ct-$p")
                    cmd = "git clone $cobraToolboxDir "*ENV["HOME"]*"/tmp/test-ct-$p"
                    info(cmd)
                    run(`$cmd`)
                end
            end
        end
    end

    # launch the function loopModels on every worker
    @sync for (p, pid) in enumerate(workers())

        if printLevel > 0
            info("Launching MATLAB session on worker $(p+1).")
        end

        if useCOBRA
            # adding the model directory and eventual subdirectories to the MATLAB path
            # Note: the fileseparator `/` also works on Windows systems if git Bash has been installed
            @async R[p] = @spawnat (p+1) begin
                eval(parse("mat\"addpath(genpath('"*ENV["HOME"]*"/tmp/test-ct-$p'))\""))
                eval(parse("mat\"run('"*ENV["HOME"]*"/tmp/test-ct-$p/initCobraToolbox.m');\""))
            end
        end
    end

    # print an informative message
    if printLevel > 0
        info("> MATLAB sessions initializing")
    end

    @sync for (p, pid) in enumerate(workers())

        # determine the starting index
        startIndex = Int((p - 1) * quotientModels + 1)

        # save the startIndex for each worker
        indicesWorkers[p, 1] = startIndex

        if p <  workers()[end]-1
            endIndex = Int(p * quotientModels)

            indicesWorkers[p, 2] = endIndex
            indicesWorkers[p, 3] = quotientModels

            localnModels = quotientModels

            if printLevel > 0
                info("(case1): Worker $(p+1) runs $localnModels models: from $startIndex to $endIndex")
            end
        else
            endIndex = Int((p+1) * quotientModels + remainderModels)

            if endIndex >= nModels
                endIndex = nModels
            end

            indicesWorkers[p, 2] = endIndex
            indicesWorkers[p, 3] = remainderModels

            localnModels = endIndex - startIndex + 1

            if printLevel > 0
                info("(case 2): Worker $(p+1) runs $localnModels models: from $startIndex to $endIndex")
            end
        end

        @async R[p] = @spawnat (p+1) begin
            loopModels(dir, p, scriptName, dirContent, startIndex, endIndex, varsCharact, localnModels)
        end
    end

    # set the header of all the columns
    summaryData[1, :] = [""; varsCharact]

    # store the data retrieved from worker p
    for (p, pid) in enumerate(workers())
        @show tmpArray = fetch(R[p])
        localnModels = indicesWorkers[p, 2] - indicesWorkers[p, 1] + 1
        summaryData[indicesWorkers[p, 1] + 1:indicesWorkers[p, 2] + 1, :] = tmpArray[1:localnModels, :]
    end

    # save the summary data
    fileName = outputFile
    file = matopen(fileName, "w")
    write(file, "summaryData", summaryData[1:nModels+1, :])

    # close the file and return a status message
    close(file)

    return summaryData, R, indicesWorkers
end

export PALM
