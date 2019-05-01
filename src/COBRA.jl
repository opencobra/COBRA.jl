#-------------------------------------------------------------------------------------------
#=
    Purpose:    Include all relevant files for running COBRA
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------

"""
Main module for `COBRA.jl` - COnstraint-Based Reconstruction and Analysis in Julia

The documentation is here: http://opencobra.github.io/COBRA.jl

"""

module COBRA

    # include the load file to load a model of .mat format
    using Pkg, SparseArrays, Distributed, LinearAlgebra
    using MAT
    using MathProgBase
    if "MATLAB" in keys(Pkg.installed())
        using MATLAB
    end

    include("checkSetup.jl")
    checkSysConfig(0)

    include("load.jl")
    include("solve.jl")
    include("distributedFBA.jl")
    include("tools.jl")
    if "MATLAB" in keys(Pkg.installed())
        include("PALM.jl")
    end

end

#-------------------------------------------------------------------------------------------
