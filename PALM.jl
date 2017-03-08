#-------------------------------------------------------------------------------------------
#=
    Purpose:    Implementation of PALM.jl
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       March 2017
=#

#-------------------------------------------------------------------------------------------

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

function PALM(scriptName, nWorkers, varsCharact, outputFile)

    # Part below is FROZEN - do not change unless you know what you are doing.
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
