#-------------------------------------------------------------------------------------------
#=
    Purpose:    Check the system's configuration
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------
"""
    checkPackage(pkgName)

Function checks whether a package is installed properly or not and returns a boolean value.

# INPUTS

- `pkgName`:        A string that contains the name of the package to be checked

# OPTIONAL INPUTS

- `printLevel`:     Verbose level (default: 1). Mute all output with `printLevel = 0`.

# OUTPUTS

- (bool):           A boolean that indicates whether a package is installed properly

See also: `using`, `isdir()`

"""

function checkPackage(pkgName, printLevel::Int=1)

    try
        eval(Expr(:using, pkgName))
        return true
    catch
        if printLevel > 0
            print_with_color(:yellow, "Package ",string(pkgName), " is not installed. ",
                             "In order to use $pkgName, you must first run `Pkg.add(\"$pkgName\")`\n")
        end
        return false
    end

end

#-------------------------------------------------------------------------------------------
"""
    checkSysConfig(printLevel)

Function evaluates whether the LP solvers of MathProgBase are installed on the system or not and
returns a list of these packages. `MathProgBase.jl` must be installed.

# OPTIONAL INPUTS

- `printLevel`:     Verbose level (default: 1). Mute all output with `printLevel = 0`.

# OUTPUTS

- packages:         A list of solver packages installed on the system

See also: `MathProgBase`, `checkPackage()`

"""

function checkSysConfig(printLevel::Int=1)

    if printLevel > 0
        print_with_color(:yellow, "\n >> Checking the system's configuration ...\n\n")
    end

    #initialize a vector for storing the packages
    packages = []

    # initialize a vector with supported LP solvers
    LPsolvers = [:Clp, :GLPKMathProgInterface, :Gurobi, :CPLEX, :Mosek]

    if checkPackage(:MathProgBase, printLevel)

        # loop through all implemented interfaces
        for s in 1:length(LPsolvers)
            pkgName = LPsolvers[s]

            if checkPackage(pkgName, printLevel)
                if printLevel > 0
                    print_with_color(:green, string(pkgName), " is installed.\n")
                end
                push!(packages, pkgName)
            end

            # load an additional package for GLPK
            if string(pkgName) == "GLPKMathProgInterface"
                checkPackage(:GLPK, printLevel)
            end
        end

    end

    # print an error if no solvers are installed on the system
    try length(packages) == 0
        error("No supported solvers are installed on the current system. Aborting.")

    # print a success message if the solver is installed
    catch
        if printLevel > 0
            print_with_color(:green, "\n >> Done. $(length(packages)) solvers are installed and ready to use.\n")
        end

        return packages
    end
end

# fix deprecation warnings in Julia 0.7
if !isdefined(Base, Symbol("@isdefined"))
    macro isdefined(symbol)
        return isdefined(symbol)
    end

    export @isdefined
end

#-------------------------------------------------------------------------------------------
