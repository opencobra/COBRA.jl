#-------------------------------------------------------------------------------------------
#=
    Purpose:    Implementation for Ridge FBA 
    Authors:    Fatemeh Heydari - University of Tehran
                Mojtaba Tefagh  - Sharif University of Technology 
    Date:       December 2022
=#

#-------------------------------------------------------------------------------------------

"""
    RidgeFBA(metabolic_model,c,lambda) 

RidgeFBA optimizes the desired objective function while minimizing L2 norm of the flux vector
The flux vector computed by RidgeFBA is more consistent with the actual values


# INPUTS

- metabolic model:  Metabolic models contain sotoichiometric matrix  and also other informations such as flux boundaries 
                    and Gene-Protein-Reaction rules. They can be found in different formats including .xml.
                    Metabolic models can be downloaded from [BiGG Models](http://bigg.ucsd.edu/) or elsewhere.

- c:                A vector with the same length as the metabolic model reactions, determining the objective function.
                    For example, if biomass is meant to be the objective function, the corresponding element in c vector
                    is set to 1 and the others are zero. 


- lambda:           Regularization coefficient for the L2 norm term in the objective function of the optimization problem.
                    The larger lambda, the smaller the flux vector.

 

# OUTPUTS

- flux_vector:      It is the calculated flux distribution, which is of type Vector{Float64}
                    (a vector whose elements are Float64), So this can be indexed and used like any other vector. 


# EXAMPLE

flux_vector=(metabolic_model,c,lambda)                                                           

"""

using JuMP, Ipopt , SBML


function RidgeFBA(metabolic_model,C,lambda)
       
    #determining irreversible to set the appropriate boundary
    irreversible_indices=[]
    lb,ub=flux_bounds(metabolic_model)
    for i in 1:length(metabolic_model.reactions)        
        if lb[i][1]==0
            push!(irreversible_indices,i)
        end    
    end

    #getting the stoichiometric matrix 
    _,_,s_matrix=stoichiometry_matrix(metabolic_model)

    #Defining the optimization model and the solver 
    model=JuMP.Model(optimizer_with_attributes(Ipopt.Optimizer))

    #Defining the flux variables 
    @variable(model,-1000<=v[1:length(metabolic_model.reactions)]<=1000)       

    #Constraint regarding irreversible reactions
    @constraint(model,[j in irreversible_indices],0<=v[j]<=1000) #+                                           

    #the stoichiometric constraint, coming from the primal
    @constraint(model, s_matrix*v.==0)
   
    #the length of the vector C,which is actually the number of nonzero elements, is calculated for normalization purposes  
    nonzero=findall(x->x!=0,C)
    n_selected=size(nonzero,1)

    @objective(model,Max,sum(C[i]*v[i] for i in 1:size(v,1) ) - (n_selected/length(metabolic_model.reactions))*lambda*sum(v[e]^2 for e in 1:size(v,1)))

    #giving random initial values to the variables
    for i in 1:size(v,1)
        if i in irreversible_indices
            set_start_value(v[i],rand(0:0.01:1000))
        else
            set_start_value(v[i],rand(-1000:0.01:1000))
        end
    end
    
    JuMP.optimize!(model)

    # If the solver terminates without finding the optimal solution, the termination status is printed out for user 
    if JuMP.raw_status(model)!="Solve_Succeeded"
        println(JuMP.termination_status(model))
                     
    end



    return JuMP.value.(v)
end

