#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test all reactions (serial)
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------

using Base.Test

if !isdefined(:includeCOBRA) includeCOBRA = true end

# output information
testFile = @__FILE__

nWorkers = 1

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


# test some functions that are known to throw errors
print_with_color(:green, "\nRunning other tests ...\n\n")

# myModel.mat does not exist
@test_throws ErrorException loadModel("myModel.mat")

# the matrix A does not exist
@test_throws ErrorException loadModel("ecoli_core_model.mat", "A")

# the matrix A does not exist
@test_throws ErrorException loadModel("ecoli_core_model.mat", "R")

# the struct myModel does not exist
@test_throws ErrorException loadModel("ecoli_core_model.mat", "S", "myModel")

# call other fields of the model
@test_throws ErrorException loadModel("ecoli_core_model.mat","S","model",["ubTest","lb","osense","c","b","csense","rxns","mets"])
@test_throws ErrorException loadModel("ecoli_core_model.mat","S","model",["ub","lbTest","osense","c","b","csense","rxns","mets"])
@test_throws ErrorException loadModel("ecoli_core_model.mat","S","model",["ub","lb","osense","cTest","b","csense","rxns","mets"])
@test_throws ErrorException loadModel("ecoli_core_model.mat","S","model",["ub","lb","osense","c","bTest","csense","rxns","mets"])
@test_throws ErrorException loadModel("ecoli_core_model.mat","S","model",["ub","lb","osense","c","b","csense","rxnsTest","mets"])
@test_throws ErrorException loadModel("ecoli_core_model.mat","S","model",["ub","lb","osense","c","b","csense","rxns","metsTest"])

# connect SSH workers that are not reachable
@test_throws ErrorException workersPool, nWorkers = createPool(nWorkers+1, true)

# set a wrong solver handle
model=loadModel("ecoli_core_model.mat")
solver=changeCobraSolver("GLPK")
solver.handle = -1
@test_throws ErrorException solveCobraLP(model, solver)
@test_throws ErrorException buildCobraLP(model, solver)
