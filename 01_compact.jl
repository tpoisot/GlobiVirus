using JSON3

# What we need to read
relevant_files = readdir()
filter!(startswith("Virus"), relevant_files)
filter!(endswith(".json"), relevant_files)

# Read everything
compendium = unique(vcat(JSON3.read.(relevant_files)...))

# Function to unmess the mess
function foreheadkiss(record)
    o_source = record["source_taxon_name"]
    o_target = record["target_taxon_name"]
    relation = record["interaction_type"]
    bor_source = record["source_specimen_basis_of_record"]
    bor_target = record["target_specimen_basis_of_record"]
    authority = record["study_title"]
    return Dict(
        :from => o_source,
        :to => o_target,
        :as => relation,
        :bors => bor_source,
        :bort => bor_target,
        :ref => authority
    )
end

allint = unique(foreheadkiss.(compendium))

if ~isfile("ObiWanVirobi.json")
    open("ObiWanVirobi.json", "w") do io
        JSON3.pretty(io, allint)
    end
end
