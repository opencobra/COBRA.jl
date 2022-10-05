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
    import Pkg
    using SparseArrays, Distributed, LinearAlgebra
    using MAT, MathOptInterface, JuMP
    #using MATLAB

    include("checkSetup.jl")
    checkSysConfig(0)

    include("load.jl")
    include("solve.jl")
    include("distributedFBA.jl")
    include("tools.jl")
    include("PALM.jl")
    include("connect.jl")

end

#-------------------------------------------------------------------------------------------
