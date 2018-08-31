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
    using MAT
    using MathProgBase
    if sizeof(Pkg.installed("MATLAB")) > 0
        using MATLAB
    end

    include("checkSetup.jl")
    checkSysConfig(0)

    include("load.jl")
    include("solve.jl")
    include("distributedFBA.jl")
    include("tools.jl")
    if sizeof(Pkg.installed("MATLAB")) > 0
        include("PALM.jl")
    end

end

#-------------------------------------------------------------------------------------------
