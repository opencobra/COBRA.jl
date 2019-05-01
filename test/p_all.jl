#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test all reactions (parallel)
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------

using Test, LinearAlgebra

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

# include a common deck for running tests
include("$(Pkg.dir("COBRA"))/config/solverCfg.jl")

# load an external mat file
model = loadModel("$(Pkg.dir("COBRA"))/test/ecoli_core_model.mat", "S", "e_coli_core")

# test that no output is produced with printLevel = 0
@info " > Testing silent $solverName ..."
solver = changeCobraSolver(solverName, printLevel=0)
output = @capture_out minFlux, maxFlux = distributedFBA(model, solver; nWorkers=nWorkers, printLevel=0, rxnsList=1:4)
if string(solverName) == "Gurobi"
    @test length(matchall(r"From worker ", output)) == 2*nWorkers
else
    @test length(output) == 0
end
@info " > Done testing silent $solverName."

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)

# select the number of reactions
rxnsList = 1:length(model.rxns)

# JL: Changed minFluxT and maxFluxT due to a different version of e_coli_core (BIGG)
minFluxT = [-2.542383644
            -2.542383644
            -3.813575466
            0.84858603
            0.84858603
            -3.813575466
            0
            0
            -1.4300908
            -2.214334142
            8.39
            34.82557929
            0.7865289
            -26.5288694
            0.84858603
            35.98482481
            -2.1451362
            8.686582477
            -2.214334142
            0
            0
            0
            15.20649461
            0
            0
            0
            0
            -10
            0
            0
            15.77776973
            20.93588573
            0
            0
            -5.559976608
            -25.61956333
            -3.214895048
            0
            0
            1.17169919
            0
            0
            -68.64435839
            0
            0
            -0.512922598
            0
            0
            9.863229712
            9.046606133
            0.20111544
            0
            -5.358861168
            0
            0
            -1.271191822
            0
            -32.25826052
            0.84858603
            0
            -2.1451362
            0
            0
            -3.249778929
            0
            0
            32.6591202
            0
            4.288784786
            17.9924124
            0
            1.17169919
            0
            -14.29905996
            -17.90917023
            0
            -16.73252299
            2.893403864
            0
            0
            0
            0
            0
            -2.542383644
            -0.620909007
            -8.611297487
            0
            0
            0
            -8.045940513
            -0.154536201
            0
            -0.154536201
            -0.466372806
            1.17169919
            ]

maxFluxT = [0
            0
            0
            0.008894527
            0.008894527
            0
            0.01716109
            0.008045941
            0
            0
            0.02555109
            0.059381115
            0.000873922
            -0.015206495
            0.008894527
            0.051239127
            0
            0.016732523
            0
            0.003813575
            0.002542384
            0.001430091
            0.026528869
            0.002214334
            0.011322375
            0
            0
            -0.009046606
            0
            0.001271192
            0.027100145
            0.032258261
            0.002145136
            0
            -0.004288785
            -0.017992412
            -0.002893404
            0.002542384
            0.001674253
            0.00921764
            0.01716109
            0.068644358
            0
            1
            0
            0.008045941
            0
            0.024137822
            0.01790917
            0.01
            0.017362205
            0
            0.01307342
            0.01716109
            0.01716109
            0
            0.024137822
            -0.020935886
            0.008894527
            0.008045941
            0
            0.008045941
            0
            0.016091881
            0.011935942
            0.01531869
            0.051239127
            0.044759781
            0.005559977
            0.025619563
            0.01988822
            0.025290737
            0.011322375
            0.009838762
            -0.00986323
            0.024137822
            -0.008686582
            0.003214895
            0.020346956
            0.01716109
            0.01716109
            0.003813575
            0.021383088
            0
            0.015526524
            -0.000565357
            0.022881453
            0.022881453
            1
            0
            0.00790523
            0.037042161
            0.00790523
            0.007621294
            0.00921764
            ]

