using HTTP
using JSON3

const _globi_root = "https://api.globalbioticinteractions.org/"

# TODO: get the list of interactionType and work from this one, keeping in mind that they
# are all symetrical so only need to pick one
# See e.g.
# https://api.globalbioticinteractions.org/interactionTypes

# TODO: need to change the search strategy a little bit
# Specifically - use the taxon endpoint and then go through all types of interaction with
# the includeObservations flag set to true
# Se e.g.
# https://api.globalbioticinteractions.org/taxon/Callinectes%20sapidus/preyedUponBy?includeObservations=true

function allint_getter(taxon::String, source::Bool=true)
    output = []
    stem = source ? "sourceTaxon" : "targetTaxon"
    keepgoing = true
    while keepgoing
        @info length(output)
        url = _globi_root * "interaction?" * stem * "=" * taxon * "&offset=$(length(output))" * "&taxonIdPrefix=NCBI"
        req = HTTP.get(url)
        js = JSON3.read(req.body)
        out = [Dict(zip(js.columns, jd)) for jd in js.data]
        keepgoing = !isempty(js.data)
        append!(output, out)
    end
    return output
end

for org in ["Virus", "Viruses"]
    int = allint_getter(org, true)
    open("$(org).json", "w") do io
        JSON3.pretty(io, int)
    end
end

