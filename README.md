# BrewingFormulas

Formulas used in beer brewing calculations, as plain stateless Julia functions working
with [Unitful.jl](https://github.com/JuliaPhysics/Unitful.jl) quantities and the brewing
units of [UnitfulBrewing.jl](https://github.com/JuliaBrewing/UnitfulBrewing.jl).

This package is still **under development** and not yet registered. It is the formula
layer of the BrewQuiver brewing software.

```julia
julia> using Unitful, UnitfulBrewing, BrewingFormulas

julia> abv(1.050u"sg", 1.010u"sg")
5.316690074810317 %

julia> ibu(30u"g", 10u"percent", 1.050u"sg", 60u"minute", 20u"L")
34.59961158766487 IBU

julia> wort_color([4u"kg" => 3u"°L", 0.3u"kg" => 120u"EBC"], 20u"L")
7.586923163856394 SRM
```

## Conventions

- Arguments are Unitful quantities in any unit of the right dimension; results are
  quantities.
- Gravities are accepted in `°P`, `Brix`, `sg` or `gu`, and must carry their unit (a plain
  `1.050` or `12` is rejected, and so is a percentage). Conversions between sugar contents
  and specific gravity use the keyword `eq`, by default `SugarGravityQuad()` from
  UnitfulBrewing. Results derived from a gravity come back in the same unit family.
- Fractions (attenuation, alpha acids, moisture, ...) are `percent` quantities or plain
  numbers taken as fractions: `75u"percent"` and `0.75` are the same.

## Models

When several empirical formulas exist for the same thing, each is a *model*, a singleton
type passed as the first argument and selected by dispatch. Without a model, the default
in `DEFAULT_MODELS` is used.

| Quantity | Models | Default |
|---|---|---|
| sugar contents ↔ gravity | `SugarGravityQuad`, `SugarGravity` (keyword `eq`) | `SugarGravityQuad()` |
| hop utilization / IBU | `Tinseth`, `Rager` | `Tinseth()` |
| MCU → SRM | `Morey`, `Daniels`, `Mosher`, `Noonan` | `Morey()` |
| alcohol by volume | `Balling`, `SimpleABV` | `Balling()` |
| refractometer final gravity | `TerrillCubic`, `TerrillLinear` | `TerrillCubic()` |

New models are added by subtyping, e.g. `struct MyModel <: BitternessModel end`, and
defining `BrewingFormulas.utilization(::MyModel, gravity, time; eq)`.

## Contents

- **Gravity and extract:** `plato`, `specific_gravity`, `extract_mass`,
  `gravity_from_extract`, `volume_for_gravity`, `solution_gravity`, `solution_volume`
  (volume of a wort from its water and extract), `hydrometer_correction`,
  `potential_from_yield`, `yield_from_potential`, `potential_extract`.
- **Attenuation and alcohol:** `apparent_attenuation`, `real_attenuation`, `real_extract`,
  `apparent_extract`, `final_gravity`, `abw`, `abv`, `real_extract_from_abw`, `calories`.
- **Refractometer:** `refractometer_gravity`, `refractometer_final_gravity`.
- **Color:** `mcu`, `srm`, `wort_color`, `srm_rgb`, `srm_hex`.
- **Bitterness:** `utilization`, `alpha_acid_mass`, `isomerized_alpha_acids`, `ibu`.
- **Mash:** `strike_temperature`, `infusion_volume`, `mash_thickness`, `mash_volume`,
  `grain_absorption`, `moisture_water`.
- **Boil and volumes:** `water_density`, `volume_at_temperature`, `evaporated_volume`.
- **Carbonation:** `residual_co2`, `priming_sugar` (with `Sucrose`, `Glucose`, `CornSugar`,
  `PrimingSugar(yield)`), `carbonation_pressure`, `carbonation_level`.
- **Yeast:** `pitch_cells`.
