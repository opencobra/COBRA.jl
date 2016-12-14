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

# define model and solution parameters
optPercentage     = 90.0
objective         = "max"
maxtrixAS         = "S"
modelName         = "model"

# test to save individual result files (chunks)
saveChunks  = true
strategy    = 0

# select the number of reactions
rxnsList = 1:length(model.rxns)

# select the reaction optimization mode
rxnsOptMode = 2 + zeros(Int64, length(rxnsList))

minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, rxnsOptMode, true, saveChunks)

# print a solution summary with full output
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName, strategy, saveChunks)

# remove the file to clean up
run(`rm -rf $(dirname(@__FILE__))/../results`)

# create folders if they are not present
if !isdir("$(dirname(@__FILE__))/../results")
    mkdir("$(dirname(@__FILE__))/../results")
    print_with_color(:green, "Directory `results` created.\n\n")

    # create a folder for storing the chunks of the fluxes of each minimization
    if !isdir("$(dirname(@__FILE__))/../results/fvamin")
        mkdir("$(dirname(@__FILE__))/../results/fvamin")
    end

    # create a folder for storing the chunks of the fluxes of each maximization
    if !isdir("$(dirname(@__FILE__))/../results/fvamax")
        mkdir("$(dirname(@__FILE__))/../results/fvamax")
    end
else
    print_with_color(:cyan, "Directory `results` already exists.\n\n")
end

minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers, optPercentage, objective, rxnsList, strategy, rxnsOptMode, true, saveChunks)

# print a solution summary with full output
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName, strategy, saveChunks)
