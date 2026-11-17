"""
    AbstractModel

Supertype of the models, the singleton types that select one of several empirical formulas
for the same quantity, by dispatch. New models are added by defining a subtype and the
corresponding methods, e.g.

```julia
struct MyUtilization <: BitternessModel end
BrewingFormulas.utilization(::MyUtilization, gravity, time; eq = SugarGravityQuad()) = ...
```
"""
abstract type AbstractModel end

"""
    BitternessModel

Models for the utilization of alpha acids in the boil: [`Tinseth`](@ref), [`Rager`](@ref).
"""
abstract type BitternessModel <: AbstractModel end

"""
    Tinseth()

Glenn Tinseth's model for the utilization of alpha acids,
`utilization = 1.65 × 0.000125^(sg - 1) × (1 - exp(-0.04 t)) / 4.15`, with `t` in minutes.
"""
struct Tinseth <: BitternessModel end

"""
    Rager()

Jackie Rager's model for the utilization of alpha acids,
`utilization = (18.11 + 13.86 tanh((t - 31.32) / 18.27)) / 100 / (1 + GA)`, with `t` in
minutes and the gravity adjustment `GA = max(0, (sg - 1.050) / 0.2)`.
"""
struct Rager <: BitternessModel end

"""
    ColorModel

Models converting malt color units (MCU) to SRM: [`Morey`](@ref), [`Daniels`](@ref),
[`Mosher`](@ref), [`Noonan`](@ref).
"""
abstract type ColorModel <: AbstractModel end

"Dan Morey's model, `SRM = 1.4922 MCU^0.6859`, recommended for colors below 50 SRM."
struct Morey <: ColorModel end

"Ray Daniels' model, `SRM = 0.2 MCU + 8.4`, meant for darker beers (MCU > 10)."
struct Daniels <: ColorModel end

"Randy Mosher's model, `SRM = 0.3 MCU + 4.7`, meant for darker beers."
struct Mosher <: ColorModel end

"Greg Noonan's model, `SRM = 15.03 MCU^0.27 - 15.53`."
struct Noonan <: ColorModel end

"""
    ABVModel

Models for the alcohol by volume: [`Balling`](@ref), [`SimpleABV`](@ref).
"""
abstract type ABVModel <: AbstractModel end

"""
    Balling()

Balling's relations between original extract, real extract and alcohol: the real extract
`RE = 0.1808 OE + 0.8192 AE`, the alcohol by weight `ABW = (OE - RE) / (2.0665 - 0.010665 OE)`
and the alcohol by volume `ABV = ABW × FG / ρ_ethanol`, all extracts in °P.
"""
struct Balling <: ABVModel end

"""
    SimpleABV()

The usual homebrewing approximation `ABV = 131.25 (OG - FG)`, with gravities in sg.
"""
struct SimpleABV <: ABVModel end

"""
    RefractometerModel

Models for estimating the final gravity from refractometer readings:
[`TerrillLinear`](@ref), [`TerrillCubic`](@ref).
"""
abstract type RefractometerModel <: AbstractModel end

"Sean Terrill's simplified linear fit of the final gravity from refractometer readings."
struct TerrillLinear <: RefractometerModel end

"Sean Terrill's simplified cubic fit of the final gravity from refractometer readings."
struct TerrillCubic <: RefractometerModel end

"""
    DEFAULT_MODELS

The models used when none is given:

- `gravity = SugarGravityQuad()`, the equivalence between °P and sg;
- `bitterness = Tinseth()`;
- `color = Morey()`;
- `abv = Balling()`;
- `refractometer = TerrillCubic()`.
"""
const DEFAULT_MODELS = (
    gravity = SugarGravityQuad(),
    bitterness = Tinseth(),
    color = Morey(),
    abv = Balling(),
    refractometer = TerrillCubic(),
)
