# Tutorial - PALM.jl

This tutorial serves as a reference to get started with `PALM.jl`. Download the live notebook from [here](https://github.com/opencobra/COBRA.jl/tree/master/tutorials).

If you are not familiar with `COBRA.jl`, or how `COBRA.jl` should be installed, please refer to the tutorial on `COBRA.jl`.

**Note:** In order to run this tutorial, you must have [MATLAB](https://www.mathworks.com) installed and a valid MATLAB license.

Please make sure to have the following packages installed: `COBRA.jl`, `MATLAB`, and `MAT`.


```julia

import Pkg;
#Pkg.add("COBRA")
Pkg.add("MATLAB")

```

## Writing a MATLAB script

The main functionality of `PALM.jl` is to run a MATLAB script that loads a different model each time from a directory of models. The MATLAB script can be based on any tutorial of [the CORBA Toolbox](https://git.io/cobratoolbox) or on a custom script.

In order to illustrate the inner workings of `PALM.jl`, we will write a custom script that loads a different model out of a folder of 4 models, and calculates several numerical characteristics of the stoichiometric matrix. The analysis is accelerated by distributing these 4 models across 2 different workers.

The MATLAB script can be saved as `scriptFile.m` in any folder. For illustration purposes, this script is located in the `test/` folder of the COBRA.jl installation directory, but may be located in any other directory. Its content can be visualized as follows:


```julia
using COBRA
run(`cat $(joinpath(dirname(pathof(COBRA)), "../test/scriptFile.m"))`)
```

Note that the variables marked with `PALM_` are the ones defined within Julia.

## Installation of the COBRA Toolbox

As the `scriptFile.m` refers to the `readCbModel` function implemented in [the COBRA Toolbox](https://git.io/cobratoolbox), the COBRA Toolbox must be installed by following the installation instructions [here](https://opencobra.github.io/cobratoolbox/stable/installation.html).

If you already have a working installation of the COBRA Toolbox, you may skip the following lines. The COBRA Toolbox may be installed in any directory - please write it down for later use in this tutorial.

**Advanced users** may also want to install the COBRA Toolbox directly installed from Julia. You must have `git` (or `gitBash` on Windows) installed - see [requirements](https://opencobra.github.io/cobratoolbox/stable/installation.html#system-requirements).

For illustration purposes of this tutorial, the COBRA Toolbox will be installed in the `~/tmp` directory. This may take a while, depending on the speed of your internet connection.


```julia
installDir = "~/tmp/cobratoolbox"
```


```julia
# if you already ran this tutorial once, you may also remove the previous installation directory with the following command:
# Note: The following command removes the directory specified above!
run(`rm -rf $installDir`)
```


```julia
run(`git clone --depth=1 --recurse-submodules https://github.com/opencobra/cobratoolbox.git $installDir`);
@info "The COBRA Toolbox has been cloned successfully to the $installDir directory."
```


```julia
run(`mkdir "~/tmp/cobratoolbox"`)
```

**Tip:** When using `PALM.jl`, it is advised to add the `--recurse-submodules` flag. This will speed up the simultaneous initialisations on several workers.

## Connecting workers

Similarly to `distributedFBA.jl`, the workers may be added using `createPool`, given in the external function `connect.jl`, which must be included separately. Please note that also workers connected via SSH may be added to the pool of workers.


```julia
using Distributed
include(joinpath(dirname(pathof(COBRA)), "connect.jl"))
```


```julia
# specify the total number of parallel workers
nWorkers = 4 

# create a parallel pool
workersPool, nWorkers = createPool(nWorkers) 
```

After initializing the workers, the packages must be loaded on each worker:


```julia
@everywhere using COBRA;
@everywhere using MATLAB;
```

## Sharing the load

Within `PALM.jl`, the load is shared automatically. However, it might be illustrative to check upfront when planning a large-scale simulation how the load will be shared. For this purpose, the `shareLoad` function within the `COBRA.jl` package may be used.

If there are 4 models to be distributed across 4 workers, the load sharing is ideal, as every worker will run 1 model.


```julia
nWorkers, quotientModels, remainderModels = COBRA.shareLoad(4)
```

In case of sharing 6 models across the connected 4 workers, the load sharing will not be ideal:


```julia
nWorkers, quotientModels, remainderModels = COBRA.shareLoad(6)
```

## Preparing the models

In order to illustrate how several models can be loaded, the models included in the COBRA Toolbox may be used. The list of models may be displayed using:


```julia
modelDir = "$installDir/test/models/mat"
readdir(modelDir)
```

## Output variables

The variables that should be retrieved from the script (see `scriptFile.m`) can be defined in an array as follows:


```julia
varsCharact = ["nMets", "nRxns", "nElem", "nNz"]
```

**Note:** The variable names defined in `varsCharac` are the same as in the MATLAB script.

## Running PALM

The input parameters of `PALM.jl` are defined as:


```julia
? PALM
```

Now, all variables are defined, and `PALM.jl` is ready to be launched:


```julia
PALM(modelDir, "$(joinpath(dirname(pathof(COBRA)), "../test/scriptFile.m"))"; nMatlab=nWorkers, outputFile="modelCharacteristics.mat", varsCharact=varsCharact, cobraToolboxDir=installDir)
```

The output file that contains the values of the variables defined in `varsCharact` for each model is `modelCharacteristics.mat`. This file can be read back into Julia by using:


```julia
using MAT
vars = matread("modelCharacteristics.mat")
```

The full data set can be retrieved with: 


```julia
summaryData = vars["summaryData"]
```
