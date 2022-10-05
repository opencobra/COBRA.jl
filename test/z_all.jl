#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test all reactions (serial)
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

pkgDir = joinpath(mkpath("COBRA"), "..")

# create a pool and use the COBRA module if the testfile is run in a loop
if includeCOBRA
    connectSSHWorkers = false
    include(pkgDir*"/src/connect.jl")

    # create a parallel pool and determine its size
    if isdefined(:nWorkers) && isdefined(:connectSSHWorkers)
        workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
    end

    using COBRA
    using HTTP

    include("getTestModel.jl")
end

# download the ecoli_core_model
getTestModel()

# include a common deck for running tests
include(pkgDir*"/config/solverCfg.jl")

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)

# test a non-supported solver
@test_throws ErrorException changeCobraSolver("mySolver")

# test some functions that are known to throw errors
printstyled("\n>> The following tests throw warning messages for testing purposes. <<\n\n"; color=:yellow)

# test if an error is thrown when myModel.mat does not exist
@test_throws ErrorException loadModel("myModel.mat")

# test if an error is thrown when the matrix A does not exist
@test_throws ErrorException loadModel(pkgDir*"/test/ecoli_core_model.mat", "A")

# test if an error is thrown when the matrix A does not exist
@test_throws ErrorException loadModel(pkgDir*"/test/ecoli_core_model.mat", "R")

# test if an error is thrown when the struct myModel does not exist
@test_throws ErrorException loadModel(pkgDir*"/test/ecoli_core_model.mat", "S", "myModel")

# connect SSH workers that are not reachable
@test createPool(1, false) == (workers(), 1)
@test_throws ErrorException workersPool, nWorkers = createPool(0, false)
@test_throws ErrorException workersPool, nWorkers = createPool(0, true, "")
@test_throws ErrorException workersPool, nWorkers = createPool(0, true)

# connect twice the same number of workers
@test createPool(4) == (workers(), 4)
@test createPool(2) == (workers(), 2)

# load a new version of the model
model = loadModel(pkgDir*"/test/ecoli_core_model.mat")

# run a model with more reactions on the reaction list than in the model
rxnsList = 1:length(model.rxns) + 1
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=1, optPercentage=90.0, objective="min", rxnsList=rxnsList)

# test preFBA! with min
optSol, fbaSol = preFBA!(model, solver, 90.0, "min")

# test if model does not have an objective (no return values)
model.c = 0.0 * model.c
@test_throws MethodError optSol, fbaSol = preFBA!(model, solver, 90.0, "min")

# set a wrong solver handle
model = loadModel(pkgDir*"/test/ecoli_core_model.mat")
solver = changeCobraSolver(solverName, solParams)
solver.handle = -1
@test_throws ErrorException solveCobraLP(model, solver)
@test_throws ErrorException buildCobraLP(model, solver)

# test if an infeasible solution status is returned
solver = changeCobraSolver(solverName, solParams)
m, x, c = buildlp([1.0, 0.0], [2.0 1.0], '<', -1.0, solver.handle)
retObj, retFlux, retStat = loopFBA(m, x, c, 1, 2)
if solverName == "Clp" || solverName == "Gurobi" || solverName == "CPLEX" || solverName == "Mosek"
    @test retStat[1] == 0 # infeasible
else
    @test retStat[1] == 5 # undocumented status
end

# load the test model
modelTest = loadModel(pkgDir*"/test/testData.mat", "S", "modelTest")
@test modelTest.osense == -1
@test modelTest.csense == fill('E', length(modelTest.b))

# test buildlp and solvelp for an unbounded problem
m, x, c = buildlp([-1.0, -1.0], [-1.0 2.0], '<', [0.0], solver.handle)
status, objval, sol = solvelp(m, x)
if solver.name == "Clp" || solver.name == "Gurobi" || solver.name == "GLPK" || solver.name == "Mosek"
    @test sol.status == MathOptInterface.TerminationStatusCode(6)
elseif solverName == "CPLEX"
    @test sol.status == MathOptInterface.TerminationStatusCode(6)
end

# solve an unbounded problem using loopFBA
m, x, c = buildlp([0.0, -1.0], [-1.0 2.0], '<', [0.0], solver.handle)
retObj, retFlux, retStat = loopFBA(m, x, c, 1, 2, 2, 1)
if solver.name == "Clp" || solver.name == "Gurobi" || solver.name == "GLPK" || solver.name == "Mosek"
    @test isequal(retStat, [2, NaN]) # unbounded and not solved
elseif solver.name == "CPLEX"
    @test isequal(retStat, [4, NaN]) # unbounded and not solved
end

printstyled("\n >> Note: Warnings above are thrown for testing purposes and can be safely ignored.\n"; color=:yellow)
