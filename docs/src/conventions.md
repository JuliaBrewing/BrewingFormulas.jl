```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing, BrewingFormulas)
```

# Conventions and models

```@docs
BrewingFormulas
```

## Arguments

- **Units:** arguments are Unitful quantities in any unit of the right dimension, and
  results are quantities.
- **Gravities** are accepted in `°P`, `Brix`, `sg` or `gu`, and must carry their unit. A
  plain number is rejected, since `1.050` and `12` are both plausible gravities, and so is
  a percentage. Results derived from a gravity come back in the same unit family:

  ```jldoctest
  julia> final_gravity(1.050u"sg", 75u"percent")
  1.0121194807789198 sg

  julia> final_gravity(12u"°P", 75u"percent")
  3.0 °P

  julia> plato(1.050)
  ERROR: ArgumentError: a gravity must carry its unit (°P, Brix, sg or gu), got 1.05; e.g. 1.050u"sg" or 12u"°P"
  [...]
  ```

- **Conversions** between sugar contents and specific gravity use the equivalence given by
  the keyword `eq`, by default `SugarGravityQuad()` from UnitfulBrewing.
- **Fractions** (attenuation, alpha acids, moisture, ...) are `percent` quantities, or
  plain numbers taken as fractions: `75u"percent"` and `0.75` are the same.

```@docs
BrewingFormulas.DEFAULT_EQUIVALENCE
BrewingFormulas.WATER_DENSITY_20C
```

## Models

When several empirical formulas exist for the same quantity, each one is a *model*: a
singleton type passed as the first argument and selected by dispatch. Without a model, the
default one in [`DEFAULT_MODELS`](@ref) is used:

```jldoctest
julia> srm(10)
7.239807780133753 SRM

julia> srm(Daniels(), 10)
10.4 SRM
```

| Quantity | Models | Default |
|:-------- |:------ |:------- |
| sugar contents ↔ gravity | `SugarGravityQuad`, `SugarGravity` (keyword `eq`) | `SugarGravityQuad()` |
| hop utilization, IBU | [`Tinseth`](@ref), [`Rager`](@ref) | `Tinseth()` |
| MCU → SRM | [`Morey`](@ref), [`Daniels`](@ref), [`Mosher`](@ref), [`DrueyDaniels`](@ref), [`DrueyNoonan`](@ref) | `Morey()` |
| alcohol by volume | [`Balling`](@ref), [`SimpleABV`](@ref) | `Balling()` |
| refractometer final gravity | [`TerrillCubic`](@ref), [`TerrillLinear`](@ref) | `TerrillCubic()` |

New models are added by defining a subtype of the corresponding abstract type and a method
for it, without changing this package.

```@docs
DEFAULT_MODELS
AbstractModel
BitternessModel
Tinseth
Rager
ColorModel
Morey
Daniels
Mosher
DrueyDaniels
DrueyNoonan
ABVModel
Balling
SimpleABV
RefractometerModel
TerrillLinear
TerrillCubic
```
