#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test the tool functions
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       January 2017
=#

#-------------------------------------------------------------------------------------------

using Test

if !@isdefined includeCOBRA
    includeCOBRA = true
end

# output information
testFile = @__FILE__

# number of workers
nWorkers = 1

# create a pool and use the COBRA module if the testfile is run in a loop
if includeCOBRA
    solverName = :GLPKMathProgInterface
    connectSSHWorkers = false
    include("$(Pkg.dir("COBRA"))/src/connect.jl")

    # create a parallel pool and determine its size
    if isdefined(:nWorkers) && isdefined(:connectSSHWorkers)
        workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
    end

    using COBRA
end

# include a common deck for running tests
include("$(Pkg.dir("COBRA"))/config/solverCfg.jl")

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)

# load an external mat file
model = loadModel("$(Pkg.dir("COBRA"))/test/ecoli_core_model.mat", "S", "model")

# find the reaction ID of one reaction
rxnIDs, rxnIDsNE = findRxnIDS(model, ["PPC"])
@test rxnIDs == [79]
@test rxnIDsNE == []

# find the reaction ID of all the reactions
rxnIDs, rxnIDsNE = findRxnIDS(model)
@test rxnIDs == model.rxns

# find the reaction ID of 2 reactions ("ABC" is not in the model)
rxnIDs, rxnIDsNE = findRxnIDS(model, ["PPC", "ABC"])
@test rxnIDs == [79]
@test rxnIDsNE == [2]

# find the reaction ID of 2 reactions ("ABC" is not in the model)
@test_throws ErrorException findRxnIDS(model, ["ABC"])
