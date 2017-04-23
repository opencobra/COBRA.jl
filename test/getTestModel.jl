function getTestModel()

    if !isfile("ecoli_core_model.mat")
        print("Downloading the ecoli_core model ...")
        ecoliModel = get("http://gcrg.ucsd.edu/sites/default/files/Attachments/Images/downloads/Ecoli_core/ecoli_core_model.mat")
        save(ecoliModel, "ecoli_core_model.mat")
        print_with_color(:green, "Done.\n")
    else
        info("The ecoli_core model already exists.\n")
    end

end
