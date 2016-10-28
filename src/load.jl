#-------------------------------------------------------------------------------------------
#=
    Purpose:    Load a COBRA model from an existing .mat file
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------
"""
    LPproblem(A, b, c, lb, ub, osense, csense, rxns, mets)

General type for storing an LP problem which contains the following fields:

- `A` or `S`:       LHS matrix (m x n)
- `b`:              RHS vector (m x 1)
- `c`:              Objective coefficient vector (n x 1)
- `lb`:             Lower bound vector (n x 1)
- `ub`:             Upper bound vector (n x 1)
- `osense`:         Objective sense (scalar; -1 ~ "max", +1 ~ "min")
- `csense`:         Constraint senses (m x 1, 'E' or '=', 'G' or '>', 'L' ~ '<')
- `solver`:         A `::SolverConfig` object that contains a valid `handle` to the solver

"""

type LPproblem
    A       ::SparseMatrixCSC{Float64,Int64}
    b       ::Array{Float64,1}
    c       ::Array{Float64,1}
    lb      ::Array{Float64,1}
    ub      ::Array{Float64,1}
    osense  ::Int8
    csense  ::Array{Char,1}
    rxns    ::Array{String,1}
    mets    ::Array{String,1}
end

#-------------------------------------------------------------------------------------------
"""
    loadModel(fileName, matrixAS, modelName)

Function used to load a COBRA model from an existing .mat file

# INPUTS

- `filename`:       Name of the `.mat` file that contains the model structure

# OPTIONAL INPUTS

- `matrixAS`:       String to distinguish the name of stoichiometric matrix ("S" or "A", default: "S")
- `modelName`:      String with the name of the model structure (default: "model")

# OUTPUTS

- `LPproblem()`       `:LPproblem` object with filled fields from `.mat` file

# Examples

- Minimum working example
```julia
julia> loadModel("myModel.mat")
```

- Full input/output example
```julia
julia> model = loadModel("myModel.mat", "A", "myModelName");
```

# Notes

- `osense` is set to "max" by default
- All entries of `A`, `b`, `c`, `lb`, `ub` are of type float

See also: `MAT.jl`, `matopen()`, `matread()`
"""

function loadModel(fileName::String, matrixAS::String="S", modelName::String="model")

    file = matopen(fileName)
    vars = matread(fileName)

    if exists(file, modelName)
        model     = vars[modelName]
        modelKeys = keys(model)

        # load the stoichiometric matrix A or S
        if matrixAS == "A" || matrixAS == "S"
            if matrixAS in modelKeys
                A = model[matrixAS]
            else
                A = model[(matrixAS == "S")? "A" : "S"]
                warn("Matrix ", (matrixAS == "S")? "`A`": "`S`", " instead of ", (matrixAS == "S")? "`S`": "`A`", " has been used.")
            end
        else
            error("Matrix `$matrixAS` does not exist in `$modelName`.")
        end

        # load the upper bound vector ub
        if "ub" in modelKeys
            ub = squeeze(model["ub"], 2)
        else
            error("The vector `ub` does not exist in `$modelName`.")
        end

        # load the upper bound vector lb
        if "lb" in modelKeys
            lb = squeeze(model["lb"], 2)
        else
            error("The vector `lb` does not exist in `$modelName`.")
        end

        # load the objective sense osense
        if "osense" in modelKeys
            osense = model["osense"]
        else
            osense = -1
            info("The model objective is set to be maximized.\n")
        end

        # load the upper bound vector c
        if "c" in modelKeys && osense != 0
            c = squeeze(model["c"], 2)
        else
            error("The vector c does not exist in `$modelName`.")
        end

        # load the upper bound vector c
        if "b" in modelKeys
            b = squeeze(model["b"], 2)
        else
            b = zeros(length(c))
            warn("The vector b does not exist in `$modelName`.")
        end

        # load the constraint senses
        csense = fill('E',length(b)) #assume all equality constraints
        if "csense" in modelKeys
            for i = 1:length(csense)
                csense[i] = model["csense"][i][1] #convert to chars
            end
        else
            info("All constraints assumed equality constaints.\n")
        end

        # load the reaction names vector
        if "rxns" in modelKeys
            rxns = squeeze(model["rxns"], 2)
        else
            warn("The vector rxns does not exist in `$modelName`.")
        end

        # load the reaction names vector
        if "mets" in modelKeys
            mets = squeeze(model["mets"], 2)
        else
            warn("The vector mets does not exist in `$modelName`.")
        end

    else
        error("The variable named `$model` does not exist.")
    end

    #determine the size of A
    nMets = size(A,1)
    nRxns = size(A,2)

    return LPproblem(A, b[1:nMets], c[1:nRxns], lb[1:nRxns], ub[1:nRxns], osense, csense[1:nMets], rxns, mets)

end

export loadModel
#-------------------------------------------------------------------------------------------
