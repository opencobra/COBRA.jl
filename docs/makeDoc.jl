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

    # only include PALM.jl if MATLAB is present
    if sizeof(Pkg.installed("MATLAB")) > 0
        include("../src/PALM.jl")
    end
end

# special concatenation of tutorials until issue 701 is fixed:
# https://github.com/JuliaDocs/Documenter.jl/issues/701
# Note: When generating a new tutorial is .ipynb, export as .md and save in ./tutorials/.

# save the current directory
currentDir = pwd()

# concatenate tutorial files
cd("$(Pkg.dir("COBRA"))/tutorials")

# define list of tutorials to be concatenated
tutorials = ["tutorial-COBRA.jl.md", "tutorial-distributedFBA.jl.md", "tutorial-PALM.jl.md"]

# concatenate the tutorials properly speaking
cat = ""
for tut in tutorials
    tmp = read(tut, String)
    cat = cat * tmp
end

# set all headers one level lower
cat = replace(cat, "\n#", "\n##")

# write out the tutorial to new file
open("tutorials.md", "w") do f
    write(f, "# Tutorials \n\n")
    write(f, cat)
end

# move the tutorials.md file to the docs folder
mv("tutorials.md", "$(Pkg.dir("COBRA"))/docs/src/tutorials.md", remove_destination=true)

# change back to the old directory
cd(currentDir)

makedocs(format = :html,
         sitename = "COBRA.jl",
         pages = Any[ # Compat: `Any` for 0.4 compat
                 "index.md",
                 "Beginner's Guide" => "beginnerGuide.md",
                 "Tutorials" => "tutorials.md",
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
