#-------------------------------------------------------------------------------------------
#=
    Purpose:    Run several tests
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------

# retrieve all packages that are installed on the system
include("$(Pkg.dir("COBRA"))/src/checkSetup.jl")
packages = checkSysConfig()

# configure for runnint the tests in batch
solverName = :GLPKMathProgInterface #:CPLEX
nWorkers = 4
connectSSHWorkers = false
include("$(Pkg.dir("COBRA"))/src/connect.jl")
TESTDIR = "$(Pkg.dir("COBRA"))/test"

# create a parallel pool and determine its size
if (@isdefined nWorkers) && (@isdefined connectSSHWorkers)
    workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
end

# use the module COBRA and Base.Test modules on all workers
using COBRA
using Base.Test
using Requests

# check if MATLAB package is present
matlabPresent = false;
if sizeof(Pkg.installed("MATLAB")) > 0
    matlabPresent = true;
    using MAT
    using MATLAB
end

# download the ecoli_core_model
include("getTestModel.jl")
getTestModel()

if matlabPresent
    info("The MATLAB package is present. The tests for PALM.jl will be run.")

    # load sharing that is not fair
    nWorkers, quotientModels, remainderModels = COBRA.shareLoad(2)

    #@test nWorkers === 4  # Note: this not the default, it is the number of available workers
    #@test quotientModels == 1
    #@test remainderModels == 0

    # ideal load sharing
    #nWorkers, quotientModels, remainderModels = COBRA.shareLoad(4)

    #@test nWorkers === 2  # Note: this not the default, it is the number of available workers
    #@test quotientModels == 1
    #@test remainderModels == 0

    # prepare a directory with 2 models
    rm(joinpath(TESTDIR, "testModels"), force=true, recursive=true)
    cd(TESTDIR)
    mkdir("testModels")
    cp("ecoli_core_model.mat", "testModels/ecoli_core_model_1.mat")
    cp("ecoli_core_model.mat", "testModels/ecoli_core_model_2.mat")
    cp("ecoli_core_model.mat", "testModels/ecoli_core_model_3.mat")
    cp("ecoli_core_model.mat", "testModels/ecoli_core_model_4.mat")

    varsCharact = ["nMets",
    "nRxns",
    "nElem",
    "nNz"]

    # launch PALM with the scriptFile on the 2 models
    PALM(joinpath(TESTDIR, "testModels"), "scriptFile", 2, "modelCharacteristics.mat", varsCharact, "/tmp/cobratoolbox-cobrajl")

    # remove the directory with the test models
    rm(joinpath(TESTDIR, "testModels"), force=true, recursive=true)
else
    warn("The MATLAB package is not present. The tests for PALM.jl will not be run.")
end


# list all currently supported solvers
supportedSolvers = [:Clp, :GLPKMathProgInterface, :CPLEX, :Gurobi, :Mosek]

# test if an error is thrown for non-installed solvers
for i = 1:length(supportedSolvers)
    if !(supportedSolvers[i] in packages)
        @test_throws ErrorException changeCobraSolver(string(supportedSolvers[i]))
    end
end

includeCOBRA = false

for s = 1:length(packages)
    # define a solvername
    solverName = string(packages[s])

    # read out the directory with the test files
    testDir = readdir(joinpath(Pkg.dir("COBRA"), "test"))

    # print the solver name
    print_with_color(:green, "\n\n -- Running $(length(testDir) - 2) tests using the $solverName solver. -- \n\n")

    # evaluate the test file
    for t = 1:length(testDir)
        # run only parallel and serial test files
        if testDir[t][1:2] == "p_" || testDir[t][1:2] == "s_" || testDir[t][1:2] == "z_"
            print_with_color(:green, "\nRunning $(testDir[t]) ...\n\n")
            include(testDir[t])
        end
    end
end

# remove the results folder to clean up
tmpDir = joinpath(dirname(@__FILE__), "..", "results")
if isdir(tmpDir)
    rm(tmpDir, recursive=true)
end

# print a status line
print_with_color(:green, "\n -- All tests passed. -- \n\n")

#-------------------------------------------------------------------------------------------
