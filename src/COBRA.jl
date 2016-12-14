#-------------------------------------------------------------------------------------------
#=
    Purpose:    Include all relevant files for running COBRA
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------

VERSION >= v"0.5"

"""
Main module for `COBRA.jl` - COnstraint-Based Reconstruction and Analysis in Julia

The documentation is here: http://opencobra.github.io/COBRA.jl

"""

module COBRA
    # include the load file to load a model of .mat format
    using MAT
    using MathProgBase

    include("load.jl")
    include("solve.jl")
    include("distributedFBA.jl")
end

#-------------------------------------------------------------------------------------------
