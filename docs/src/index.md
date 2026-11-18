```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing, BrewingFormulas)
```

# BrewingFormulas.jl

Formulas used in beer brewing calculations, as plain stateless Julia functions working with
[Unitful.jl](https://github.com/JuliaPhysics/Unitful.jl) quantities and the brewing units of
[UnitfulBrewing.jl](https://github.com/JuliaBrewing/UnitfulBrewing.jl). It covers gravity and
extract, attenuation and alcohol, refractometer corrections, color, bitterness, mash and boil
volumes and temperatures, carbonation and yeast pitching.

It is the formula layer of the BrewQuiver brewing software, and can be used on its own as a
brewing calculator at the Julia REPL.

!!! note
    This package is still under development and not yet registered.

## Installation

Since neither this package nor UnitfulBrewing is registered yet, install them from their
repositories:

```julia
using Pkg
Pkg.add(url = "https://github.com/JuliaBrewing/UnitfulBrewing.jl")
Pkg.add(url = "https://github.com/JuliaBrewing/BrewingFormulas.jl")
```

## Quick start

```jldoctest
julia> using Unitful, UnitfulBrewing, BrewingFormulas

julia> abv(1.050u"sg", 1.010u"sg")
5.316690074810317 %

julia> abv(SimpleABV(), 1.050u"sg", 1.010u"sg")
5.250000000000004 %

julia> ibu(30u"g", 10u"percent", 1.050u"sg", 60u"minute", 20u"L")
34.59961158766487 IBU

julia> wort_color([4u"kg" => 3u"°L", 0.3u"kg" => 120u"EBC"], 20u"L")
7.586923163856394 SRM

julia> strike_temperature(67u"°C", 20u"°C", 15u"L", 5u"kg")
73.2779481394733 °C
```

The arguments can be given in any unit of the right dimension, and the results are
quantities, which can be converted to other units with `uconvert`.

## Contents

- [Conventions and models](conventions.md): how arguments are given, and how alternative
  formulas are selected by dispatch.
- Formulas: [gravity and extract](gravity.md), [attenuation and alcohol](attenuation.md),
  [refractometer](refractometer.md), [color](color.md), [bitterness](bitterness.md),
  [mash](mash.md), [boil and volumes](boil.md), [carbonation](carbonation.md) and
  [yeast](yeast.md).
- [References](references.md): the sources of all the formulas.

## License

This package is licensed under the
[MIT license](https://github.com/JuliaBrewing/BrewingFormulas.jl/blob/main/LICENSE).
