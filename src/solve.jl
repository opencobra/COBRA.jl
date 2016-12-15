#-------------------------------------------------------------------------------------------
#=
    Purpose:    Solver interface for solving COBRA models and LPs
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------
"""
    SolverConfig(name, handle)

Definition of a common solver type, which inclues the name of the solver and other parameters

- `name`:           Name of the solver (alias)
- `handle`:         Solver handle used to refer to the solver

"""

type SolverConfig
  name      ::String
  handle    ::Union{Int64, MathProgBase.SolverInterface.AbstractMathProgSolver}
end

#-------------------------------------------------------------------------------------------
"""
    buildCobraLP(model, solver)

Build a model by interfacing directly with the CPLEX solver

# INPUTS

- `model`:          An `::LPproblem` object that has been built using the `loadModel` function.
                        All fields of `model` must be available.
- `solver`:         A `::SolverConfig` object that contains a valid `handle`to the solver

# OUTPUTS

- `m`:              A MathProgBase.LinearQuadraticModel object with `inner` field

# EXAMPLES

```julia
julia> m = buildCobraLP(model, solver)
```

See also: `MathProgBase.LinearQuadraticModel()`, `MathProgBase.HighLevelInterface.buildlp()`
"""

function buildCobraLP(model, solver::SolverConfig)

    if solver.handle != -1

        # prepare the csense vector when letters instead of symbols are used
        for i = 1:length(model.csense)
            if model.csense[i] == 'E'  model.csense[i] = '='  end
            if model.csense[i] == 'G'  model.csense[i] = '<'  end
            if model.csense[i] == 'L'  model.csense[i] = '>'  end
        end

        return MathProgBase.HighLevelInterface.buildlp(model.osense * model.c, model.S, model.csense, model.b, model.lb, model.ub, solver.handle)
    else

        error("The solver is not supported. Please set solver name to one the supported solvers.")

    end
end

#-------------------------------------------------------------------------------------------
"""
    changeCobraSolver(name, params)

Function used to change the solver and include the respective solver interfaces

# INPUT

- `name`:           Name of the solver (alias)

# OPTIONAL INPUT

- `params`:         Solver parameters as a row vector with tuples

# OUTPUT

- `solver`:         Solver object with a `handle` field

# EXAMPLES

Minimum working example (for the CPLEX solver)
```julia
julia> changeCobraSolver("CPLEX", cpxControl)
```

See also: `MathProgBase.jl`
"""

function changeCobraSolver(name, params = [])

    # convert type of name
    if typeof(name) != :String
        name = string(name)
    end

    # define empty solver object
    solver = SolverConfig(name,0)

    # define the solver handle
    if name == "CPLEX"
        try
            eval(Expr(:using, :CPLEX))
            solver.handle = CplexSolver(params)
        catch
            error("The solver `CPLEX` cannot be set using `changeCobraSolver()`.")
        end

    elseif name == "GLPKMathProgInterface" || name == "GLPK"
        try
            eval(Expr(:using, :GLPKMathProgInterface))
            eval(Expr(:using, :GLPK))
            if length(params) > 1
                solver.handle = GLPKSolverLP(method=params[1], presolve=params[2])
            else
                solver.handle = GLPKSolverLP()
            end
        catch
            error("The solver `GLPK` or `GLPKMathProgInterface` cannot be set using `changeCobraSolver()`.")
        end

    elseif name == "Gurobi"
        try
            eval(Expr(:using, :Gurobi))
            if length(params) > 1
                solver.handle = GurobiSolver(Method=params[1],OutputFlag=params[2])
            else
                solver.handle = GurobiSolver()
            end
        catch
            error("The solver `Gurobi` cannot be set using `changeCobraSolver()`.")
        end

    elseif name == "Clp"
        try
            eval(Expr(:using, :Clp))
            solver.handle = ClpSolver()
        catch
            error("The solver `Clp` cannot be set using `changeCobraSolver()`.")
        end

    elseif name == "Mosek"
        try
            eval(Expr(:using, :Mosek))
            solver.handle = MosekSolver()
        catch
          error("The solver `Mosek` cannot be set using `changeCobraSolver()`.")
        end

    else
        solver.handle = -1
        error("The solver is not supported. Please set the solver name to one the supported solvers.")
    end

    return solver

end

#-------------------------------------------------------------------------------------------
"""
    solveCobraLP(model, solver)

Function used to solve a linear program (LP) with a specified solver.
LP problem must have the form:
```
                                  max/min cᵀv
                                   s.t.  Av = b
                                        l ⩽ v ⩽ u
```
# INPUTS

- `model`:          An `::LPproblem` object that has been built using the `loadModel` function.
                        All fields of `model` must be available.
- `solver`:         A `::SolverConfig` object that contains a valid `handle`to the solver

# OUTPUTS

- `solutionLP`:     Solution object of type `LPproblem`

# EXAMPLES

Minimum working example
```julia
julia> solveCobraLP(model, solver)
```

See also: `MathProgBase.linprog()`,
"""

function solveCobraLP(model, solver)

    if solver.handle != -1

        # retrieve the solution
        m = buildCobraLP(model, solver)
        solutionLP = MathProgBase.HighLevelInterface.solvelp(m)

        # adapt the objective value
        solutionLP.objval = model.osense * solutionLP.objval

        return solutionLP

    else

        error("The solver handle is not set properly using `changeCobraSolver()`.")

    end
end

export buildCobraLP, changeCobraSolver, solveCobraLP
#-------------------------------------------------------------------------------------------
