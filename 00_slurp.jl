using HTTP
using JSON3

const _globi_root = "https://api.globalbioticinteractions.org/"

function interactiontypes()
    url = "https://api.globalbioticinteractions.org/interactionTypes?format=json.v2"
    req = HTTP.get(url)
    return JSON3.read(req.body)
end

function construct_url(root, taxon, itype, default_params, offset=0)
    p_string = ["$(p.first)=$(p.second)" for p in default_params]
    push!(p_string, "offset=$(offset)")
    url = root * "taxon/$(taxon)/$(itype)?" * join(p_string, "&")
    return url
end

function interactions(taxon::String, itype::String)
    query_parameters = ["format" => "json.v2", "includeObservations" => true]
    output = []
    keepgoing = true
    while keepgoing
        url = construct_url(_globi_root, taxon, itype, query_parameters, length(output))
        req = HTTP.get(url)
        js = JSON3.read(req.body)
        out = [Dict(zip(js.columns, jd)) for jd in js.data]
        keepgoing = !isempty(js.data)
        append!(output, out)
    end
    return unique(output)
end

types = interactiontypes()

for org in ["Virus", "Viruses"]
    for it in String.(collect(keys(types)))
        @info "$(org) $(it)"
        int = interactions(org, it)
        open("$(org)-$(it).json", "w") do io
            JSON3.pretty(io, int)
        end
    end
end

