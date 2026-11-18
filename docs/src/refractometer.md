```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing, BrewingFormulas)
```

# Refractometer

Refractometers are calibrated for sucrose solutions; wort reads higher by the wort correction factor, and once fermentation starts the alcohol distorts the reading, so the final gravity is estimated by an empirical fit.

```@docs
refractometer_gravity
refractometer_final_gravity
```
