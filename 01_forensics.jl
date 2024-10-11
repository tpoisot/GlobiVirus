using JSON3
using StatsBase

all_int = unique(vcat(JSON3.read("Virus.json"), JSON3.read("Viruses.json")))

open("ObiWanVirobi.json", "w") do io
    JSON3.pretty(io, all_int)
end

all_int_type = [a.interaction_type for a in all_int]
interaction_types = sort(collect(countmap(all_int_type)); by=x -> x[2])
