```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing, BrewingFormulas)
```

# Mash

Temperatures and volumes of the mash. The heat balances take the specific heat of the grain relative to that of water, `grain_heat = 0.4` by default, and neglect the heat capacity of the vessel.

```@docs
strike_temperature
infusion_volume
mash_thickness
mash_volume
grain_absorption
moisture_water
```
