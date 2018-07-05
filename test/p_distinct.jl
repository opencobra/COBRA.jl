#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test particular reactions (parallel)
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
nWorkers = 4

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

# include the solver configuration file
include("$(Pkg.dir("COBRA"))/config/solverCfg.jl")

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)

# load an external mat file
model = loadModel("$(Pkg.dir("COBRA"))/test/ecoli_core_model.mat", "S", "model")

# define an optPercentage value
optPercentage = 90.0

# run all the reactions as a reference
minFlux1, maxFlux1, optSol1, fbaSol1, fvamin1, fvamax1, statussolmin1, statussolmax1 = distributedFBA(model, solver, nWorkers=nWorkers, optPercentage=optPercentage, preFBA=true)

rxnsList = [1; 2; 3; 4; 12; 28]
rxnsOptMode = [0; 1; 2; 0; 1; 2] # min: 1, 3, 4, 28; max: 2, 3, 12, 28

# run only a few reactions with rxnsOptMode and rxnsList
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, preFBA=true, optPercentage=optPercentage, rxnsList=rxnsList, rxnsOptMode=rxnsOptMode)

# test the solution status
@test isequal(statussolmin[rxnsList], [1, NaN, 1, 1, NaN, 1])
@test isequal(statussolmax[rxnsList], [NaN, 1, 1, NaN, 1, 1])
@test minFlux[1:4] != minFlux[[1, 3, 4, 28]]

# test fbaSol vectors
@test norm(fbaSol - fbaSol1) < 1e-9
@test abs(optSol - optSol1) < 1e-9

#other solvers (e.g., CPLEX) might report alternate optimal solutions
if solverName == "GLPKMathProgInterface"
    # test minimum and maximum flux vectors
    @test norm(fvamin[:,[1, 3, 4, 28]] - fvamin1[:,[1, 3, 4, 28]]) < 1e-9
    @test norm(fvamax[:,[2, 3, 12, 28]] - fvamax1[:,[2, 3, 12, 28]]) < 1e-9
end

# test rxnsOptMode and rxnsList criteria
@test norm(minFlux[[1, 3, 4, 28]] - minFlux1[[1, 3, 4, 28]]) < 1e-9
@test norm(maxFlux[[2, 3, 12, 28]] - maxFlux1[[2, 3, 12, 28]]) < 1e-9

# run only the reactions of the rxnsList (both maximizations and minimizations)
startTime = time()
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, preFBA=true, optPercentage=optPercentage, rxnsList=rxnsList)
solTime = time() - startTime

@test norm(minFlux1[rxnsList] - minFlux[rxnsList]) < 1e-9
@test norm(maxFlux1[rxnsList] - maxFlux[rxnsList]) < 1e-9
@test norm(optSol1 - optSol) < 1e-9
@test norm(fbaSol1 - fbaSol) < 1e-9

#other solvers (e.g., CPLEX) might report alternate optimal solutions
if solverName == "GLPKMathProgInterface"
    # test minimum and maximum flux vectors
    @test norm(fvamin[:,[1,3,4,28]] - fvamin1[:,[1,3,4,28]]) < 1e-9
    @test norm(fvamax[:,[2,3,12,28]] - fvamax1[:,[2,3,12,28]]) < 1e-9
end

# save the variables to the current directory
saveDistributedFBA("testFile.mat")

# remove the file to clean up
run(`rm testFile.mat`)

# print a solution summary
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
