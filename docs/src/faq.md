# [Frequently Asked Questions (FAQ)](@id FAQ)

Why can't I build packages in Julia?
------------------------------------

In order to build the packages of Julia, `cmake` must be installed on *Unix* systems. In addition, `csh` must be installed in order to open a `MATLAB` session. Both packages can be installed using system commands (must have `sudo` rights):
```sh
$ sudo apt-get install cmake csh
```

Why do the Julia instances on remote workers not start?
-------------------------------------------------------

There can be several reasons, but majorly, you must ensure that the Julia configuration on all the nodes is the same than on the host node.

Make sure that the lib folder in `~/.julia` is the same on the **ALL** the nodes (`.ji` files in `/.julia/lib/v0.x`). The exact (bitwise) same usr/lib/julia/* binaries, which requires copying them to each machine. In order to have the same `.ji` files on all nodes, it is recommended to copy them from a central storage space (or cloud) to the library folder on the node:
```sh
$ cp ~/centralStorage/CPLEX.ji ~/.julia/lib/v0.x/
$ cp ~/centralStorage/MathProgBase.ji ~/.julia/lib/v0.x/
```
Once all the `.ji` have been copied, do not use or build the modules on the nodes. In other words, **do not type using CPLEX/MathProgBase at the [REPL](https://en.wikibooks.org/wiki/Introducing_Julia/The_REPL)**. Alternatively, you may set `JULIA_PKGDIR` to a cloud or common storage location.

Some workers are dying - how can I avoid this?
----------------------------------------------
Set the enviornment variables explicity on the host in the `.bashrc` file or `/etc/profile.d`
```sh
export JULIA_WORKER_TIMEOUT=1000;
```

I cannot access the SSH nodes. What am I doing wrong?
-----------------------------------------------------

You must have configured your [ssh keys](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) in order to be able to access the nodes, or you must access the nodes without credentials.

My machine is a Windows machine, and everything is so slow. What can I do?
--------------------------------------------------------------------------

Some Windows users may have to wait a while when installing Julia. The performance of `COBRA.jl` is unaffected by this relatively long load time. However, you may try these avenues of fixing this:

Try setting the `git` parameters correctly (using git bash that you can download from [here](https://git-for-windows.github.io/)):
```sh
$ git config --global core.preloadindex true
$ git config --global core.fscache true
$ git config --global gc.auto 256
```
Make sure that you set the following [environment variables](http://www.computerhope.com/issues/ch000549.htm) correctly:
```
$ set JULIA_PKGDIR=C:\Users\<yourUsername>\.julia\vx.y.z
$ set HOME=C:\Users\<yourUsername>\AppData\Local\Julia-x.y.z
```
Make sure that the `.julia` folder is **not** located on a network. This slows the processes in Julia down dramatically.

How can I generate the documentation?
-------------------------------------

You can generate the documentation using [`Documenter.jl`](https://github.com/JuliaDocs/Documenter.jl) by typing in `/docs`:
```sh
$ julia --color=yes makeDoc.jl
```

How can I get the latest version of `COBRA.jl`
----------------------------------------------

If you want to enjoy the latest untagged (but eventually unstable) features of `COBRA.jl`, do the following from within `Julia`:
```Julia
julia> Pkg.checkout("COBRA", "develop")
```
