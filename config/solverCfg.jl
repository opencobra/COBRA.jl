#-------------------------------------------------------------------------------------------
#=
    Purpose:    Define an array with all solver parameters
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------

if !@isdefined solverName
    solverName = :GLPK
end

if typeof(solverName) != :String
    solverName = string(solverName)
end

if solverName == "CPLEX"
    # set solver parameters
    solParams = [
        # decides whether or not results are displayed on screen in an application of the C API.
        (:CPX_PARAM_SCRIND,         0);

        # sets the parallel optimization mode. Possible modes are automatic, deterministic, and opportunistic.
        (:CPX_PARAM_PARALLELMODE,   1);

        # sets the default maximal number of parallel threads that will be invoked by any CPLEX parallel optimizer.
        (:CPX_PARAM_THREADS,        1);

        # partitions the number of threads for CPLEX to use for auxiliary tasks while it solves the root node of a problem.
        (:CPX_PARAM_AUXROOTTHREADS, 2);

        # decides how to scale the problem matrix.
        (:CPX_PARAM_SCAIND,         1);

        # controls which algorithm CPLEX uses to solve continuous models (LPs).
        (:CPX_PARAM_LPMETHOD,       0)
    ] #end of solParams

elseif solverName == "GLPKMathProgInterface" || solverName == "GLPK"
    solParams = [:Simplex,    #Method
                 true        #presolve
    ] #end of solParams

elseif solverName == "Gurobi"
    solParams = [2,           #Method
                 0             #OutputFlag
    ] #end of solParams

elseif solverName == "Clp"
    solParams = [] #end of solParams

elseif solverName == "Mosek"
    solParams = [] #end of solParams

else
    solParams = [] #end of solParams
    warn("The solver is not supported. No solver parameters have been set.")
end
