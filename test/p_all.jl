#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test all reactions (parallel)
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------

using Base.Test

if !isdefined(:includeCOBRA) includeCOBRA = true end

# output information
testFile = @__FILE__

nWorkers = 4

# create a pool and use the COBRA module if the testfile is run in a loop
if includeCOBRA

    solverName = :GLPKMathProgInterface
    connectSSHWorkers = false
    include("$(dirname(pwd()))/src/connect.jl")

    # create a parallel pool and determine its size
    if isdefined(:nWorkers) && isdefined(:connectSSHWorkers)
        workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
    end

    using COBRA
end

# include a common deck for running tests
include("$(dirname(pwd()))/config/solverCfg.jl")

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)

# load an external mat file
model = loadModel("ecoli_core_model.mat", "S", "model")

# select the number of reactions
rxnsList = 1:length(model.rxns)

for s = 0:2
    # launch the distributedFBA process
    startTime   = time()
    minFlux, maxFlux, optSol = distributedFBA(model, solver, nWorkers, 90.0, "max", rxnsList, s)
    solTime = time() - startTime

    # Test numerical values - test on floor as different numerical precision with different solvers
    @test floor(maximum(maxFlux)) == 1000.0
    @test floor(minimum(maxFlux)) == -21.0
    @test floor(maximum(minFlux)) == 32.0
    @test floor(minimum(minFlux)) == -36.0
    @test floor(norm(maxFlux))    == 1427.0
    @test floor(norm(minFlux))    == 93.0
    @test abs((- model.c'*minFlux)[1] - optSol) < 1e-9

    # print a solution summary
    printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
end

# launch the distributedFBA process
startTime   = time()
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax = distributedFBA(model, solver, nWorkers)
solTime = time() - startTime

# Test numerical values - test on floor as different numerical precision with different solvers
@test floor(maximum(maxFlux)) == 1000.0
@test floor(minimum(maxFlux)) == -30.0
@test floor(maximum(minFlux)) == 29.0
@test floor(minimum(minFlux)) == -46.0
@test floor(norm(maxFlux))    == 1414.0
@test floor(norm(minFlux))    == 106.0
@test abs((- model.c'*minFlux)[1] - optSol) < 1e-9

# save the variables to the current directory
saveDistributedFBA("testFile.mat")

# remove the file to clean up
run(`rm testFile.mat`)

# print a solution summary
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
