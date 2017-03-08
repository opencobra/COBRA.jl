#-------------------------------------------------------------------------------------------
#=
    Purpose:    Implementation of PALM.jl
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       March 2017
=#

#-------------------------------------------------------------------------------------------

function shareLoad(nMatlab::Int, nModels::Int, verbose::Bool = true)

    # Make sure that not more processes are launched than there are models (load ratio >= 1)
    if nMatlab > nModels
        if verbose
            warn("Number of workers ($nMatlab) exceeds the number of models ($nModels).")
        end

        nMatlab = nModels

        if verbose
            warn("Number of workers reduced to number of models for ideal load distribution.\n")
        end
    end

    # Add workers if workerpool is not yet initialized
    #=
    poolsize = nprocs()
    if poolsize < nMatlab
        createPool(nMatlab)
        poolsize = nprocs()
        if verbose
            info("$nMatlab workers added to the pool (poolsize+ = $poolsize).")
        end
    else
        if verbose
            print_with_color(:yellow, "Maximum poolsize of $(poolsize-1) (+1 host) reached.\n")
        end
    end
    =#

    # Definition of workers and load distribution
    wrks = workers()
    nWorkers = length(wrks)
    realLoadRatio = Int(round(nModels / nWorkers))

    if verbose
        println("\n -- Load distribution --\n")
        println(" - Number of workers:                $nWorkers")
        println(" - Number of models:                 $nModels")
        println(" - True load ratio (Models/worker):  $(nModels/nWorkers)")
        println(" - Realistic load ratio :            $realLoadRatio\n")
    end

    restModels = 0

    if nModels%nWorkers > 0
        if verbose
            println(" >> Every worker (#", wrks[1], " - #", wrks[end - 1], ") will solve ", realLoadRatio, " model(s).")
        end

        restModels = Int(nModels - (nWorkers - 1) * realLoadRatio)
        if restModels > 0
            if verbose
                println(" >> Worker #", wrks[end], " will solve ", restModels, " model(s).")
            end
        end

        if realLoadRatio < restModels - 1 || restModels < 1
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
            println(" >> Every worker will run ", realLoadRatio, " model(s).")
            print_with_color(:green, " >> Load sharing is ideal.\n")
        end
    end

    return nWorkers, realLoadRatio, restModels
end

@everywhere function loopModels(p, scriptName, dirContent, startIndex, endIndex, nCharacteristics, varsCharact)

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

function prePALM(dirContent, nModels, scriptName, nWorkers, realLoadRatio, restModels, varsCharact, outputFile)

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

        startIndex = Int((p - 1) * realLoadRatio + 1)

        # save the startIndex for each worker
        indicesWorkers[p, 1] = startIndex

        if p <  workers()[end]
            endIndex = Int(p * realLoadRatio)
            indicesWorkers[p, 2] = endIndex
            indicesWorkers[p, 3] = realLoadRatio
            info("Worker $(p+1) runs $realLoadRatio models: from $startIndex to $endIndex")
        else
            endIndex = Int((p - 1) * realLoadRatio + restModels)
            indicesWorkers[p, 2] = endIndex
            indicesWorkers[p, 3] = restModels
            info("Worker $(p+1) runs $restModels models: from $startIndex to $endIndex")
        end

        @async R[p] = @spawnat (p + 1) begin
            loopModels(p, scriptName, dirContent, startIndex, endIndex, nCharacteristics, varsCharact)
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

    info("Directory read successfully ($nModels models).")

    nWorkers, realLoadRatio, restModels = shareLoad(nMatlab, nModels)

    prePALM(dirContent, nModels, scriptName, nWorkers, realLoadRatio, restModels, varsCharact, outputFile)
end
