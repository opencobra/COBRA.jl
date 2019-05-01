function getTestModel()

    if !isfile("ecoli_core_model.mat")
        print("Downloading the ecoli_core model ...")

        # JL: I was not able to access the mat file in gcrg.ucsd.edu, so I decided to use the address in BIGG
        # ecoliModel = HTTP.request("GET", "http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/ecoli_core_model.mat")
        ecoliModel = HTTP.request("GET", "http://bigg.ucsd.edu/static/models/e_coli_core.mat")

        write("ecoli_core_model.mat", ecoliModel.body)
        printstyled("Done.\n"; color=:green)
    else
        @info "The ecoli_core model already exists."
    end

end
