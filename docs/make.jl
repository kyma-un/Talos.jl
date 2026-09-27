# Talos es una herramienta desarrollada por Kyma. https://kyma-un.github.io
using Documenter
using Talos

makedocs(;
    modules = [Talos],
    authors = "Kyma, Andrés Morales, Juan Daleman",
    sitename = "Talos.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
        canonical = "https://kyma-un.github.io/JuliaRobTB",
        edit_link = "main",
        lang = "es",
        description = "Talos es una herramienta desarrollada por Kyma. https://kyma-un.github.io",
        footer = "Talos es una herramienta desarrollada por [Kyma](https://kyma-un.github.io).",
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
