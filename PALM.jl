# Configuration
# Local directory with model files
LOCAL_DIR_PATH = "./AGORA_fixedRxns_17_01_10_sorted_fixGPR"#./testModels"
MATLAB_EXEC = "/Applications/MATLAB_R2016b.app/bin/matlab"
SCRIPT_NAME = "tutorial_modelCharact_script"

# Number of MATLAB sessions
Nmatlab = 8

# Part below is FROZEN - do not change unless you know what you are doing.
if Nmatlab == 1
    warn("The poolsize is equal to 1. PALM.jl is meant to be used in parallel, not serial or sequential.")
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
R = Array{Future}(nWorkers, nCharacteristics)

# retrieve the numerical characteristics from each worker
data = Array{Union{Int,Float64,AbstractString}}(nModels+1, nCharacteristics+1)

# set the header of all the columns
data[1, :] = [""; varsCharact]

@sync for (p, pid) in enumerate(workers())

    info("Launching MATLAB session on worker $(p+1).")

    startIndex = (p-1)*realLoadRatio + 1

    if p+1 < wrks[end]
        endIndex = p*realLoadRatio
        info("Worker $(p+1) runs $realLoadRatio models: from $startIndex to $endIndex")
    else
        endIndex = (p-1)*realLoadRatio + restModels
        info("Worker $(p+1) runs $restModels models: from $startIndex to $endIndex")
    end
    
    #=

    PALM_iModel = p
    PALM_modelFile = dirContent[PALM_iModel]

    # save the modelName
    data[p+1, 1] = PALM_modelFile

    @spawnat p @mput PALM_iModel
    @spawnat p @mput PALM_modelFile
    @spawnat p @matlab tutorial_modelCharact_script

    for i = 1:length(varsCharact)
        R[p, i] = @spawnat p MATLAB.get_variable(Symbol(varsCharact[i]))
    end
    =#
    # directly call the local Function on each of the workers using the system command
    #@spawnat p run(`$MATLAB_EXEC -nodesktop -nosplash -r "PALM_modelFile = '$(dirContent[p-1])'; PALM_iModel = $(p-1); $SCRIPT_NAME;" -logfile $LOCAL_DIR_PATH/logs/logFile_$(dirContent[p-1][1:end-4])_$(p-1).log`)
end
#=
# insert the data and the model name
for (p, pid) in enumerate(workers())
    for i = 1:nCharacteristics
        data[p+1, i+1] =  fetch(R[p, i])
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
