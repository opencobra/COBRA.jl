#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test 30 reactions (parallel)
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------


if !@isdefined includeCOBRA
    includeCOBRA = true
end

# output information
testFile = @__FILE__

# number of workers
nWorkers = 4

pkgDir = joinpath(mkpath("COBRA"), "..")

# create a pool and use the COBRA module if the testfile is run in a loop
if includeCOBRA
    connectSSHWorkers = false
    include(pkgDir*"/src/connect.jl")

    # create a parallel pool and determine its size
    if isdefined(:nWorkers) && isdefined(:connectSSHWorkers)
        workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
    end

    using COBRA, HTTP

    include("getTestModel.jl")
end

# download the ecoli_core_model
getTestModel()

# include a common deck for running tests
include(pkgDir*"/config/solverCfg.jl")

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)

# load an external mat file
model = loadModel(pkgDir*"/test/ecoli_core_model.mat", "S", "model")

# select the number of reactions
rxnsList = 1:30

# select the reaction optimization mode
rxnsOptMode = 2 .+ zeros(Int64, length(rxnsList))

# define an optPercentage value
optPercentage = 90.0

# launch the distributedFBA process
startTime   = time()
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax = distributedFBA(model, solver, nWorkers=nWorkers, optPercentage=optPercentage, preFBA=true, rxnsList=rxnsList)
solTime = time() - startTime

# Test numerical values - test on floor as different numerical precision with different solvers
@test floor(maximum(maxFlux[rxnsList])) == 59.0
@test floor(minimum(maxFlux[rxnsList])) == -16.0
@test floor(maximum(minFlux[rxnsList])) == 35.0
@test floor(minimum(minFlux[rxnsList])) == -27.0
@test floor(norm(maxFlux[rxnsList])) == 94.0
@test floor(norm(minFlux[rxnsList])) == 61.0
@test abs((model.c[rxnsList]' * minFlux[rxnsList])[1] - optPercentage / 100.0 * optSol) < 1e-6

# save the variables to the current directory
saveDistributedFBA("testFile.mat")

# remove the file to clean up
#run(`rm testFile.mat`)

# print a solution summary
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
