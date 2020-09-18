pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh '''/home/vmhadmin/julia-1.2.0/bin/julia --color=yes -e \'import Pkg; Pkg.clone(pwd()); Pkg.test("COBRA", coverage=true); Pkg.rm("COBRA");\'
'''
      }
    }

  }
}