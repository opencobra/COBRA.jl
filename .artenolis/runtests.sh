# print out the version and the architecture
echo "ARCH = $ARCH"
echo "JULIA_VER = $JULIA_VER"
echo "MATLAB_VER = $MATLAB_VER"

# launch the test script
if [ "$ARCH" == "Linux" ]; then
    if [ "$JULIA_VER" == "v0.6.4" ]; then
        # remove th julia directory to clean the installation directory
        rm -rf $JULIA_PKGDIR/v0.6/COBRA

        # add the COBRA module
        $ARTENOLIS_SOFT_PATH/julia/$JULIA_VER/bin/julia --color=yes -e 'Pkg.clone(pwd()); cd(Pkg.dir("COBRA")); Pkg.test(pwd(), coverage=true);'

    elif [ "$JULIA_VER" == "v0.7.0" ]; then
        # add the COBRA module
        $ARTENOLIS_SOFT_PATH/julia/$JULIA_VER/bin/julia --color=yes -e 'using Pkg; Pkg.clone(pwd())'
    fi

elif [ "$ARCH" == "macOS" ]; then
    # remove th julia directory to clean the installation directory
    rm -rf ~/.julia/v0.6/COBRA

    caffeinate -u &
    /Applications/Julia-$JULIA_VER.app/Contents/Resources/julia/bin/julia --color=yes -e 'Pkg.clone(pwd()); cd(Pkg.dir("COBRA")); Pkg.test(pwd());'

elif [ "$ARCH" == "windows" ]; then
    if [ "$JULIA_VER" == "v0.6.4" ]; then
        # remove th julia directory to clean the installation directory
        rm -rf ~/.julia/v0.6/COBRA

        unset Path
        nohup "D:\\JULIA\\$JULIA_VER\\\bin\\julia.exe" --color=yes -e 'import Base; ENV["MATLAB_HOME"]="D:\\MATLAB\\$(ENV["MATLAB_VER"])"; Pkg.clone(pwd()); cd(Pkg.dir("COBRA")); Pkg.test(pwd());' > output.log & PID=$!

        # follow the log file
        tail -n0 -F --pid=$! output.log 2>/dev/null

        # wait until the background process is done
        wait $PID
    fi
fi

CODE=$?
exit $CODE
