#-------------------------------------------------------------------------------------------
#=
    Purpose:    Test all reactions (serial)
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------


if !@isdefined includeCOBRA
    includeCOBRA = true
end

pkgDir = joinpath(dirname(pathof(COBRA)))

# output information
testFile = @__FILE__

# number of workers
nWorkers = 1

# create a pool and use the COBRA module if the testfile is run in a loop
if includeCOBRA
    connectSSHWorkers = false
    include(pkgDir*"/connect.jl")

    # create a parallel pool and determine its size
    if isdefined(:nWorkers) && isdefined(:connectSSHWorkers)
        workersPool, nWorkers = createPool(nWorkers, connectSSHWorkers)
    end

    using COBRA, HTTP

    include("getTestModel.jl")
end

# download the ecoli_core_model
getTestModel()

# include a common deck for running tests
include(pkgDir*"/../config/solverCfg.jl")

# change the COBRA solver
solver = changeCobraSolver(solverName, solParams)

# load an external mat file
model = loadModel(pkgDir*"/../test/ecoli_core_model.mat", "S", "model")

# select the number of reactions
rxnsList = 1:length(model.rxns)

minFluxT = [-2.542357461637039
            -2.542357461637039
            -3.813536192455565
             0.848587001219999
             0.848587001219999
            -3.813536192455565
                             0
                             0
            -1.430076072170838
            -2.214311337554841
             8.390000000000001
            34.825655310640002
             0.786529800000000
            -26.528831096100003
             0.848587001219999
            35.984903218817756
            -2.145114108256252
             8.686592417159998
            -2.214311337554841
                             0
                             0
                             0
            15.206556434392406
                             0
                             0
                             0
                             0
            -10.000000000000000
                             0
                             0
            15.777787788000069
            20.935954109512409
                             0
                             0
            -5.559968424258519
            -25.619523994320012
            -3.214895047684765
                             0
                             0
             1.171711973239997
                             0
                             0
                             0
                             0
                             0
            -0.512905973490859
                             0
                             0
             9.863240997959998
             9.046615951886109
             0.201115669860000
                             0
            -5.358852754398518
                             0
                             0
            -1.271178730818519
                             0
            -32.258228771220004
             0.848587001219999
                             0
            -2.145114108256252
                             0
                             0
            -3.249704488360005
                             0
                             0
            32.659177871419992
                             0
             4.288789693440000
            17.992451609408878
                             0
             1.171711973239997
                             0
            -14.299019113100011
            -17.909167832660000
                             0
            -16.732519251860001
             2.893407175260005
                             0
                             0
                             0
                             0
                             0
            -2.542357461637041
            -0.620909006871476
            -8.611284454940005
                             0
                             0
                             0
            -8.045926834700001
            -0.154536201070266
                             0
            -0.154536201070266
            -0.466372805801210
             1.171711973239997
            ]

maxFluxT = [0
            0
            0
            0.008894513835920
            0.008894513835920
            0
            0.017160912866050
            0.008045926834700
            0
            0
            0.025550912866050
            0.059381011244985
            0.000873921506968
            -0.015206556434392
            0.008894513835920
            0.051239047988640
            0
            0.016732519251860
            0
            0.003813536192456
            0.002542357461637
            0.001430076072171
            0.026528831096100
            0.002214311337555
            0.011322274661708
            0
            0
            -0.009046615951886
            0
            0.001271178730819
            0.027100062449708
            0.032258228771220
            0.002145114108256
            0
            -0.004288789693440
            -0.017992451609409
            -0.002893407175260
            0.002542357461637
            0.001674235401566
            0.009217638807940
            0.017160912866050
            0.068643651464200
            0.068643651464200
            1.000000000000000
            0
            0.008045926834700
            0
            0.024137780504100
            0.017909167832660
            0.010000000000000
            0.017362028535910
            0
            0.013073238842470
            0.017160912866050
            0.017160912866050
            0
            0.024137780504100
            -0.020935954109512
            0.008894513835920
            0.008045926834700
            0
            0.008045926834700
            0
            0.016091853669400
            0.011935837517263
            0.015318594740410
            0.051239047988640
            0.044759390689735
            0.005559968424259
            0.025619523994320
            0.019888197055060
            0.025290553320174
            0.011322274661708
            0.009838761391000
            -0.009863240997960
            0.024137780504100
            -0.008686592417160
            0.003214895047685
            0.020346778124675
            0.017160912866050
            0.017160912866050
            0.003813536192456
            0.021382900237218
            0
            0.015526496049160
            -0.000565357620240
            0.022881217154733
            0.022881217154733
            1.000000000000000
            0
            0.007905216653480
            0.037041821616640
            0.007905216653480
            0.007621279395680
            0.009217638807940
            ]

# define an optPercentage value
optPercentage = 90.0

# launch the distributedFBA process
startTime = time()
minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver; nWorkers=nWorkers, optPercentage=optPercentage, preFBA=true)
solTime = time() - startTime

# Test numerical values - test on floor as different numerical precision with different solvers
@test floor(maximum(maxFlux)) == 1000.0
@test floor(minimum(maxFlux)) == -21.0
@test floor(maximum(minFlux)) == 35.0
@test floor(minimum(minFlux)) == -33.0
@test floor(norm(maxFlux))    == 1427.0
@test floor(norm(minFlux))    == 93.0
@test abs((model.c' * minFlux)[1] - optPercentage / 100.0 * optSol) < 1e-6

# test each element of the minimum and maximum flux vectors
for i = 1:length(minFlux)
    @test abs(minFluxT[i] - minFlux[i]) < 1e-3
    @test abs(maxFluxT[i]*1000 - maxFlux[i]) < 1e-3
end

# save the variables to the current directory
saveDistributedFBA("testFile.mat")

# remove the file to clean up
run(`rm testFile.mat`)

# print a solution summary
printSolSummary(testFile, optSol, maxFlux, minFlux, solTime, nWorkers, solverName)
