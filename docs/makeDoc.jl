#-------------------------------------------------------------------------------------------
#=
    Purpose:    Make file for documentation
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       October 2016
=#

#-------------------------------------------------------------------------------------------

using Documenter

if !isdefined(:includeCOBRA) includeCOBRA = true end

if includeCOBRA
    include("../src/COBRA.jl")
    include("../src/load.jl")
    include("../src/solve.jl")
    include("../src/distributedFBA.jl")
    include("../src/connect.jl")
    include("../src/checkSetup.jl")
    include("../src/tools.jl")
    include("../src/PALM.jl")
end

makedocs(format = :html,
         sitename = "COBRA.jl",
         clean   = false,
         pages = Any[ # Compat: `Any` for 0.4 compat
                 "index.md",
                 "Beginner's Guide" => "cbg.md",
                 "Tutorial" => "cobratutorial.md",
                 "Configuration" => "configuration.md",
                 "Modules and Functions" => "functions.md",
                 "FAQ" => "faq.md",
                 "Index" => "contents.md"
                 ],
         doctest = false
        )

deploydocs(repo = "github.com/opencobra/COBRA.jl.git",
           julia  = get(ENV, "JULIA_VER", ""),
           target = "build",
           make = nothing,
           deps = nothing,
           latest = get(ENV, "GIT_BRANCH", "")
          )
