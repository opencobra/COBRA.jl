#-------------------------------------------------------------------------------------------
#=
    Purpose:    Run several tests
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------

using Pkg, Distributed, LinearAlgebra # for Julia ver >= 1.0
import COBRA

pkgDir = joinpath(dirname(pathof(COBRA)))

# retrieve all packages that are installed on the system
include(pkgDir*"/checkSetup.jl")
packages = checkSysConfig()

# configure for runnint the tests in batch
solverName = :GLPKMathProgInterface #:CPLEX
nWorkers = 4
connectSSHWorkers = false
include(pkgDir*"/connect.jl")
TESTDIR = pkgDir*"/../test"

# create a parallel pool and determine its size
if (@isdefined nWorkers) && (@isdefined connectSSHWorkers)
    workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
end

# use the module COBRA and Base.Test modules on all workers
using COBRA
using Test
using HTTP
using Suppressor

# download the ecoli_core_model
include("getTestModel.jl")
getTestModel()

# check if MATLAB package is present
if "MATLAB" in keys(Pkg.installed())
    @info "The MATLAB package is present. The tests for PALM.jl will be run."

    using MAT
    using MATLAB

    # load sharing that is not fair
    nWorkers, quotientModels, remainderModels = COBRA.shareLoad(2)

    @test nWorkers === 4  # Note: this not the default, it is the number of available workers
    @test quotientModels == 1
    @test remainderModels == -1

    # load sharing that is fair (Note: dry-run load sharing)
    nWorkers, quotientModels, remainderModels =  COBRA.shareLoad(4, 2, 0, true)

    @test nWorkers === 2
    @test quotientModels == 2
    @test remainderModels == 0

    # load sharing with exceeding number of workers (Note: dry-run load sharing)
    nWorkers, quotientModels, remainderModels =  COBRA.shareLoad(4, 8, 0, true)

    @test nWorkers === 4 # original number of workers
    @test quotientModels == 1
    @test remainderModels == 0

    # load sharing that is almost ideal (Note: dry-run load sharing)
    nWorkers, quotientModels, remainderModels =  COBRA.shareLoad(8, 3, 1, true)

    @test nWorkers === 3
    @test quotientModels == 3
    @test remainderModels == 2

    # load sharing that is not fair (Note: dry-run load sharing)
    nWorkers, quotientModels, remainderModels =  COBRA.shareLoad(4, 3, 1, true)

    @test nWorkers === 3
    @test quotientModels == 2
    @test remainderModels == 0

    # prepare a directory with 2 models
    rm(joinpath(TESTDIR, "testModels"), force=true, recursive=true)
    cd(TESTDIR)
    mkdir("testModels")
    for k = 1:4
        cp("ecoli_core_model.mat", "testModels/ecoli_core_model_$k.mat")
    end

    varsCharact = ["nMets",
                   "nRxns",
                   "nElem",
                   "nNz"]

    # launch PALM with the scriptFile on the 2 models
    PALM(joinpath(TESTDIR, "testModels"), "scriptFile", nMatlab=2, outputFile="modelCharacteristics.mat", varsCharact=varsCharact, cobraToolboxDir=ENV["HOME"]*"/tmp/cobratoolbox-cobrajl")

    # remove the directory with the test models
    rm(joinpath(TESTDIR, "testModels"), force=true, recursive=true)
else
    @warn "The MATLAB package is not present. The tests for PALM.jl will not be run."
end


# list all currently supported solvers
supportedSolvers = [:Clp, :GLPKMathProgInterface, :CPLEX, :Gurobi, :Mosek]

# test if an error is thrown for non-installed solvers
for i = 1:length(supportedSolvers)
    print(" > Testing $(supportedSolvers[i]) ... ")
    if !(supportedSolvers[i] in packages)
        @test_throws ErrorException changeCobraSolver(string(supportedSolvers[i]))
        printstyled("Not supported.\n"; color=:red)
    else
        @test typeof(changeCobraSolver(supportedSolvers[i])) == COBRA.SolverConfig
        printstyled("Done.\n"; color=:green)
    end
end

includeCOBRA = false

for s in packages
    # define a solvername
    global solverName = string(s)

    # read out the directory with the test files
    testDir = readdir(TESTDIR)

    # print the solver name
    printstyled("\n\n -- Running $(length(testDir) - 2) tests using the $solverName solver. -- \n\n"; color=:green)

    # evaluate the test file
    for t = 1:length(testDir)
        # run only parallel and serial test files
        if testDir[t][1:2] in ["p_", "s_", "z_"]
            printstyled("\nRunning $(testDir[t]) ...\n\n"; color=:green)
            include(testDir[t])
        end
    end
end

# remove the results folder to clean up
tmpDir = joinpath(dirname(@__FILE__), "..", "results")
if isdir(tmpDir)
    try
        rm("$tmpDir", recursive=true, force=true)
    catch
        info("The directory $tmpDir cannot be removed. Please check permissions.\n")
    end
end

# print a status line
printstyled("\n -- All tests passed. -- \n\n"; color=:green)

#-------------------------------------------------------------------------------------------
