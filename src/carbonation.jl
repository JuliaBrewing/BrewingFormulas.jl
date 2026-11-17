# Carbonation: residual CO₂, priming and force carbonation.

"""
    AbstractPrimingSugar

Sugars for priming, characterized by their [`co2_yield`](@ref), the mass of CO₂ produced
per mass of sugar fully fermented: [`Sucrose`](@ref), [`Glucose`](@ref),
[`CornSugar`](@ref), or a custom `PrimingSugar(yield)`, e.g. for malt extracts.
"""
abstract type AbstractPrimingSugar end

"""
    PrimingSugar(yield)

A priming sugar producing the mass fraction `yield` of CO₂ when fermented, e.g. for malt
extracts, which are only partially fermentable.
"""
struct PrimingSugar <: AbstractPrimingSugar
    yield::Float64
end

"Sucrose, C₁₂H₂₂O₁₁ + H₂O → 4 C₂H₅OH + 4 CO₂."
struct Sucrose <: AbstractPrimingSugar end

"Anhydrous glucose (dextrose), C₆H₁₂O₆ → 2 C₂H₅OH + 2 CO₂."
struct Glucose <: AbstractPrimingSugar end

"Corn sugar, i.e. dextrose monohydrate, C₆H₁₂O₆·H₂O."
struct CornSugar <: AbstractPrimingSugar end

const _M_CO2 = 44.0095
"""
    co2_yield(sugar)

Mass of CO₂ produced per mass of the priming `sugar`, assuming full fermentation.
"""
co2_yield(s::PrimingSugar) = s.yield
co2_yield(::Sucrose) = 4 * _M_CO2 / 342.2965
co2_yield(::Glucose) = 2 * _M_CO2 / 180.156
co2_yield(::CornSugar) = 2 * _M_CO2 / 198.171

"""
    residual_co2(temperature)

The CO₂, in `vols`, remaining dissolved in a beer after fermentation at `temperature` (the
highest temperature reached after fermentation), at 1 atm:
`3.0378 - 0.050062 T + 0.00026555 T²`, with `T` in °F.

```julia
julia> residual_co2(20u"°C")
0.8614871999999993 vols
```
"""
function residual_co2(temperature::Unitful.Temperature)
    t = _val(u"°F", temperature)
    return (3.0378 - 0.050062t + 0.00026555t^2) * u"vols"
end

"""
    priming_sugar(sugar, volume, target, temperature)

The mass, in `g`, of priming `sugar` to bring a `volume` of beer, fermented up to
`temperature`, to the `target` carbonation (in `vols`), using 1 vols = 1.977 g/L of CO₂.

```julia
julia> priming_sugar(CornSugar(), 20u"L", 2.5u"vols", 20u"°C")
145.86469026359262 g
```
"""
function priming_sugar(sugar::AbstractPrimingSugar, volume::Unitful.Volume,
                       target::CarbonationQuantity, temperature::Unitful.Temperature)
    Δ = max(0u"vols", uconvert(u"vols", target) - residual_co2(temperature))
    co2 = uconvert(u"g/L", Δ, CarbonationDensity()) * volume
    return uconvert(u"g", co2 / co2_yield(sugar))
end

"""
    carbonation_pressure(level, temperature)

The gauge pressure, in `psi`, of CO₂ to force carbonate a beer at `temperature` to the
given carbonation `level` (in `vols`), from the usual fit of the solubility charts
(`T` in °F, `V` in vols, `P` in psig):

    P = -16.6999 - 0.0101059 T + 0.00116512 T² + 0.173354 T V + 4.24267 V - 0.0684226 V².

```julia
julia> carbonation_pressure(2.5u"vols", 38u"°F")
11.246172830000003 psi
```
"""
function carbonation_pressure(level::CarbonationQuantity, temperature::Unitful.Temperature)
    t, v = _val(u"°F", temperature), _val(u"vols", level)
    p = -16.6999 - 0.0101059t + 0.00116512t^2 + 0.173354t * v + 4.24267v - 0.0684226v^2
    return p * u"psi"
end

"""
    carbonation_level(pressure, temperature)

The carbonation, in `vols`, reached at equilibrium under the gauge `pressure` of CO₂ at
`temperature`; the inverse of [`carbonation_pressure`](@ref).
"""
function carbonation_level(pressure::Unitful.Pressure, temperature::Unitful.Temperature)
    t, p = _val(u"°F", temperature), _val(u"psi", pressure)
    a = -0.0684226
    b = 4.24267 + 0.173354t
    c = -16.6999 - 0.0101059t + 0.00116512t^2 - p
    Δ = b^2 - 4a * c
    Δ < 0 && throw(DomainError(pressure, "no carbonation level for this pressure"))
    return (-b + sqrt(Δ)) / (2a) * u"vols"    # the smaller, physical root (a < 0)
end
