# tutorial-TLOF

This tutorial serves as a reference to get started with `TLOF`. Download the live notebook from [here](https://github.com/opencobra/COBRA.jl/tree/master/tutorials).

If you are not familiar with `COBRA.jl`, or how `COBRA.jl` should be installed, please refer to the tutorial on `COBRA.jl`.


# TLOF
Transcription-based Lasso Objective Finder(TLOF) is an optimization based method to obtain a context-specific objective function for a given condition.



## Formulation
`TLOF` solves the following optimization problem to find a context-specific objective function:

*Minimize:*



$$\parallel v - v_\text{est} \parallel_2 + 𝑹∗\parallel c\parallel_1$$



*Subject to:*

$$\sum_{j \in P}c_j v_j=\text{carbon uptake rate} \times  \text{g}$$

$$ a_j \geq c_j \quad \forall j \in P$$

$$ a_j \geq -c_j \quad \forall j \in P$$

$$\sum_{j \in P}S_ij v_j=0 \quad \forall i \in N$$

$$v_\text{carbon uptake rxn}=\text{carbon uptake rate}$$

$$\sum_{i=1}^N u_i S_ij \geq c_j \quad \forall j \in P$$

$$\sum_{i=1}^N u_i S_ij \geq 0 \quad \forall j \notin P , \text{carbon uptake rxn}$$

$$\sum_{i=1}^N u_i S_ij + \text{g} \geq 0 \quad \forall j \in \text{carbon uptake rxn}$$

$$v_j \geq 0 \quad \forall j \in I$$



Where  v<sub>est</sub> is the flux estimation, v is flux vector, R is regularization coefficient, S is stoichiometric matrix ,  u and g are dual variables , P is the set of reactions considered as “Potential cellular objectives” and *I* is the set of irreversible reactions.

## Prerequisites
`TLOF` reads SBML models by [SBML.jl](https://github.com/LCSB-BioCore/SBML.jl), models the optimization problem by [JuMP.jl](https://github.com/jump-dev/JuMP.jl) and uses [Ipopt.jl](https://github.com/jump-dev/Ipopt.jl) as the solver. 
[LinearAlgebra.jl](https://github.com/JuliaLang/julia/blob/master/stdlib/LinearAlgebra/src/LinearAlgebra.jl) is also required in the computations inside the function.

So these four packages are necessary to run `TLOF`, in addition, [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl), [CSV.jl](https://github.com/JuliaData/CSV.jl), [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl) and [Test.jl](https://github.com/JuliaLang/julia/blob/master/stdlib/Test/src/Test.jl) are needed to run the test script for this function. 
They can be installed as follows:


```julia
using Pkg
Pkg.add("COBRA")

Pkg.add("SBML")
Pkg.add("JuMP")
Pkg.add("Ipopt")

Pkg.add("DataFrames")
Pkg.add("CSV")
Pkg.add("HTTP")
```

This function can be called simply, by a single line of code:


```julia
using COBRA
TLOF(metabolic_model,lambda,flux_estimation,module_flux,selected_rxns,carbon_uptake_rxn,carbon_uptake_rate,sd)
```

#### Input:
  **metabolic model**: Metabolic models contain sotoichiometric matrix  and also other informations such as flux boundaries and Gene-Protein-Reaction rules. They can be found in different formats including .xml. Metabolic models can be downloaded from [BiGG Models](http://bigg.ucsd.edu/) or elsewhere.

  **lambda**: Regularization coefficient for the L1 norm term in the objective function of the optimization problem. The larger lambda, the sparser the objective function.
  
  **flux_estimation**: It is a dataframe that has two columns, the first one contains the name of the reactions and the second one flux values.

*The next two arguments can either be given by the user or assessed by `TLOF_Preprocess` function, provided in this repo.

**module_flux**: Sometimes measuring the flux of a single reaction is not possible, thus we have measured (or estimated) flux, for example, associated with A-B or A+B, where A and B are reactions in metabolic network. On the other hand, the optimization problem finds flux for single reactions (in that example, A and B separately). But in the objective function (see formulation section above), the difference between measured flux and the corresponding predicted value should be calculated so this `module_flux`,  whose dot product with the predicted flux vector returns the appropriate value for `v`, is required to solve the problem.

**rxn_names**: This argument is a vector containing the name of the reactions and can be different from the first column of `flux_estimation` according to the explanations for the previous argument.

**selected_rxns**: A user can define which reactions should be included in potential cellular objective set. This can be either all reactions of the network or any subset of the reactions, defined by their index in the stoichiometric matrix. 

**carbon_uptake_rxn**: The name of the reaction through which carbon is uptaken by a cell, for example,"R_GLCptspp". It should match with the reaction names of metabolic network. 

**carbon_uptake_rate**: The exchange flux associated with the carbon source, measured experimentally.

#### OPTIONAL INPUTS

**sd**: Measurements are usually performed as replicates and the average value is reported, so there is also a standard deviation value. Since problems with inequality constraints converge better, if any value is given to this argument the capacity constraint will be applied as an inequality constraint, otherwise it will be an equality constraint.  
  
  
 #### Output:

  **c**: It is the objective function found by`TLOF` and is of type Vector{Float64} (a vector whose elements are Float64), which has the same length as the `selected_reaction`.
 
  
  **obj**: The optimal value for objective function


## TLOF_Preprocess usage
As it was explained thoroughly for `module_flux` arguement above, this function computes two input data needed to run `TLOF`: 





```julia
rxn_names,module_flux=TLOF_Preprocess(flux_estimation)
```

#### Input:

**flux_estimation**: Just the same as what was mentioned above.

#### Output:

  **rxn_names** and **module_flux**: As explained earlier, what are needed for `TLOF`.

The following is an example in which `TLOF` is used to find the objective function for *E. coli* by using the provided flux estimation data:


```julia
#Downloading the metabolic model
ecoli_model=HTTP.get("http://bigg.ucsd.edu/static/models/iJO1366.xml")
write("iJO1366.xml",ecoli_model.body)
metabolic_model=readSBML("iJO1366.xml")


```


```julia
#An example of flux data for *E. coli* to run TLOF
flux_estimation= CSV.read("flux estimation.csv",DataFrame)



```

For this example all reactions of the metabolic network are allowed to be in potential cellular objective set:


```julia
s_matrix=stoichiometry_matrix(metabolic_model)
selected_rxns=1:length(metabolic_model.reactions)
```

Suitable values are given as input:


```julia
lambda=0.001
carbon_uptake_rxn="R_SUCCt2_2pp"
carbon_uptake_rate=15.902
sd=0.305667764744552


```

`TLOF_Preprocess` is called to obtain the required input for `TLOF`


```julia
rxn_names,module_flux=TLOF_Preprocess(flux_estimation)
```


```julia
#running TLOF
c,obj=TLOF(metabolic_model,lambda,flux_estimation,module_flux,rxn_names,selected_rxns,carbon_uptake_rxn,carbon_uptake_rate,sd)

```
