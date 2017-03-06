# Configuration
# Local directory with model files
LOCAL_DIR_PATH = "./testModels" #/AGORA_fixedRxns_17_01_10_sorted_fixGPR
MATLAB_EXEC = "/Applications/MATLAB_R2016b.app/bin/matlab"
SCRIPT_NAME = "tutorial_modelCharact_script"

# Number of MATLAB sessions
Nmatlab = 2

# Part below is FROZEN - do not change unless you know what you are doing.
if Nmatlab == 1
    error("The poolsize is equal to 1. PALM.jl is meant to be used in parallel, not serial or sequential.")
end

dirContent = readdir(LOCAL_DIR_PATH);
nModels = length(dirContent);

info("Directory read successfully ($nModels models).")

# Make sure that not more processes are launched than there are models (load ratio >= 1)
if Nmatlab > nModels
    warn("Number of workers ($Nmatlab) exceeds the number of models ($nModels).")
    Nmatlab = nModels
    warn("Number of workers reduced to number of models for ideal load distribution.\n")
end

# Add workers if workerpool is not yet initialized
poolsize = nprocs()
if poolsize < Nmatlab
    addprocs(Nmatlab)
    poolsize = nprocs()
    info("$Nmatlab workers added to the pool (poolsize+ = $poolsize).")
else
    print_with_color(:yellow, "Maximum poolsize of $(poolsize-1) (+1 host) reached.\n")
end

# Definition of workers and load distribution
wrks = workers()
nWorkers = length(wrks)
realLoadRatio = round(nModels/nWorkers)

println("\n -- Load distribution --\n")
println(" - Number of workers:                $nWorkers")
println(" - Number of models:                 $nModels")
println(" - True load ratio (Models/worker):  $(nModels/nWorkers)")
println(" - Realistic load ratio :            $realLoadRatio\n")

restModels = 0
if nModels%nWorkers > 0
    println(" >> Every worker (#", wrks[1], " - #", wrks[end - 1], ") will solve ", realLoadRatio, " model(s).")
    restModels = nModels - (nWorkers-1)*realLoadRatio
    if restModels > 0
        println(" >> Worker #", wrks[end], " will solve ", restModels, " model(s).")
    end

    if realLoadRatio < restModels-1 || restModels < 1
        print_with_color(:red, "\n >> Load sharing is not fair. Consider adjusting the maximum poolsize.\n")
    else
        print_with_color(:yellow, "\n >> Load sharing is almost ideal.\n")
    end
else
    println(" >> Every worker will run ", realLoadRatio, " model(s).")
    print_with_color(:green, " >> Load sharing is ideal.\n")
end

# Preload the COBRA module everywhere
using COBRA, MATLAB

# broadcast local variables to every worker
@eval @everywhere dirContent = $dirContent
#@eval @everywhere MATLAB_EXEC = $MATLAB_EXEC
#@eval @everywhere SCRIPT_NAME = $SCRIPT_NAME
@eval @everywhere LOCAL_DIR_PATH = $LOCAL_DIR_PATH

varsCharact = ["Nmets", "Nrxns", "Nelem", "Nnz", "sparsityRatio", "bwidth", "maxVal", "minVal", "columnDensity", "rankA", "rankDeficiencyA", "maxSingVal", "minSingVal", "condNumber"]

# determine the number of characteristics to be retrieved
nCharacteristics = length(varsCharact)

# prepare array for storing remote references
#R = Array{Future}(nModels, nCharacteristics)
#R = Array{Union{Int,Float64,AbstractString}}(nModels, nCharacteristics)
R = Array{Future}(nWorkers)

# retrieve the numerical characteristics from each worker

# set the header of all the columns
data[1, :] = [""; varsCharact]

@everywhere using MATLAB

@everywhere function loopModels(p, dirContent, startIndex, endIndex, nCharacteristics, varsCharact)


    #local nModels
    if endIndex > startIndex
        nModels = endIndex - startIndex + 1
        @show nModels
    else
        error("The specified endIndex (=$endIndex) is greater than the specified startIndex (=$startIndex).")
    end

    # convert global to local counter
    if startIndex - nModels > 0
        startIndex = startIndex - nModels
    end
    if endIndex - nModels >= nModels
        endIndex = endIndex - nModels
    end

    data = Array{Union{Int,Float64,AbstractString}}(nModels + 1, nCharacteristics + 1)

    for k = startIndex:endIndex

        PALM_iModel = k + nModels
        PALM_modelFile = dirContent[PALM_iModel]

        # save the modelName
        data[k + 1, 1] = PALM_modelFile

        @mput PALM_iModel
        @mput PALM_modelFile
        @matlab tutorial_modelCharact_script

        for i = 1:nCharacteristics
            data[k + 1, i + 1] = MATLAB.get_variable(Symbol(varsCharact[i]))
        end

    end

    return data
end

@sync for (p, pid) in enumerate(workers())

    info("Launching MATLAB session on worker $(p+1).")

    startIndex = Int((p-1) * realLoadRatio + 1)

    if p < wrks[end]
        endIndex = Int(p * realLoadRatio)
        info("Worker $(p+1) runs $realLoadRatio models: from $startIndex to $endIndex")
    else
        endIndex = Int((p-1) * realLoadRatio + restModels)
        info("Worker $(p+1) runs $restModels models: from $startIndex to $endIndex")
    end

    @async R[p] = @spawnat (p+1) begin
        loopModels(p, dirContent, startIndex, endIndex, nCharacteristics, varsCharact)
    end

    #=
    @spawnat p begin

    end
    =#
    #=
    @sync for k = startIndex:endIndex
        #@show print_with_color(:yellow, "$p - $k")
        PALM_iModel = k
        PALM_modelFile = dirContent[PALM_iModel]

        # save the modelName
        data[k + 1, 1] = PALM_modelFile

        @spawnat p @mput PALM_iModel
        @spawnat p @mput PALM_modelFile
        @spawnat p @matlab tutorial_modelCharact_script

        for i = 1:nCharacteristics
            R[k, i] = @spawnat p MATLAB.get_variable(Symbol(varsCharact[i]))
        end

    end
    =#
    # directly call the local Function on each of the workers using the system command
    #@spawnat p run(`$MATLAB_EXEC -nodesktop -nosplash -r "PALM_modelFile = '$(dirContent[p-1])'; PALM_iModel = $(p-1); $SCRIPT_NAME;" -logfile $LOCAL_DIR_PATH/logs/logFile_$(dirContent[p-1][1:end-4])_$(p-1).log`)
end

## 3 models/worker
# 6 models, 2 workers -> 4.31s
# 12 models, 4 workers -> 7.68s
# 12 models, 2 workers -> 5.64s
#=
# insert the data and the model name
for (p, pid) in enumerate(workers())

    startIndex = Int((p-1) * realLoadRatio + 1)

    if p  < wrks[end]
        endIndex = Int(p * realLoadRatio)
        #info("Worker $(p + 1) runs $realLoadRatio models: from $startIndex to $endIndex")
    else
        endIndex = Int((p-1) * realLoadRatio + restModels)
        #info("Worker $(p + 1) runs $restModels models: from $startIndex to $endIndex")
    end

    for k = startIndex:endIndex
        for i = 1:nCharacteristics
            data[k + 1, i + 1] =  fetch(R[k, i])
        end
    end
end

using COBRA, MAT
# save the summaries to individual files
# open a file with a give filename
fileName = "modelCharacteristics.mat"
file = matopen(fileName, "w")
# set the list of variables
vars = ["data"]
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
=#
