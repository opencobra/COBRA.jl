# Configuration
# Local directory with model files
LOCAL_DIR_PATH = "./AGORA_RenamedBiomassForVMH"
MATLAB_EXEC = "/Applications/MATLAB_R2016b.app/bin/matlab"
SCRIPT_NAME = "tutorial_modelCharact_script"

# Number of MATLAB sessions
Nmatlab = 2

# Part below is FROZEN - do not change unless you know what you are doing.
if Nmatlab == 1
    warn("The poolsize is equal to 1. PALM.jl is meant to be used in parallel, not serial or sequential.")
end

dirContent = readdir(LOCAL_DIR_PATH);
Nmodels = length(dirContent);

info("Directory read successfully ($Nmodels models).")

# Make sure that not more processes are launched than there are models (load ratio >= 1)
if Nmatlab > Nmodels
    warn("Number of workers ($Nmatlab) exceeds the number of models ($Nmodels).")
    Nmatlab = Nmodels
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
Nworkers = length(wrks)
realLoadRatio = round(Nmodels/Nworkers)

println("\n -- Load distribution --\n")
println(" - Number of workers:                $Nworkers")
println(" - Number of models:                 $Nmodels")
println(" - True load ratio (Models/worker):  $(Nmodels/Nworkers)")
println(" - Realistic load ratio :            $realLoadRatio\n")

if Nmodels%Nworkers > 0
    println(" >> Every worker (#", wrks[1], " - #", wrks[end - 1], ") will solve ", realLoadRatio, " model(s).")
    restModels = Nmodels - (Nworkers-1)*realLoadRatio
    if restModels > 0
        println(" >> Worker #", wrks[end], " will solve ", restModels, " model(s).")
    end

    if realLoadRatio < restModels-1 || restModels < 1
        print_with_color(:red, "\n >> Load sharing is not fair. Consider adjusting the maximum poolsize.\n")
    else
        print_with_color(:yellow, "\n >> Load sharing is almost ideal.\n")
    end
else
    println(" >> Every worker will solve ", realLoadRatio, " model(s).")
    print_with_color(:green, " >> Load sharing is ideal.\n")
end

# Preload the COBRA module everywhere
using COBRA

# broadcast local variables to every worker
@eval @everywhere dirContent = $dirContent
@eval @everywhere MATLAB_EXEC = $MATLAB_EXEC
@eval @everywhere SCRIPT_NAME = $SCRIPT_NAME
@eval @everywhere LOCAL_DIR_PATH = $LOCAL_DIR_PATH

@sync for p in wrks

  info("Launching MATLAB session on worker $p.")

  # call the local Function on each of the workers
  @spawnat p run(`$MATLAB_EXEC -nodesktop -nosplash -r "PALM_modelFile = '$(dirContent[p-1])'; PALM_iModel = $(p-1); $SCRIPT_NAME;" -logfile $LOCAL_DIR_PATH/logs/logFile_$(dirContent[p-1][1:end-4])_$(p-1).log`)
end
