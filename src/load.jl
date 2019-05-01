#-------------------------------------------------------------------------------------------
#=
    Purpose:    Load a COBRA model from an existing .mat file
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------
"""
    LPproblem(S, b, c, lb, ub, osense, csense, rxns, mets)

General type for storing an LP problem which contains the following fields:

- `S`:              LHS matrix (m x n)
- `b`:              RHS vector (m x 1)
- `c`:              Objective coefficient vector (n x 1)
- `lb`:             Lower bound vector (n x 1)
- `ub`:             Upper bound vector (n x 1)
- `osense`:         Objective sense (scalar; -1 ~ "max", +1 ~ "min")
- `csense`:         Constraint senses (m x 1, 'E' or '=', 'G' or '>', 'L' ~ '<')
- `solver`:         A `::SolverConfig` object that contains a valid `handle` to the solver

"""

mutable struct LPproblem
    S       ::Union{SparseMatrixCSC{Float64,Int64}, AbstractMatrix}
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
    loadModel(fileName, matrixAS, modelName, modelFields, printLevel)

Function used to load a COBRA model from an existing .mat file

# INPUTS

- `filename`:       Name of the `.mat` file that contains the model structure

# OPTIONAL INPUTS

- `matrixAS`:       String to distinguish the name of stoichiometric matrix ("S" or "A", default: "S")
- `modelName`:      String with the name of the model structure (default: "model")
- `modelFields`:    Array with strings of fields of the model structure (default: ["ub", "lb", "osense", "c", "b", "csense", "rxns", "mets"])
- `printLevel`:     Verbose level (default: 1). Mute all output with `printLevel = 0`.

# OUTPUTS

- `LPproblem()`     `:LPproblem` object with filled fields from `.mat` file

# Examples

- Minimum working example
```julia
julia> loadModel("myModel.mat")
```

- Full input/output example
```julia
julia> model = loadModel("myModel.mat", "A", "myModelName", ["ub","lb","osense","c","b","csense","rxns","mets"]);
```

# Notes

- `osense` is set to "max" (osense = -1) by default
- All entries of `A`, `b`, `c`, `lb`, `ub` are of type float

See also: `MAT.jl`, `matopen()`, `matread()`
"""

function loadModel(fileName::String, matrixAS::String="S", modelName::String="model", modelFields::Array{String,1}=["ub", "lb", "osense", "c", "b", "csense", "rxns", "mets"], printLevel::Int=1)

    file = matopen(fileName)
    vars = matread(fileName)

    if exists(file, modelName)

        model     = vars[modelName]
        modelKeys = keys(model)

        # load the stoichiometric matrix A or S
        if matrixAS == "A" || matrixAS == "S"
            if matrixAS in modelKeys
                S = sparse(model[matrixAS])
            else
                S = sparse(model[(matrixAS == "S") ? "A" : "S"])
                error("Matrix `$matrixAS` does not exist in `$modelName`, but matrix `S` exists. Set `matrixAS = S` if you want to use `S`.")
            end
        else
            error("Matrix `$matrixAS` does not exist in `$modelName`.")
        end

        # load the upper bound vector ub
        if modelFields[1] in modelKeys
            ub = dropdims(model[modelFields[1]]; dims = 2)
        else
            error("The vector `$(modelFields[1])` does not exist in `$modelName`.")
        end

        # load the upper bound vector lb
        if modelFields[2] in modelKeys
            lb = dropdims(model[modelFields[2]]; dims = 2)
        else
            error("The vector `$(modelFields[2])` does not exist in `$modelName`.")
        end

        # load the objective sense osense
        if modelFields[3] in modelKeys
            osense = model[modelFields[3]]
        else
            osense = -1
            if printLevel > 0
                @info "The model objective is set to be maximized."
            end
        end

        # load the upper bound vector c
        if modelFields[4] in modelKeys && osense != 0
            c = dropdims(model[modelFields[4]]; dims = 2)
        else
            error("The vector `$(modelFields[4])` does not exist in `$modelName`.")
        end

        # load the upper bound vector c
        if modelFields[5] in modelKeys
            b = dropdims(model[modelFields[5]]; dims = 2)
        else
            b = zeros(length(c))
            error("The vector `$(modelFields[5])` does not exist in `$modelName`.")
        end

        # load the constraint senses
        csense = fill('E',length(b)) #assume all equality constraints
        if modelFields[6] in modelKeys
            for i = 1:length(csense)
                csense[i] = model[modelFields[6]][i][1] #convert to chars
            end
        else
            if printLevel > 0
                @info "All constraints assumed equality constaints."
            end
        end

        # load the reaction names vector
        if modelFields[7] in modelKeys
            rxns = dropdims(model[modelFields[7]]; dims = 2)
        else
            error("The vector `$(modelFields[7])` does not exist in `$modelName`.")
        end

        # load the reaction names vector
        if modelFields[8] in modelKeys
            mets = dropdims(model[modelFields[8]]; dims = 2)
        else
            error("The vector `$(modelFields[8])` does not exist in `$modelName`.")
        end

        # determine the size of S
        nMets = size(S,1)
        nRxns = size(S,2)

        return LPproblem(S, b[1:nMets], c[1:nRxns], lb[1:nRxns], ub[1:nRxns], osense, csense[1:nMets], rxns, mets)
    else
        error("The variable named `$modelName` does not exist. Please set `$modelName` to a known variable in the `.mat` file.")
    end

end

export loadModel
#-------------------------------------------------------------------------------------------
