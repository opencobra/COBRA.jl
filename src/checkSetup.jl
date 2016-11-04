#-------------------------------------------------------------------------------------------
#=
    Purpose:    Check the system's configuration
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------
"""
    checkPackage(pkgname)

Function checks whether a package is installed properly or not and returns a boolean value.

# INPUTS

- `pkgname`:        A string that contains the name of the package to be checked

# OUTPUTS

- (bool):           A boolean that indicates whether a package is installed properly

See also: `using`, `isdir()`

"""

function checkPackage(pkgname)

    try
        eval(Expr(:using,pkgname))
        return true
    catch
        if isdir(Pkg.dir((string(pkgname))))
           print_with_color(:yellow, "Package ",string(pkgname),
               " is installed but couldn't be loaded. ",
               "You may need to run `Pkg.build(\"$pkgname\")`\n")
        else
           print_with_color(:yellow, "Package ",string(pkgname), " is not installed. ",
               "In order to use $pkgname, you must first run `Pkg.add(\"$pkgname\")`\n")
        end
        return false
    end



end

#-------------------------------------------------------------------------------------------
"""
    checkSysConfig()

Function evaluates whether the LP solvers of MathProgBase are installed on the system or not and
returns a list of these packages. `MathProgBase.jl` must be installed.

# OUTPUTS

- packages:         A list of solver packages installed on the system

See also: `MathProgBase`, `checkPackage()`

"""

function checkSysConfig()

    print_with_color(:yellow, "\n >> Checking the system's configuration ...\n\n")

    #initialize a vector for storing the packages
    packages = []

    if checkPackage(:MathProgBase)

        # loop through all implemented interfaces
        for s in 1:length(MathProgBase.LPsolvers)
            pkgname = MathProgBase.LPsolvers[s][1]

            if checkPackage(pkgname)
                print_with_color(:green, string(pkgname), " is installed.\n")
                push!(packages, pkgname)
            end

            # load an additional package for GLPK
            if string(pkgname) == "GLPKMathProgInterface"
                checkPackage(:GLPK)
            end
        end

    end

    # print an error if no solvers are installed on the system
    try length(packages) == 0
        error("No supported solvers are installed on the current system. Aborting.")

    # print a success message if the solver is installed
    catch
        print_with_color(:green, "\n >> Done. $(length(packages)) solvers are installed and ready to use.\n")
        return packages

    end

end

#-------------------------------------------------------------------------------------------
