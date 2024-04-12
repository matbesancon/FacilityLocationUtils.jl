using FacilityLocationUtils
using Documenter

DocMeta.setdocmeta!(FacilityLocationUtils, :DocTestSetup, :(using FacilityLocationUtils); recursive=true)

makedocs(;
    modules=[FacilityLocationUtils],
    authors="Mathieu Besançon <mathieu.besancon@gmail.com> and contributors",
    sitename="FacilityLocationUtils.jl",
    format=Documenter.HTML(;
        canonical="https://matbesancon.github.io/FacilityLocationUtils.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/matbesancon/FacilityLocationUtils.jl",
    devbranch="main",
)
