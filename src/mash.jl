# Mash: temperatures, infusions, volumes and losses.
#
# The heat balances take the specific heat of the grain relative to that of water,
# `grain_heat = 0.4` by default, and neglect the heat capacity of the vessel.

"""
    strike_temperature(target, grain_temperature, water, grain; grain_heat = 0.4)

The temperature of the strike `water` (a volume or mass) to reach the `target` mash
temperature when mixed with a mass `grain` of grain at `grain_temperature`, by the heat
balance `T_w = T + (c_g m_g / m_w) (T - T_g)`.

```julia
julia> strike_temperature(67u"°C", 20u"°C", 15u"L", 5u"kg")
73.2779481394733 °C
```
"""
function strike_temperature(target::Unitful.Temperature, grain_temperature::Unitful.Temperature,
                            water::Union{Unitful.Volume, Unitful.Mass}, grain::Unitful.Mass;
                            grain_heat::Real = 0.4)
    t, tg = _val(u"°C", target), _val(u"°C", grain_temperature)
    r = float(uconvert(NoUnits, grain / _water_mass(water)))
    return uconvert(unit(target), (t + grain_heat * r * (t - tg)) * u"°C")
end

"""
    infusion_volume(current, target, water, grain; infusion_temperature = 100u"°C", grain_heat = 0.4)

The volume of water at `infusion_temperature` to add to a mash at temperature `current`,
with the given `water` (volume or mass) and mass `grain`, to raise it to `target`:
`V = (T₂ - T₁)(c_g m_g + m_w) / (T_w - T₂)`.
"""
function infusion_volume(current::Unitful.Temperature, target::Unitful.Temperature,
                         water::Union{Unitful.Volume, Unitful.Mass}, grain::Unitful.Mass;
                         infusion_temperature::Unitful.Temperature = 100u"°C",
                         grain_heat::Real = 0.4)
    t1, t2, tw = _val(u"°C", current), _val(u"°C", target), _val(u"°C", infusion_temperature)
    tw > t2 || throw(ArgumentError("the infusion must be hotter than the target temperature"))
    m = (t2 - t1) * (grain_heat * grain + _water_mass(water)) / (tw - t2)
    return uconvert(u"L", m / WATER_DENSITY_20C)
end

"""
    mash_thickness(water, grain)

The ratio of the `water` volume to the `grain` mass, in `L/kg`.
"""
mash_thickness(water::Unitful.Volume, grain::Unitful.Mass) = uconvert(u"L/kg", water / grain)

"""
    mash_volume(water, grain; displacement = 0.67u"L/kg")

The total volume of a mash with the given `water` volume and `grain` mass, the grain
displacing `displacement` per unit mass.
"""
mash_volume(water::Unitful.Volume, grain::Unitful.Mass; displacement = 0.67u"L/kg") =
    uconvert(unit(water), water + grain * displacement)

"""
    grain_absorption(grain; rate = 1.0u"L/kg")

The volume of liquid retained by a mass `grain` of spent grain, at the given absorption
`rate` (usually from 0.8 to 1.25 L/kg).
"""
grain_absorption(grain::Unitful.Mass; rate = 1.0u"L/kg") = uconvert(u"L", grain * rate)

"""
    moisture_water(grain, moisture)

The volume of water (at 20 °C) brought by a mass `grain` of fermentable with the given
`moisture` content (a percentage or fraction).
"""
moisture_water(grain::Unitful.Mass, moisture) =
    uconvert(u"L", grain * _fraction(moisture) / WATER_DENSITY_20C)
