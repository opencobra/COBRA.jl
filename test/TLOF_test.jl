#This script tests both TLOF_Preprocess and TLOF for the example provided below.

using JuMP 
using Ipopt
using HTTP
using Test
using DataFrames
using CSV

#Downloading the metabolic model
ecoli_model=HTTP.get("http://bigg.ucsd.edu/static/models/iJO1366.xml")
write("iJO1366.xml",ecoli_model.body)
metabolic_model=readSBML("iJO1366.xml")

#An example of flux data for *E. coli* to run TLOF
flux_estimation= CSV.read("flux estimation.csv",DataFrame)


lambda=0.001
s_matrix=stoichiometry_matrix(metabolic_model)
selected_rxns=1:length(metabolic_model.reactions)
carbon_uptake_rxn="R_SUCCt2_2pp"
carbon_uptake_rate=15.902
sd=0.305667764744552

rxn_names,module_flux=TLOF_Preprocess(flux_estimation)
c,obj=TLOF(metabolic_model,lambda,flux_estimation,module_flux,rxn_names,selected_rxns,carbon_uptake_rxn,carbon_uptake_rate,sd)

                                                           
@test isapprox(obj ,9.577185672827648; atol=0.0001)
