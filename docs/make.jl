# Print units as in the REPL on macOS, e.g. `L⁻¹` instead of `L^-1`
ENV["UNITFUL_FANCY_EXPONENTS"] = "true"

using Documenter
using Unitful
using UnitfulBrewing
using BrewingFormulas

DocMeta.setdocmeta!(BrewingFormulas, :DocTestSetup,
                    :(using Unitful, UnitfulBrewing, BrewingFormulas); recursive = true)

# The list of references is kept at the root of the repository, in REFERENCES.md, and
# copied into the documentation when it is built.
let refs = read(joinpath(@__DIR__, "..", "REFERENCES.md"), String)
    header = """
    ```@meta
    EditURL = "https://github.com/JuliaBrewing/BrewingFormulas.jl/blob/main/REFERENCES.md"
    ```

    """
    write(joinpath(@__DIR__, "src", "references.md"), header * refs)
end

makedocs(;
    modules = [BrewingFormulas],
    sitename = "BrewingFormulas.jl",
    authors = "Ricardo Rosa",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://JuliaBrewing.github.io/BrewingFormulas.jl",
        edit_link = "main",
    ),
    pages = [
        "Home" => "index.md",
        "Conventions and models" => "conventions.md",
        "Formulas" => [
            "Gravity and extract" => "gravity.md",
            "Attenuation and alcohol" => "attenuation.md",
            "Refractometer" => "refractometer.md",
            "Color" => "color.md",
            "Bitterness" => "bitterness.md",
            "Mash" => "mash.md",
            "Boil and volumes" => "boil.md",
            "Carbonation" => "carbonation.md",
            "Yeast" => "yeast.md",
            "Water" => "water.md",
        ],
        "References" => "references.md",
    ],
)

deploydocs(;
    repo = "github.com/JuliaBrewing/BrewingFormulas.jl",
    devbranch = "main",
    push_preview = false,
)
