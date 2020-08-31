function getTestModel()

    if !isfile("ecoli_core_model.mat")
        print("Downloading the ecoli_core model ...")
        ecoliModel = HTTP.get("http://bigg.ucsd.edu/static/models/e_coli_core.mat")
        write("ecoli_core_model.mat", ecoliModel.body)
        printstyled("Done.\n"; color=:green)
    else
        @info "The ecoli_core model already exists.\n"
    end

end
