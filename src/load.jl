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
    loadModel(fileName, modelName::String="model", printLevel)

Function used to load a COBRA model from an existing .mat file

# INPUTS

- `filename`:       Name of the `.mat` file that contains the model structure

# OPTIONAL INPUTS

- `modelName`:      String with the name of the model structure (default: "model")
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
julia> model = loadModel("myModel.mat", "myModelName", 2);
```

See also: `MAT.jl`, `matopen()`, `matread()`
"""
function loadModel(fileName::String, modelName::String="model", printLevel::Int=1)

    file = matopen(fileName)
    vars = matread(fileName)

    if exists(file, modelName)

        model     = vars[modelName]
        modelKeys = keys(model)
        cdPresent = false

        # set the model fields
        modelFields = ["ub", "lb", "osense", "c", "b", "csense", "rxns", "mets"]

        # determine if the model file contains a coupled model or not, i.e. if a C matrix is present
        if "C" in modelKeys && "d" in modelKeys
            if size(model["C"]) > (0, 0) && size(model["d"]) > (0, 0)
                # model is a coupled model
                if printLevel > 0
                    @info "The model named $modelName loaded from $fileName is a coupled model."
                end
                cdPresent = true
                S = [model["S"]; model["C"]]
            else
                error("The fields C and d are present in the loaded model structure $modelName in the $fileName, but are not of the right size.")
            end

            # set the model fields
            push!(modelFields, "d", "dsense", "ctrs")

            # load the vector d
            if modelFields[9] in modelKeys
                d = vec(model[modelFields[9]])
            else
                error("The vector `$(modelFields[9])` does not exist in `$modelName`.")
            end
        else
            if "A" in modelKeys
                # legacy structure if a matrix A is present
                S = model["A"]
                if printLevel > 0
                    @warn "The named $modelName loaded from $fileName is a coupled model, but has a legacy structure."
                end
            else
                # model is an uncoupled model
                S = model["S"]
                if printLevel > 0
                    @info "The model named $modelName loaded from $fileName is a uncoupled model."
                end
            end
        end

        # determine the size of S
        nMets = size(S,1)
        nRxns = size(S,2)

        # load the upper bound vector ub
        if modelFields[1] in modelKeys
            ub = vec(model[modelFields[1]])
        else
            error("The vector `$(modelFields[1])` does not exist in `$modelName`.")
        end

        # load the lower bound vector lb
        if modelFields[2] in modelKeys
            lb = vec(model[modelFields[2]])
        else
            error("The vector `$(modelFields[2])` does not exist in `$modelName`.")
        end

        # load the objective sense osense
        if modelFields[3] in modelKeys
            osense = model[modelFields[3]]
        else
            osense = -1
            if printLevel > 0
                @info "The model objective is set to be maximized.\n"
            end
        end

        # load the objective vector c
        if modelFields[4] in modelKeys && osense != 0
            c = vec(model[modelFields[4]])
        else
            error("The vector `$(modelFields[4])` does not exist in `$modelName`.")
        end

        # load the right hand side vector b
        if modelFields[5] in modelKeys
            b = vec(model[modelFields[5]])
        else
            b = zeros(length(c))
            error("The vector `$(modelFields[5])` does not exist in `$modelName`.")
        end

        # load the constraint senses
        csense = fill('E',length(b)) # assume all equality constraints

        # initialize the dsense vector for the case of a coupled model
        if cdPresent
            dsense = fill('E',length(d))
        end

        if modelFields[6] in modelKeys
            for i = 1:length(csense)
                csense[i] = model[modelFields[6]][i][1] # convert to chars
            end

            # retrieve the dsense vector for a coupled model
            if cdPresent
                for i = 1:length(dsense)
                    dsense[i] = model[modelFields[10]][i][1] # convert to chars
                end
            end
        else
            if printLevel > 0
                @info "All constraints assumed equality constaints.\n"
            end
        end

        # load the reaction names vector
        if modelFields[7] in modelKeys
            rxns = vec(model[modelFields[7]])
        else
            error("The vector `$(modelFields[7])` does not exist in `$modelName`.")
        end

        # load the metabolites vector
        if modelFields[8] in modelKeys
            mets = vec(model[modelFields[8]])
        else
            error("The vector `$(modelFields[8])` does not exist in `$modelName`.")
        end

        if cdPresent
            # load the contraints vector
            if modelFields[8] in modelKeys
                ctrs = vec(model[modelFields[11]])
            else
                error("The vector `$(modelFields[11])` does not exist in `$modelName`.")
            end

            # append the d, dsense, and mets vectors for a coupled model
            b = [b; d]
            csense = [csense; dsense]
            mets = [mets; ctrs]
        end

        return LPproblem(S, b[1:nMets], c[1:nRxns], lb[1:nRxns], ub[1:nRxns], osense, csense[1:nMets], rxns, mets)
    else
        error("The variable named `$modelName` does not exist. Please set `$modelName` to a known variable in the `.mat` file.")
    end

end

# keep legacy signature
loadModel(fileName, matrixAS::String="S", modelName::String="model", modelFields::Array{String,1}=["ub", "lb", "osense", "c", "b", "csense", "rxns", "mets"], printLevel::Int=1) = loadModel(fileName, modelName, printLevel)

export loadModel
#-------------------------------------------------------------------------------------------