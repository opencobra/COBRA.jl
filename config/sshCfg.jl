#-------------------------------------------------------------------------------------------
#=
    Purpose:    Define an array with all connection details to SHH nodes
    Author:     Laurent Heirendt - LCSB - Luxembourg
    Date:       September 2016
=#

#-------------------------------------------------------------------------------------------

sshWorkers = Array{Dict{Any, Any}}(3)

sshWorkers[1,:] = Dict( "usernode"   => "first.last@server1.com",
                        "procs"  => 8,
                        "dir"    => `~/COBRA.jl/`,
                        "flags"  => `-6 -p8022`,
                        "exename"=> "/usr/bin/julia/bin/./julia")

sshWorkers[2,:] = Dict( "usernode"   => "first.last@server2.com",
                        "procs"  => 16,
                        "dir"    => `~/COBRA.jl/`,
                        "flags"  => `-p22`,
                        "exename"=> "/usr/bin/julia/bin/./julia")

sshWorkers[3,:] = Dict( "usernode"   => "first.last@server3.com",
                        "procs"  => 32,
                        "dir"    => `~/COBRA.jl/`,
                        "flags"  => `-4 -p9997`,
                        "exename"=> "/usr/bin/julia/bin/./julia")
