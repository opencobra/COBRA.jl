#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test a single FBA
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

modelOrig = model

nWorkers = 1
rxnsList = 13
rxnsOptMode = 1  # maximization

# define an optPercentage value
optPercentage = 10.0

for s = 0:2
    # launch the distributedFBA process
    startTime   = time()
    minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, optPercentage=optPercentage, objective="min", rxnsList=rxnsList, strategy=s, rxnsOptMode=rxnsOptMode, preFBA=false)
    solTime = time() - startTime

    # Test numerical values - test on ceil as different numerical precision with different solvers
    @test ceil(maximum(maxFlux)) == 1.0
    @test ceil(minimum(maxFlux)) == 0.0
    @test ceil(maximum(minFlux)) == 0.0
    @test ceil(minimum(minFlux)) == 0.0
    @test ceil(norm(maxFlux))    == 1.0
    @test ceil(norm(minFlux))    == 0.0
    @test isequal(optSol, NaN)
    @test isequal(fbaSol, NaN * zeros(length(model.rxns)))

    # print a solution summary
    printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
end

# -------------------------------------------------------------------------------------

# reload an external mat file
model = modelOrig

# launch the distributedFBA process with only 1 reaction
startTime = time()
minFlux, maxFlux, optSol  = distributedFBA(model, solver, nWorkers=nWorkers, objective="", rxnsList=rxnsList, rxnsOptMode=rxnsOptMode, preFBA=false);
solTime = time() - startTime

status, objval, sol = solveCobraLP(model, solver)  # in the model, objective is assumed to be maximized
fbaObj = objval
fbaSol = sol

@test abs(maxFlux[rxnsList] - fbaObj) < 1e-9

# print a solution summary
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)

# -------------------------------------------------------------------------------------

# reload an external mat file
model = modelOrig

model.osense = 1  # minimization - in the model, objective is assumed to be maximized
rxnsOptMode = -1  # minimization
startTime   = time()
minFlux, maxFlux, optSol  = distributedFBA(model, solver, nWorkers=nWorkers, objective="", rxnsList=rxnsList, rxnsOptMode=rxnsOptMode, preFBA=false);
solTime = time() - startTime

status, objval, sol = solveCobraLP(model, solver)
fbaObj = objval
fbaSol = sol

@test abs(minFlux[rxnsList] - fbaObj) < 1e-9

# save the variables to the current directory
saveDistributedFBA("testFile.mat")

# remove the file to clean up
#run(`rm testFile.mat`)

# print a solution summary
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
