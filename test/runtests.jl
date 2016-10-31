#-------------------------------------------------------------------------------------------
#=
    Purpose:    Run several tests
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------

# retrieve all packages that are installed on the system
include("$(dirname(pwd()))/src/checkSetup.jl")
packages = checkSysConfig()

using Base.Test

# configure for runnint the tests in batch
solverName = :GLPKMathProgInterface #:CPLEX
nWorkers = 4
connectSSHWorkers = false
include("$(dirname(pwd()))/src/connect.jl")

# create a parallel pool and determine its size
if isdefined(:nWorkers) && isdefined(:connectSSHWorkers)
    workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
end

# use the module COBRA on all workers
using COBRA

# list all currently supported solvers
supportedSolvers = [:Clp, :GLPKMathProgInterface, :CPLEX, :Gurobi, :Mosek]

# test if an error is thrown for non-installed solvers
for i = 1:length(supportedSolvers)
    if !(supportedSolvers[i] in packages)
        @test_throws ErrorException changeCobraSolver(string(supportedSolvers[i]))
    end
end

# test a non-supported solver
@test_throws ErrorException changeCobraSolver("mySolver")

includeCOBRA = false

for s in 1:length(packages)

    # define a solvername
    solverName = string(packages[s])

    # read out the directory with the test files
    testDir = readdir(".")

    # print the solver name
    print_with_color(:green, "\n\n -- Running $(length(testDir) - 2) tests using the $solverName solver. -- \n\n")

    # evaluate the test file
    for t in 1:length(testDir)
        # run only parallel and serial test files
        if testDir[t][1:2] == "p_" || testDir[t][1:2] == "s_" || testDir[t][1:2] == "z_"
            print_with_color(:green, "\nRunning $(testDir[t]) ...\n\n")
            include(testDir[t])
        end
    end
end

# print a status line
print_with_color(:green, "\n -- All tests passed. -- \n\n")

#-------------------------------------------------------------------------------------------
