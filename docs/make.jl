using Documenter, FHist
using Pluto: Configuration.CompilerOptions
using PlutoStaticHTML

notebooks = [
    "UnROOT Tutorial",
]

include("build.jl")

build()
md_files = markdown_files()
T = [t => f for (t, f) in zip(notebooks, md_files)]

makedocs(;
    modules=[],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    pages=[
        "Tutorials" => T,
    ],
    repo="https://github.com/Moelf/HSF_Julia_Tutorial/blob/{commit}{path}#L{line}",
    sitename="HSF_Julia_Tutorial",
    authors="Jerry Ling",
    assets=String[],
)

deploydocs(;
    repo="github.com/Moelf/HSF_Julia_Tutorial",
)
