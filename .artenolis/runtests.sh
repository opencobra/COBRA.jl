# print out the version and the architecture
echo "ARCH = $ARCH"
echo "JULIA_VER = $JULIA_VER"

# launch the test script
if [ "$ARCH" == "Linux" ]; then
    if [ "$JULIA_VER" == "v0.6.3" ]; then

        # remove th julia directory to clean the installation directory
        rm -rf ~/.julia/v0.6/COBRA

        # add the COBRA module
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --code-coverage=user --color=yes -e 'Pkg.clone(pwd()); Pkg.test(pwd());'

        # adding coverage
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Coverage; Codecov.submit_generic(process_folder(), Pkg.dir("COBRA"), service="artenolis", commit=ENV["GIT_COMMIT"], branch=ENV["GIT_BRANCH"]);'
        #/mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'cd(Pkg.dir("COBRA")); using Coverage; Codecov.submit_generic(process_folder(), service="artenolis", branch=ENV["GIT_BRANCH"], commit=ENV["GIT_COMMIT"]);'

    elif [ "$JULIA_VER" == "v0.7.0" ]; then
        # temporary addition for julia 0.6 until new version of MAT tagged
        #/mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.add("MAT"); Pkg.checkout("MAT")'

        # add the COBRA module
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.clone(pwd())'
        #/mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.build()'
        #/mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.test("COBRA",coverage=true)'
    fi
fi

CODE=$?
exit $CODE
