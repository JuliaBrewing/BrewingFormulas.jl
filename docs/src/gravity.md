```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing, BrewingFormulas)
```

# Gravity and extract

Degrees Plato are the mass percentage of extract in a solution, and the specific gravity is its density relative to water, both at 20 °C. These definitions relate the gravity, the volume and the mass of extract, and give the volume of a wort from its water and dissolved extract.

```@docs
plato
specific_gravity
extract_mass
gravity_from_extract
volume_for_gravity
solution_gravity
solution_volume
hydrometer_correction
potential_from_yield
yield_from_potential
potential_extract
BrewingFormulas.SUCROSE_PPG
```
