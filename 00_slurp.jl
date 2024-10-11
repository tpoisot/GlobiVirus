using HTTP
using JSON3

const _globi_root = "https://api.globalbioticinteractions.org/"

function allint_getter(taxon::String, source::Bool=true)
    output = []
    stem = source ? "sourceTaxon" : "targetTaxon"
    keepgoing = true
    while keepgoing
        @info length(output)
        url = _globi_root * "interaction?" * stem * "=" * taxon * "&offset=$(length(output))"
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

