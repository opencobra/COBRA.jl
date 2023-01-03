# tutorial-RidgeFBA

This tutorial serves as a reference to get started with `RidgeFBA`. Download the live notebook from [here](https://github.com/opencobra/COBRA.jl/tree/master/tutorials).

If you are not familiar with `COBRA.jl`, or how `COBRA.jl` should be installed, please refer to the tutorial on `COBRA.jl`.



`RidgeFBA` is a member of COBRA analyses family. It returns a unique flux distribution which is also more consistent with the actual values comparing to the similar methods.


`RidgeFBA` solves the following quadratic programming to find a context-specific objective function:


*Minimize:*


$$cv - 𝑹∗\parallel v \parallel_2$$

*Subject to:*

$$Sv=0$$

$$v_j \geq 0 \quad \forall j \in I$$
 

Where R is regularization coefficient, v is flux vector, S is stoichiometric matrix and I is the set of irreversible reactions. 


## Prerequisites

`RidgeFBA` reads SBML models by [SBML.jl](https://github.com/LCSB-BioCore/SBML.jl),
models the optimization problem by [JuMP.jl](https://github.com/jump-dev/JuMP.jl)
and uses [Ipopt.jl](https://github.com/jump-dev/Ipopt.jl) as the solver.

So these three packages are required to run `RidgeFBA`,
in addition [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl) and [Test.jl](https://github.com/JuliaLang/julia/blob/master/stdlib/Test/src/Test.jl) are needed
to run the test for this function. 

They can be installed as follows:


```julia
using Pkg
Pkg.add("COBRA")
Pkg.add("JuMP")
Pkg.add("Ipopt")
Pkg.add("SBML")
```

This function can be called simply, by a single line of code:



```julia
using COBRA
flux_vector=RidgeFBA(metabolic_model,c,lambda)
```


 #### Input:
  **metabolic model**: Metabolic models contain stoichiometric matrix above all, and also other informations such as flux boundaries and Gene-Protein-Reaction rules. They can be found in different formats including .xml. Metabolic models can be downloaded from [BiGG Models](http://bigg.ucsd.edu/) or elsewhere.
  
  **c**: A vector with the same length as the metabolic model reactions, determining the objective function.
  For example, if biomass is meant to be the objective function, the corresponding element in c vector is set to 1 and the others are zero. 
  
  **lambda**: Regularization coefficient for the L2 norm term in the objective function of the optimization problem. The larger lambda, the smaller the flux vector.
  
 #### Output:
  **flux_vector**: It is the calculated flux distribution, which is of type Vector{Float64} (a vector whose elements are Float64), So this can be indexed and used like any other vector. 
  


The following is an example in which `RidgeFBA` is used to find the flux distribution for *E. coli* when the biomass reaction is set as objective function 


```julia
# Downloading the metabolic model
ecoli_model=HTTP.get("http://bigg.ucsd.edu/static/models/e_coli_core.xml")
write("e_coli_core.xml",ecoli_model.body)
ecoli_metabolic_model=readSBML("e_coli_core.xml")


 
```


```julia
#The name of the reactions are extracted as a vector.
reaction_names_keySet=keys(ecoli_metabolic_model.reactions)
reaction_names=[]
for item in reaction_names_keySet
    push!(reaction_names,item)

end

```


```julia
#Obtaining the biomass reaction index
for n in 1:length(ecoli_metabolic_model.reactions)
    
    if occursin("BIOMASS" , reaction_names[n])
        global biomass_index=n
    end
end

```


```julia
#As biomass is set as objective function the corresponding element in c vector is set to 1
c_test=zeros(1,length(ecoli_metabolic_model.reactions))
c_test[biomass_index]=1

```


```julia
#running RidgeFBA
flux_vector=RidgeFBA(ecoli_metabolic_model,c_test,10^-5)       
```
