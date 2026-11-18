```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing, BrewingFormulas)
```

# Carbonation

The CO₂ left in the beer after fermentation, the priming sugar to reach a given carbonation, and the pressure for forced carbonation.

```@docs
residual_co2
priming_sugar
AbstractPrimingSugar
PrimingSugar
Sucrose
Glucose
CornSugar
co2_yield
carbonation_pressure
carbonation_level
```
