# Boil and volumes: water density with temperature, thermal contraction, evaporation.

"""
    water_density(temperature)

The density of water, in `kg/L`, at the given `temperature`, by Kell's formula (1975),
valid from 0 to 150 °C.

# References

- G. S. Kell, "Density, thermal expansivity, and compressibility of liquid water from 0° to
  150 °C", *J. Chem. Eng. Data* 20 (1975) 97–105, <https://doi.org/10.1021/je60064a005>.

```jldoctest
julia> water_density(20u"°C")
0.9982041322005837 kg L⁻¹
```
"""
function water_density(temperature::Unitful.Temperature)
    t = _val(u"°C", temperature)
    ρ = (999.83952 + 16.945176t - 7.9870401e-3t^2 - 46.170461e-6t^3 + 105.56302e-9t^4 -
         280.54253e-12t^5) / (1 + 16.879850e-3t)
    return ρ / 1000 * u"kg/L"
end

"""
    volume_at_temperature(volume, from, to)

The volume, at temperature `to`, of a `volume` of liquid measured at temperature `from`,
taking its thermal expansion as that of water. E.g. the shrinkage of a wort when cooled.

```jldoctest
julia> volume_at_temperature(25u"L", 100u"°C", 20u"°C")
24.002196197557904 L
```
"""
volume_at_temperature(volume::Unitful.Volume, from::Unitful.Temperature,
                      to::Unitful.Temperature) =
    volume * float(water_density(from) / water_density(to))

"""
    evaporated_volume(volume, rate, time)

The volume evaporated from a `volume` of boiling wort during `time`, with the evaporation
`rate` either as a volume per time (e.g. `4u"L/hr"`) or as a fraction of `volume` per time
(e.g. `10u"percent/hr"`).
"""
evaporated_volume(volume::Unitful.Volume, rate::Unitful.VolumeFlow, time::Unitful.Time) =
    min(volume, float(uconvert(unit(volume), rate * time)))

evaporated_volume(volume::Unitful.Volume, rate::Unitful.Frequency, time::Unitful.Time) =
    min(volume, float(uconvert(unit(volume), volume * rate * time)))
