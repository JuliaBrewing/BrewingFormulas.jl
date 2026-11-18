# Bitterness: the utilization of alpha acids in the boil and the resulting IBUs.
#
# One IBU is taken as 1 mg/L of iso-alpha acids. The models give the utilization, the
# fraction of the alpha acids that end up isomerized in the wort; other effects (hop form,
# hop bags, first wort or mash hopping, ...) go in the multiplicative `factor`.

"""
    utilization([model = Tinseth()], gravity, time; eq = SugarGravityQuad())

The fraction of alpha acids isomerized in a wort of the given (boil) `gravity` after boiling
for `time`, with the given [`BitternessModel`](@ref); see the models for the references.

```jldoctest
julia> utilization(1.050u"sg", 60u"minute")
0.2306640772510991
```
"""
utilization(gravity, time::Unitful.Time; eq::Equivalence = DEFAULT_EQUIVALENCE) =
    utilization(DEFAULT_MODELS.bitterness, gravity, time; eq)

function utilization(::Tinseth, gravity, time::Unitful.Time; eq::Equivalence = DEFAULT_EQUIVALENCE)
    bigness = 1.65 * 0.000125^(_sg(gravity, eq) - 1)
    timefactor = (1 - exp(-0.04 * _val(u"minute", time))) / 4.15
    return bigness * timefactor
end

function utilization(::Rager, gravity, time::Unitful.Time; eq::Equivalence = DEFAULT_EQUIVALENCE)
    ga = max(0.0, (_sg(gravity, eq) - 1.050) / 0.2)
    timefactor = (18.11 + 13.86 * tanh((_val(u"minute", time) - 31.32) / 18.27)) / 100
    return timefactor / (1 + ga)
end

"""
    alpha_acid_mass(mass, alpha)

The mass of alpha acids, in `g`, in a `mass` of hops with the alpha acid content `alpha`
(a percentage or fraction).
"""
alpha_acid_mass(mass::Unitful.Mass, alpha) = uconvert(u"g", mass * _fraction(alpha))

"""
    isomerized_alpha_acids([model = Tinseth()], mass, alpha, gravity, time; factor = 1, eq = SugarGravityQuad())

The mass, in `mg`, of iso-alpha acids from a `mass` of hops with alpha acid content `alpha`,
boiled for `time` in a wort of the given `gravity`, with the utilization given by the
[`BitternessModel`](@ref) times `factor`.
"""
isomerized_alpha_acids(mass::Unitful.Mass, alpha, gravity, time::Unitful.Time;
                       factor::Real = 1, eq::Equivalence = DEFAULT_EQUIVALENCE) =
    isomerized_alpha_acids(DEFAULT_MODELS.bitterness, mass, alpha, gravity, time; factor, eq)

isomerized_alpha_acids(model::BitternessModel, mass::Unitful.Mass, alpha, gravity,
                       time::Unitful.Time; factor::Real = 1,
                       eq::Equivalence = DEFAULT_EQUIVALENCE) =
    uconvert(u"mg", factor * utilization(model, gravity, time; eq) * alpha_acid_mass(mass, alpha))

"""
    ibu(isoalpha, volume)
    ibu([model = Tinseth()], mass, alpha, gravity, time, volume; factor = 1, eq = SugarGravityQuad())

The bitterness, in `IBU`, of a `volume` of wort with the mass `isoalpha` of iso-alpha acids,
1 IBU being taken as 1 mg/L, the usual approximation. In the second form, the iso-alpha acids come from a `mass` of hops with
alpha acid content `alpha` boiled for `time` in a wort of the given `gravity`, as in
[`isomerized_alpha_acids`](@ref).

```jldoctest
julia> ibu(30u"g", 10u"percent", 1.050u"sg", 60u"minute", 20u"L")
34.59961158766487 IBU
```
"""
ibu(isoalpha::Unitful.Mass, volume::Unitful.Volume) =
    float(ustrip(u"mg/L", isoalpha / volume)) * u"IBU"

ibu(mass::Unitful.Mass, alpha, gravity, time::Unitful.Time, volume::Unitful.Volume;
    factor::Real = 1, eq::Equivalence = DEFAULT_EQUIVALENCE) =
    ibu(DEFAULT_MODELS.bitterness, mass, alpha, gravity, time, volume; factor, eq)

ibu(model::BitternessModel, mass::Unitful.Mass, alpha, gravity, time::Unitful.Time,
    volume::Unitful.Volume; factor::Real = 1, eq::Equivalence = DEFAULT_EQUIVALENCE) =
    ibu(isomerized_alpha_acids(model, mass, alpha, gravity, time; factor, eq), volume)
