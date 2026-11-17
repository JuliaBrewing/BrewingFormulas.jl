# Yeast pitching.

"""
    pitch_cells(volume, gravity; rate = 0.75, eq = SugarGravityQuad())

The number of yeast cells to pitch in a `volume` of wort of the given `gravity`, at `rate`
million cells per mL per °P (usually 0.75 for ales and 1.5 for lagers).

```julia
julia> pitch_cells(20u"L", 12u"°P")
1.8e11
```
"""
pitch_cells(volume::Unitful.Volume, gravity; rate::Real = 0.75,
            eq::Equivalence = DEFAULT_EQUIVALENCE) =
    rate * 1e6 * _val(u"mL", volume) * _plato(gravity, eq)
