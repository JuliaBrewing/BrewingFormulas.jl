```@meta
DocTestSetup = :(using Unitful, UnitfulBrewing, BrewingFormulas)
```

# Color

Malt color units (MCU), the color of the grains times their mass over the volume of wort, are additive; they are converted to the SRM color of the wort by one of the color models.

```@docs
mcu
srm
wort_color
srm_rgb
srm_hex
```
