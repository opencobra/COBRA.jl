function getTestModel()

    if !isfile("ecoli_core_model.mat")
        print("Downloading the ecoli_core model ...")
        ecoliModel = HTTP.get("https://github.com/LCSB-BioCore/COBRA.models/raw/master/mat/ecoli_core_model.mat")
        write("ecoli_core_model.mat", ecoliModel.body)
        printstyled("Done.\n"; color=:green)
    else
        @info "The ecoli_core model already exists.\n"
    end

end
