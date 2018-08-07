#-------------------------------------------------------------------------------------------
#=
    Purpose:    Include all relevant files for running COBRA
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------

VERSION >= v"0.6"

"""
Main module for `COBRA.jl` - COnstraint-Based Reconstruction and Analysis in Julia

The documentation is here: http://opencobra.github.io/COBRA.jl

"""

module COBRA

    # include the load file to load a model of .mat format
    using MAT
    using MathProgBase
    using MATLAB

    if "JENKINS" in keys(ENV)
        info("JENKINS CI server detected. Workers will be added with test environment configuration.")
        include("$JULIA_HOME/../share/julia/test/testenv.jl")
        addprocsCOBRA = addprocs_with_testenv
    else
        addprocsCOBRA = addprocs
    end

    include("checkSetup.jl")
    checkSysConfig(0)

    include("load.jl")
    include("solve.jl")
    include("distributedFBA.jl")
    include("tools.jl")
    include("PALM.jl")
end

#-------------------------------------------------------------------------------------------
