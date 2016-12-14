#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test 30 reactions (parallel)
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------

using Base.Test

if !isdefined(:includeCOBRA) includeCOBRA = true end

# output information
testFile = @__FILE__

# number of workers
nWorkers = 4

# create a pool and use the COBRA module if the testfile is run in a loop
if includeCOBRA
    solverName = :GLPKMathProgInterface
    connectSSHWorkers = false
    include("$(dirname(@__FILE__))/../src/connect.jl")

    # create a parallel pool and determine its size
    if isdefined(:nWorkers) && isdefined(:connectSSHWorkers)
        workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
    end

    using COBRA
end

# include a common deck for running tests
include("$(dirname(@__FILE__))/../config/solverCfg.jl")

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)

# load an external mat file
model = loadModel("ecoli_core_model.mat", "S", "model")

# select the number of reactions
rxnsList = 1:30

# select the reaction optimization mode
rxnsOptMode = 2 + zeros(Int64, length(rxnsList))

# launch the distributedFBA process
startTime   = time()
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax = distributedFBA(model, solver, nWorkers, 90.0, "max", rxnsList, 0, rxnsOptMode)
solTime = time() - startTime

# Test numerical values - test on floor as different numerical precision with different solvers
@test floor(maximum(maxFlux)) == 59.0
@test floor(minimum(maxFlux)) == -16.0
@test floor(maximum(minFlux)) == 26.0
@test floor(minimum(minFlux)) == -36.0
@test floor(norm(maxFlux))    == 94.0
@test floor(norm(minFlux))    == 61.0
@test abs((- model.c'*minFlux)[1] - optSol) < 1e-9

# save the variables to the current directory
saveDistributedFBA("testFile.mat")

# remove the file to clean up
run(`rm testFile.mat`)

# print a solution summary
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
