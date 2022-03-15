#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test core functions (serial)
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
nWorkers = 1

pkgDir = joinpath(dirname(pathof(COBRA)), "..")

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
#run(`rm testFile.mat`)

# load a coupled model (printLevel = 0)
modelCoupled = loadModel("modelCoupled.mat", "modelCoupled")

# test the size of the combined S matrix
@test size(modelCoupled.S, 1) == length(modelCoupled.mets)
@test size(modelCoupled.S, 2) == length(modelCoupled.rxns)

# load a coupled model (printLevel = 1)
modelCoupled = loadModel("modelCoupled.mat", "modelCoupled", 1)

# test the size of the combined S matrix
@test size(modelCoupled.S, 1) == length(modelCoupled.mets)
@test size(modelCoupled.S, 2) == length(modelCoupled.rxns)

# print a solution summary
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
