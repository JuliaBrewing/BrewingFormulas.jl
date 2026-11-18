"""
    BrewingFormulas

Formulas used in beer brewing calculations: gravity and extract, attenuation and alcohol,
refractometer corrections, color, bitterness, mash and boil volumes and temperatures,
carbonation and yeast pitching.

All functions are stateless and work with [Unitful.jl](https://github.com/JuliaPhysics/Unitful.jl)
quantities, with the brewing units of
[UnitfulBrewing.jl](https://github.com/JuliaBrewing/UnitfulBrewing.jl). Arguments may be
given in any unit of the right dimension, and results are quantities.

When several empirical formulas exist for the same thing, each one is a *model*, a
singleton type passed as the first argument, e.g. `utilization(Tinseth(), og, 60u"minute")`
or `srm(Morey(), mcu)`. Calling the function without a model uses the default one, listed
in [`DEFAULT_MODELS`](@ref).

## Conventions for the arguments

- Gravities and extracts are accepted in `°P`, `Brix`, `sg` or `gu`, and must carry their
  unit: a plain number is rejected, since `1.050` and `12` are both plausible gravities.
  Conversions between sugar contents and specific gravity use the equivalence given by the
  keyword `eq`, `SugarGravityQuad()` by default.
- Fractions (attenuation, alpha acids, moisture, ...) are accepted as `percent` quantities or
  as plain numbers, which are taken as fractions: `75percent` and `0.75` are the same.
"""
module BrewingFormulas

using Unitful
using Unitful: DimensionlessQuantity, ustrip, uconvert, unit, @u_str
using UnitfulBrewing
using UnitfulBrewing: SugarGravity, SugarGravityQuad, CarbonationDensity
using UnitfulEquivalences: Equivalence

include("conventions.jl")
include("models.jl")
include("gravity.jl")
include("attenuation.jl")
include("refractometer.jl")
include("color.jl")
include("bitterness.jl")
include("mash.jl")
include("boil.jl")
include("carbonation.jl")
include("yeast.jl")

# models
export AbstractModel, BitternessModel, ColorModel, ABVModel, RefractometerModel
export Tinseth, Rager, Morey, Daniels, Mosher, DrueyDaniels, DrueyNoonan, Balling, SimpleABV
export TerrillLinear, TerrillCubic, DEFAULT_MODELS
export SugarGravity, SugarGravityQuad

# gravity and extract
export plato, specific_gravity, extract_mass, gravity_from_extract, volume_for_gravity
export solution_gravity, solution_volume, hydrometer_correction
export potential_from_yield, yield_from_potential, potential_extract

# attenuation and alcohol
export apparent_attenuation, real_attenuation, real_extract, apparent_extract
export final_gravity, abw, abv, real_extract_from_abw, calories

# refractometer
export refractometer_gravity, refractometer_final_gravity

# color
export mcu, srm, wort_color, srm_rgb, srm_hex

# bitterness
export utilization, isomerization_rate, isomerization_factor, alpha_acid_mass,
    isomerized_alpha_acids, ibu

# mash
export strike_temperature, infusion_volume, mash_thickness, mash_volume
export grain_absorption, moisture_water

# boil and volumes
export water_density, volume_at_temperature, evaporated_volume

# carbonation
export AbstractPrimingSugar, PrimingSugar, Sucrose, Glucose, CornSugar, co2_yield
export residual_co2, priming_sugar, carbonation_pressure, carbonation_level

# yeast
export pitch_cells

end # module
