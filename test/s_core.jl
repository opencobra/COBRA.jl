#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test core functions (serial)
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------

using Base.Test

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
    using Requests

    include("getTestModel.jl")
end

# download the ecoli_core_model
getTestModel()

# include a common deck for running tests
include("$(Pkg.dir("COBRA"))/config/solverCfg.jl")

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)

# load an external mat file
model = loadModel("$(Pkg.dir("COBRA"))/ecoli_core_model.mat", "S", "model")

# select the number of reactions
rxnsList = 1:length(model.rxns)

# individual building model and then solving it
m = buildCobraLP(model, solver)
solutionLP2 = MathProgBase.HighLevelInterface.solvelp(m)
solutionLP2.objval = model.osense * solutionLP2.objval

# using the new linprog function
solutionLP1 = MathProgBase.linprog(model.osense * model.c, model.S, model.csense, model.b, model.lb, model.ub, solver.handle)
solutionLP1.objval = model.osense * solutionLP1.objval

@test abs(solutionLP2.objval - solutionLP1.objval) < 1e-9

# get the full solution
solutionLP = solveCobraLP(model, solver)

@test abs(solutionLP2.objval - solutionLP.objval) < 1e-9

# define an optPercentage value
optPercentage = 90.0

# launch the distributedFBA process
startTime = time()
minFlux, maxFlux, optSol = distributedFBA(model, solver, nWorkers=nWorkers, optPercentage=optPercentage, preFBA=true)
solTime = time() - startTime

# Test numerical values - test on floor as different numerical precision with different solvers
@test floor(maximum(maxFlux)) == 1000.0
@test floor(minimum(maxFlux)) == -21.0
@test floor(maximum(minFlux)) == 35.0
@test floor(minimum(minFlux)) == -33.0
@test floor(norm(maxFlux))    == 1427.0
@test floor(norm(minFlux))    == 93.0
@test abs((model.c' * minFlux)[1] - optPercentage / 100.0 * optSol) < 1e-6

# save the variables to the current directory
saveDistributedFBA("testFile.mat")

# remove the file to clean up
run(`rm testFile.mat`)

# print a solution summary
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
