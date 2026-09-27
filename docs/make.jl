using Documenter
using Talos

makedocs(;
    modules = [Talos],
    authors = "Andrés Morales, Juan Daleman",
    sitename = "Talos.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://kyma-un.github.io/JuliaRobTB",
        edit_link = "main",
    ),
    pages = [
        "Inicio" => "index.md",
        "Referencia" => "reference.md",
    ],
)

deploydocs(;
    repo = "github.com/kyma-un/JuliaRobTB",
    devbranch = "main",
)
