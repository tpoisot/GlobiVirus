using JSON3

all_int = unique(vcat(JSON3.read("Virus.json"), JSON3.read("Viruses.json")))

if ~isfile("ObiWanVirobi.json")
    open("ObiWanVirobi.json", "w") do io
        JSON3.pretty(io, all_int)
    end
end

# Simplified version

simplified = unique([Dict(:from => r.source_taxon_name, :as => r.interaction_type, :to => r.target_taxon_name) for r in all_int])

if ~isfile("compact.json")
    open("compact.json", "w") do io
        JSON3.pretty(io, simplified)
    end
end
