# Configuration
# Local directory with model files
LOCAL_DIR_PATH = "./testModels" #/AGORA_fixedRxns_17_01_10_sorted_fixGPR
MATLAB_EXEC = "/Applications/MATLAB_R2016b.app/bin/matlab"
SCRIPT_NAME = "tutorial_modelCharact_script"

# Number of MATLAB sessions
nMatlab = 4

# Part below is FROZEN - do not change unless you know what you are doing.
if nMatlab == 1
    error("The poolsize is equal to 1. PALM.jl is meant to be used in parallel, not serial or sequential.")
end

dirContent = readdir(LOCAL_DIR_PATH);
nModels = length(dirContent);

info("Directory read successfully ($nModels models).")

function shareLoad(nMatlab, nModels)

    # Make sure that not more processes are launched than there are models (load ratio >= 1)
    if nMatlab > nModels
        warn("Number of workers ($nMatlab) exceeds the number of models ($nModels).")
        nMatlab = nModels
        warn("Number of workers reduced to number of models for ideal load distribution.\n")
    end

    # Add workers if workerpool is not yet initialized
    poolsize = nprocs()
    if poolsize < nMatlab
        addprocs(nMatlab)
        poolsize = nprocs()
        info("$nMatlab workers added to the pool (poolsize+ = $poolsize).")
    else
        print_with_color(:yellow, "Maximum poolsize of $(poolsize-1) (+1 host) reached.\n")
    end

    # Definition of workers and load distribution
    wrks = workers()
    nWorkers = length(wrks)
    realLoadRatio = Int(round(nModels / nWorkers))

    println("\n -- Load distribution --\n")
    println(" - Number of workers:                $nWorkers")
    println(" - Number of models:                 $nModels")
    println(" - True load ratio (Models/worker):  $(nModels/nWorkers)")
    println(" - Realistic load ratio :            $realLoadRatio\n")

    restModels = 0
    if nModels%nWorkers > 0
        println(" >> Every worker (#", wrks[1], " - #", wrks[end - 1], ") will solve ", realLoadRatio, " model(s).")
        restModels = Int(nModels - (nWorkers - 1) * realLoadRatio)
        if restModels > 0
            println(" >> Worker #", wrks[end], " will solve ", restModels, " model(s).")
        end

        if realLoadRatio < restModels - 1 || restModels < 1
            print_with_color(:red, "\n >> Load sharing is not fair. Consider adjusting the maximum poolsize.\n")
        else
            print_with_color(:yellow, "\n >> Load sharing is almost ideal.\n")
        end
    else
        println(" >> Every worker will run ", realLoadRatio, " model(s).")
        print_with_color(:green, " >> Load sharing is ideal.\n")
    end

    return nWorkers, realLoadRatio, restModels
end

nWorkers, realLoadRatio, restModels = shareLoad(nMatlab, nModels)

# broadcast local variables to every worker
@eval @everywhere dirContent = $dirContent
@eval @everywhere restModels = $restModels
@eval @everywhere realLoadRatio = $realLoadRatio
@eval @everywhere LOCAL_DIR_PATH = $LOCAL_DIR_PATH

varsCharact = ["Nmets", "Nrxns", "Nelem", "Nnz", "sparsityRatio", "bwidth", "maxVal", "minVal", "columnDensity", "rankA", "rankDeficiencyA", "maxSingVal", "minSingVal", "condNumber"]

# determine the number of characteristics to be retrieved
nCharacteristics = length(varsCharact)

# prepare array for storing remote references
R = Array{Future}(nWorkers)

# declare an array to store the indices for each worker
indicesWorkers = Array{Int}(nWorkers, 3)

# declare an empty array for storing a summary of all data
summaryData = Array{Union{Int,Float64,AbstractString}}(nModels + 1, nCharacteristics + 1)

# use the MATLAB module on every worker
@everywhere using MATLAB

@everywhere function loopModels(p, dirContent, startIndex, endIndex, nCharacteristics, varsCharact)

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
            @matlab tutorial_modelCharact_script

            for i = 1:nCharacteristics
                data[k, i + 1] = MATLAB.get_variable(Symbol(varsCharact[i]))
            end
        end

        return data
    else
        error("The specified endIndex (=$endIndex) is greater than the specified startIndex (=$startIndex).")
    end
end

# launch the function loopModels on every worker
@sync for (p, pid) in enumerate(workers())

    info("Launching MATLAB session on worker $(p+1).")

    startIndex = Int((p - 1) * realLoadRatio + 1)

    # save the startIndex for each worker
    indicesWorkers[p, 1] = startIndex

    if p < wrks[end]
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
        loopModels(p, dirContent, startIndex, endIndex, nCharacteristics, varsCharact)
    end

end

# set the header of all the columns
summaryData[1, :] = [""; varsCharact]

# store the data retrieved from worker p
@sync for (p, pid) in enumerate(workers())
    summaryData[indicesWorkers[p, 1] + 1:indicesWorkers[p, 2] + 1, :] = fetch(R[p][1:indicesWorkers[p, 3], :])
end


@everywhere using MAT
@everywhere using COBRA

# save the summaries to individual files
# open a file with a give filename
fileName = "modelCharacteristics.mat"
file = matopen(fileName, "w")

# set the list of variables
vars = ["summaryData"]
countSavedVars = 0

# loop through the list of variables
for i = 1:length(vars)
    if isdefined(Main, Symbol(vars[i]))
        print("Saving $(vars[i]) (T:> $(typeof(eval(Main, Symbol(vars[i]))))) ...")
        write(file, "$(vars[i])", COBRA.convertUnitRange( eval(Main, Symbol(vars[i])) ))
        # increment the counter
        countSavedVars = countSavedVars + 1
        print_with_color(:green, "Done.\n")
    end
end

# close the file and return a status message
close(file)
