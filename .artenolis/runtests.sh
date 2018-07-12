# print out the version and the architecture
echo "ARCH = $ARCH"
echo "JULIA_VER = $JULIA_VER"

# launch the test script
if [ "$ARCH" == "Linux" ]; then
    if [ "$JULIA_VER" == "v0.6.4" ]; then

        # remove th julia directory to clean the installation directory
        rm -rf ~/.julia/v0.6/COBRA

        # add the COBRA module
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'Pkg.clone(pwd()); cd(Pkg.dir("COBRA")); Pkg.test(pwd(), coverage=true);'

    elif [ "$JULIA_VER" == "v0.7.0" ]; then
        # add the COBRA module
        /mnt/prince-data/JULIA/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.clone(pwd())'
    fi
fi

CODE=$?
exit $CODE