for s = 0:2
    # define an optPercentage value
    optPercentage = 90 # define optPercentage as Int64 (will be converted to Float64)

    # launch the distributedFBA process
    startTime = time()
    minFlux, maxFlux, optSol = distributedFBA(model, solver; nWorkers=nWorkers, preFBA=true, optPercentage=optPercentage, objective="max", rxnsList=rxnsList, strategy=s)
    solTime = time() - startTime

    # Test numerical values - test on floor as different numerical precision with different solvers
    @test floor(maximum(maxFlux)) == 1000.0
    @test floor(minimum(maxFlux)) == -21.0
    @test floor(maximum(minFlux)) == 35.0
    @test floor(minimum(minFlux)) == -69.0 # JL: The changed values must be checked in the future; possibly due to changing e_coli_core
    @test floor(norm(maxFlux))    == 1425.0 # JL: The changed values must be checked in the future; possibly due to changing e_coli_core
    @test floor(norm(minFlux))    == 116.0 # JL: The changed values must be checked in the future; possibly due to changing e_coli_core
    @test abs((model.c' * minFlux)[1] - optPercentage / 100.0 * optSol) < 1e-6

    # test each element of the minimum and maximum flux vectors
    for i = 1:length(minFlux)
        @test abs(minFluxT[i] - minFlux[i]) < 1e-3
        @test abs(maxFluxT[i]*1000 - maxFlux[i]) < 1e-3
    end

    # print a solution summary
    printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
end

if solverName != "Mosek"
    # Note: Mosek is not able to solve this problem
    # launch the distributedFBA process
    startTime = time()
    minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax = distributedFBA(model, solver, nWorkers=nWorkers, preFBA=true, optPercentage=100.0)
    solTime = time() - startTime

    # Test numerical values - test on floor as different numerical precision with different solvers

    @test floor(maximum(maxFlux)) == 1000.0
    @test floor(minimum(maxFlux)) == -30.0
    @test floor(maximum(minFlux)) == 45.0
    @test floor(minimum(minFlux)) == -30.0
    @test floor(norm(maxFlux))    == 1414.0
    @test floor(norm(minFlux))    == 106.0
    @test abs((model.c' * minFlux)[1] - optSol) < 1e-6

    # save the variables to the current directory
    saveDistributedFBA("testFile.mat")

    # remove the file to clean up
    run(`rm testFile.mat`)

    # print a solution summary
    printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
end

# define model and solution parameters
optPercentage = 90.0
objective = "max"
maxtrixAS = "S"
modelName = "model"

# test to save individual result files (chunks)
saveChunks = true
strategy = 0

# select the number of reactions
rxnsList = 1:length(model.rxns)

# select the reaction optimization mode
rxnsOptMode = 2 + zeros(Int64, length(rxnsList))

minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, optPercentage=optPercentage, strategy=strategy, preFBA=true, saveChunks=saveChunks)

# print a solution summary with full output
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName, strategy, saveChunks)

# remove the results folder to clean up
run(`rm -rf $(Pkg.dir("COBRA"))/results`)

# create folders if they are not present
if !isdir("$(Pkg.dir("COBRA"))/results")
    mkdir("$(Pkg.dir("COBRA"))/results")
    print_with_color(:green, "Directory `results` created.\n\n")

    # create a folder for storing the chunks of the fluxes of each minimization
    if !isdir("$(Pkg.dir("COBRA"))/results/fvamin")
        mkdir("$(Pkg.dir("COBRA"))/results/fvamin")
    end

    # create a folder for storing the chunks of the fluxes of each maximization
    if !isdir("$(Pkg.dir("COBRA"))/results/fvamax")
        mkdir("$(Pkg.dir("COBRA"))/results/fvamax")
    end
else
    print_with_color(:cyan, "Directory `results` already exists.\n\n")
end

minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, preFBA=true, saveChunks=true)

# print a solution summary with full output
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName, strategy, saveChunks)

# output only the fluxes
minFlux, maxFlux = distributedFBA(model, solver, onlyFluxes=true)

minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, onlyFluxes=true)

@test isequal(fvamin, NaN * zeros(1, 1))
@test isequal(fvamax, NaN * zeros(1, 1))
@test isequal(statussolmin, ones(Int, length(rxnsList)))
@test isequal(statussolmax, ones(Int, length(rxnsList)))

minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, onlyFluxes=true)

@test isequal(fvamin, NaN * zeros(1, 1))
@test isequal(fvamax, NaN * zeros(1, 1))
@test isequal(statussolmin, ones(Int, length(rxnsList)))
@test isequal(statussolmax, ones(Int, length(rxnsList)))

saveDistributedFBA("testFile.mat", ["minFlux", "maxFlux"])

# call saveDistributedFBA with no variables
saveDistributedFBA("testFile.mat", [""])

# remove the file to clean up
run(`rm testFile.mat`)

# remove the results folder to clean up
run(`rm -rf $(Pkg.dir("COBRA"))/results`)

# create the logs folder
resultsDir = "$(Pkg.dir("COBRA"))/results"

if isdir("$resultsDir/logs")
    rm("$resultsDir/logs")
    print_with_color(:green, "$resultsDir/logs folder created")
end

# call to create a log files directory
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, resultsDir=resultsDir, nWorkers=nWorkers, saveChunks=true, logFiles=true, rxnsList=1:10)

# test if the /logs folder has been created
@test isdir("$resultsDir/logs")

# remove the results folder to clean up
run(`rm -rf $(Pkg.dir("COBRA"))/results`)

# call to create a log files directory (throws a warning message)
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, saveChunks=true, onlyFluxes=true, rxnsList=1:10)

# call to throw a warning message when nRxnsList < nWorkers (throws a warning message)
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, rxnsList=1:2)

# call to write logFiles with onlyFluxes
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, onlyFluxes=true, rxnsList=1:10, logFiles=true)

# test if the /logs folder has been created
@test isdir("$(Pkg.dir("COBRA"))/results/logs")

# remove the results folder to clean up
run(`rm -rf $(Pkg.dir("COBRA"))/results`)
