#-------------------------------------------------------------------------------------------
#=
    Purpose:    Tools for working with COBRA models
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       January 2017
=#

#-------------------------------------------------------------------------------------------
"""
    findRxnIDS(model, rxnsList)

Function that returns a vector of reaction IDs that correspond to an input list of reaction
names.

# INPUTS

- `model`:          An `::LPproblem` object that has been built using the `loadModel` function.
                        All fields of `model` must be available.

# OPTIONAL INPUTS

- `rxnsList`:       List of reaction names (default: all reactions in the model)

# OUTPUTS

- `rxnIDs`:       	Vector with the reaction IDs that correspond to the reaction names in `rxnsList`

# EXAMPLES

- Minimum working example:
```julia
julia> findRxnIDS(model)
```

- Full input/output example
```julia
julia> rxnIDs, rxnIDsNE = findRxnIDS(model, rxnsList)
```

- Full input/output example
```julia
julia> rxnIDs, rxnIDsNE = findRxnIDS(model, ["reactionName1", "reactionName2"])
```

See also: `loadModel()`, `distributedFBA()`

"""

function findRxnIDS(model, rxnsList=model.rxns)

    rxnIDs = [] # reaction names that exist in the model
    rxnIDsNE = [] # reaction names that do not exist

    # loop through the input reaction list
    if rxnsList == model.rxns
        rxnIDs = model.rxns
    else
        for j = 1:length(rxnsList)
            # initialize a flag of not having found the reaction
            flag = false

            # loop through all the reactions
            for i = 1:length(model.rxns)
                if model.rxns[i] == rxnsList[j]

                    # save the reaction ID
                    push!(rxnIDs, i)

                    # set the flag of having found the reaction
                    flag = true
                end
            end

            # if the reaction name has not been found, save the index of the rxnsList
            if !flag
                push!(rxnIDsNE, j)
            end
        end
    end

    # throw an error when no reaction matched any in the model
    if length(rxnIDs) == 0
        error("No reactions were found that match the requested reacion numbers (IDs). Please change `rxnList`.\n")
    end

    # throw an error when no reaction matched any in the model
    if length(rxnIDsNE) != 0
        @warn "Some reaction names are not in the model; their indices in the `rxnsList` are reported in `rxnIDsNE`.\n"
    end

    return rxnIDs, rxnIDsNE

end

#------------------------------------------------------------------------------------------
"""
    convertUnitRange(vect)

Converts a unit range vector to an array type vector.
If the vector is not of UnitRange{Int64} type, the same vector is returned.

# INPUTS

- `vect`:         Any vector (UnitRange{Int64} will be converted to Array{Int64})

# OUTPUTS

- `retVect`       Converted vector (if type of input vector is UnitRange{Int64})

# EXAMPLES

- Minimum working example
```julia
julia> a = 1:4
1:4

julia> convertUnitRange(a)
4-element Array{Int64,1}:
  1
  2
  3
  4
```

"""

function convertUnitRange(vect)

    retVect = zeros(Int64, length(vect))

    if typeof(vect) == UnitRange{Int64}
        for k = 1:length(vect)
            retVect[k] = vect[k]
        end
    else
        retVect = vect
    end

    return retVect

end

export findRxnIDS, convertUnitRange

#-------------------------------------------------------------------------------------------
